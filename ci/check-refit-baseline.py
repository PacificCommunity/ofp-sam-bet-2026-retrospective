#!/usr/bin/env python3
"""Check baseline preparation and refusals without R or MFCL execution."""
import copy
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parent.parent
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("retro_baseline", ROOT / "reproduce/baseline.py")
baseline = importlib.util.module_from_spec(spec)
spec.loader.exec_module(baseline)
manifest = json.loads((ROOT / "reproduce/refit-baseline.json").read_bytes())
archive = (ROOT / "reproduce/refit-baseline.tar.gz").read_bytes()
files = baseline.checked_archive(archive, manifest)
checks = []


def require(condition, label):
    if not condition:
        raise RuntimeError(label)
    checks.append(label)


def rejected(function, label):
    try:
        function()
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError):
        checks.append(label)
    else:
        raise RuntimeError("Expected refusal: " + label)


def altered_archive(kind):
    records = manifest["files"]
    raw = io.BytesIO()
    with tarfile.open(fileobj=raw, mode="w:gz", format=tarfile.USTAR_FORMAT) as target:
        for i, row in enumerate(records):
            name = row["path"]
            data = files[name]
            info = tarfile.TarInfo(name)
            info.size, info.mode = len(data), row["mode"]
            if i == 0:
                if kind == "path": info.name = "../outside"
                if kind == "mode": info.mode = 0o777
                if kind == "content": data = bytes([data[0] ^ 1]) + data[1:]
                if kind == "symlink": info.type, info.linkname, info.size = tarfile.SYMTYPE, "/outside", 0
                if kind == "hardlink": info.type, info.linkname, info.size = tarfile.LNKTYPE, "bet.ini", 0
                if kind == "missing": continue
            target.addfile(info, io.BytesIO(data) if info.isfile() else None)
            if i == 0 and kind == "duplicate":
                target.addfile(info, io.BytesIO(data))
    data = raw.getvalue()
    fixture = copy.deepcopy(manifest)
    fixture["archive"].update(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    return data, fixture


refit = (ROOT / "reproduce/refit.R").read_text()
for row in manifest["files"]:
    if row["path"] in ("mfclo64", "00.fixed.par"):
        continue
    require(row["path"] in refit and row["sha256"] in refit,
            "Pinned controller input: " + row["path"])
require(manifest["files"][0]["path"] == "00.fixed.par", "Prepared start PAR included")
require(hashlib.md5(files["00.fixed.par"]).hexdigest() == "01c9056f7268fb643cfc77382980ace0",
        "Historical start-PAR MD5 witness")
require(hashlib.sha256(files["mfclo64"]).hexdigest() in refit, "Pinned controller MFCL engine")
require(len(files) == 11 and "bet.model.ini" not in files, "Eleven files; no derived INI or outputs")
rejected(lambda: baseline.checked_archive(archive[:-1], manifest), "Damaged outer archive")
for kind in ("path", "mode", "content", "symlink", "hardlink", "missing", "duplicate"):
    data, fixture = altered_archive(kind)
    rejected(lambda: baseline.checked_archive(data, fixture), "Unsafe archive: " + kind)

temp_parent = Path(tempfile.gettempdir()).resolve()
with tempfile.TemporaryDirectory(prefix="bet-retro-baseline-", dir=temp_parent) as folder:
    scratch = Path(folder)
    prepared = scratch / "prepared"
    env = dict(os.environ)
    env.pop("MAKEFLAGS", None)
    env.pop("MFLAGS", None)

    def make(value, success):
        result = subprocess.run(["make", "--no-print-directory", "prepare", "INPUT=" + str(value)],
                                cwd=ROOT, env=env, capture_output=True, text=True, timeout=30)
        require((result.returncode == 0) == success, "Make prepare exit: " + str(value))

    make(prepared, True)
    observed = sorted(p.relative_to(prepared).as_posix() for p in prepared.rglob("*") if p.is_file())
    require(observed == sorted(files), "Exactly eleven prepared files")
    for row in manifest["files"]:
        path = prepared / row["path"]
        require(not path.is_symlink() and path.stat().st_size == row["bytes"]
                and hashlib.sha256(path.read_bytes()).hexdigest() == row["sha256"]
                and path.stat().st_mode & 0o777 == row["mode"], "Prepared bytes and mode: " + row["path"])
    before = {name: (prepared / name).read_bytes() for name in files}
    make(prepared, False)
    require(all((prepared / name).read_bytes() == data for name, data in before.items()),
            "Existing prepared files unchanged")
    occupied = scratch / "occupied"
    occupied.write_bytes(b"do not overwrite")
    make(occupied, False)
    require(occupied.read_bytes() == b"do not overwrite", "Existing file unchanged")
    link = scratch / "linked-parent"
    link.symlink_to(scratch, target_is_directory=True)
    broken = scratch / "broken-parent"
    broken.symlink_to(scratch / "absent", target_is_directory=True)
    blocked = ["", "/", "relative", str(ROOT / "new-baseline"), str(scratch) + "//new",
               str(scratch / "existing") + "/../new", str(scratch) + "/./new",
               str(scratch) + "/new\nline", str(scratch) + "/new\rline",
               str(link / "new"), str(broken / "new"), str(scratch / "missing-parent/new")]
    for value in blocked:
        make(value, False)
    require(not (ROOT / "new-baseline").exists() and not (scratch / "new").exists()
            and not (scratch / "missing-parent").exists(), "Rejected paths create no destination")

print(f"Refit baseline passed {len(checks)} source, archive and preparation checks; no model execution.")
