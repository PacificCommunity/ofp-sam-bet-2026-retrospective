#!/usr/bin/env python3
"""Check or prepare the pinned full-refit baseline; never execute a model."""
import argparse
import contextlib
import hashlib
import io
import json
import os
from pathlib import Path
import stat
import sys
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
PATHS = frozenset({"00.fixed.par", "bet.frq", "bet.ini", "bet.tag", "bet.age_length",
                   "bet.reg_scaling", "mfcl.cfg", "doitall.sh", "mfclo64",
                   "model-inputs/S0.90-F2.conf", "selectivity-models/F2.csv"})


def digest(data):
    return hashlib.sha256(data).hexdigest()


def identity(value):
    return value.st_dev, value.st_ino


def signature(value):
    return identity(value), value.st_size, value.st_mtime_ns, value.st_ctime_ns


def read_fd(fd):
    chunks, offset = [], 0
    while True:
        data = os.pread(fd, 1024 * 1024, offset)
        if not data:
            return b"".join(chunks)
        chunks.append(data)
        offset += len(data)


@contextlib.contextmanager
def frozen_bytes(path):
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        before = os.fstat(fd)
        if not stat.S_ISREG(before.st_mode):
            raise ValueError("Expected a regular source file")
        data = read_fd(fd)

        def stable():
            named = os.stat(path, follow_symlinks=False)
            if (signature(os.fstat(fd)) != signature(before)
                    or identity(named) != identity(before) or not stat.S_ISREG(named.st_mode)
                    or read_fd(fd) != data):
                raise ValueError("Baseline source changed while reading")

        stable()
        yield data
        stable()
    finally:
        os.close(fd)


def checked_archive(data, manifest):
    if manifest.get("schema_version") != 1 or manifest["archive"]["path"] != "refit-baseline.tar.gz":
        raise ValueError("Unsupported baseline manifest")
    archive = manifest["archive"]
    if len(data) != archive["bytes"] or digest(data) != archive["sha256"]:
        raise ValueError("Baseline archive checksum differs")
    expected = {row["path"]: row for row in manifest["files"]}
    if len(expected) != len(manifest["files"]) or set(expected) != PATHS:
        raise ValueError("Baseline must contain the eleven specified files")
    for name, row in expected.items():
        mode = 0o755 if name in ("doitall.sh", "mfclo64") else 0o644
        if row["mode"] != mode or type(row["bytes"]) is not int or not 0 < row["bytes"] <= 40 * 1024 * 1024:
            raise ValueError("Invalid baseline file mode or size")
    result = {}
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
        for member in archive:
            if member.name not in expected or member.name in result:
                raise ValueError("Unexpected or duplicate baseline member")
            row = expected[member.name]
            if not member.isfile() or member.pax_headers or member.linkname:
                raise ValueError("Baseline members must be plain regular files")
            if member.size != row["bytes"] or member.mode != row["mode"]:
                raise ValueError("Baseline member size or mode differs")
            with archive.extractfile(member) as stream:
                contents = stream.read()
            if len(contents) != row["bytes"] or digest(contents) != row["sha256"]:
                raise ValueError("Baseline member checksum differs: " + member.name)
            result[member.name] = contents
    if set(result) != PATHS:
        raise ValueError("Missing baseline members")
    return result


def output_path(value):
    if (not value or not value.startswith("/") or value == "/" or "//" in value
            or "\n" in value or "\r" in value
            or any(part in ("", ".", "..") for part in value.split("/")[1:])):
        raise ValueError("INPUT must be a clean absolute path to a new directory")
    path = Path(value)
    if path == REPO or REPO in path.parents or path in REPO.parents:
        raise ValueError("INPUT must be outside the repository")
    if os.path.lexists(path):
        raise ValueError("Existing INPUT refused")
    return path


@contextlib.contextmanager
def existing_parent(path):
    flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
    held = [os.open(path.anchor, flags)]
    links = []
    try:
        for name in path.parts[1:]:
            child = os.open(name, flags, dir_fd=held[-1])
            links.append((held[-1], name, child))
            held.append(child)

        def stable():
            for parent, name, child in links:
                named = os.stat(name, dir_fd=parent, follow_symlinks=False)
                if not stat.S_ISDIR(named.st_mode) or identity(named) != identity(os.fstat(child)):
                    raise ValueError("INPUT parent changed")

        stable()
        yield held[-1], stable
    finally:
        for fd in reversed(held):
            os.close(fd)


def prepare(output, files, manifest):
    # All source members are verified before the first destination is created.
    modes = {row["path"]: row["mode"] for row in manifest["files"]}
    with existing_parent(output.parent) as (parent, parent_stable):
        os.mkdir(output.name, 0o700, dir_fd=parent)
        root = os.open(output.name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=parent)
        dirs = {"": root}
        links, held = [], []
        expected_entries = {"": set()}

        def stable():
            parent_stable()
            named = os.stat(output.name, dir_fd=parent, follow_symlinks=False)
            if not stat.S_ISDIR(named.st_mode) or identity(named) != identity(os.fstat(root)):
                raise ValueError("INPUT directory changed")
            for ancestor, name, fd in links:
                named = os.stat(name, dir_fd=ancestor, follow_symlinks=False)
                if not stat.S_ISDIR(named.st_mode) or identity(named) != identity(os.fstat(fd)):
                    raise ValueError("Baseline directory changed")
            for name, fd in dirs.items():
                if set(os.listdir(fd)) != expected_entries[name]:
                    raise ValueError("Unexpected baseline directory entry")
            for directory, name, fd, data, mode in held:
                observed = os.fstat(fd)
                named = os.stat(name, dir_fd=directory, follow_symlinks=False)
                if (not stat.S_ISREG(named.st_mode) or identity(named) != identity(observed)
                        or observed.st_nlink != 1 or stat.S_IMODE(observed.st_mode) != mode
                        or read_fd(fd) != data):
                    raise ValueError("Prepared baseline file changed")

        try:
            stable()
            for name, data in sorted(files.items()):
                parts = name.split("/")
                directory = root
                relative = ""
                for component in parts[:-1]:
                    child_relative = relative + ("/" if relative else "") + component
                    if child_relative not in dirs:
                        stable()
                        os.mkdir(component, 0o700, dir_fd=directory)
                        expected_entries[relative].add(component)
                        child = os.open(component, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=directory)
                        dirs[child_relative] = child
                        links.append((directory, component, child))
                        expected_entries[child_relative] = set()
                    directory, relative = dirs[child_relative], child_relative
                stable()
                fd = os.open(parts[-1], os.O_RDWR | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=directory)
                held.append((directory, parts[-1], fd, data, modes[name]))
                expected_entries[relative].add(parts[-1])
                remaining = memoryview(data)
                while remaining:
                    count = os.write(fd, remaining)
                    if not count:
                        raise OSError("Incomplete baseline write")
                    remaining = remaining[count:]
                os.fchmod(fd, modes[name])
                os.fsync(fd)
                stable()
            stable()
        finally:
            # On failure, leave only the new partial directory for inspection.
            for _, _, fd, _, _ in held:
                os.close(fd)
            for fd in reversed(list(dirs.values())):
                os.close(fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    choice = parser.add_mutually_exclusive_group(required=True)
    choice.add_argument("--verify", action="store_true")
    choice.add_argument("--output", help="new INPUT directory; existing parent required")
    choice.add_argument("--prepare", action="store_true", help="use INPUT exported by Make")
    args = parser.parse_args()
    value = os.environ.get("BET_RETRO_BASELINE_INPUT", "") if args.prepare else args.output
    output = output_path(value) if args.prepare or args.output is not None else None
    with frozen_bytes(HERE / "refit-baseline.json") as data:
        manifest = json.loads(data)
        with frozen_bytes(HERE / "refit-baseline.tar.gz") as archive:
            files = checked_archive(archive, manifest)
            if output is not None:
                prepare(output, files, manifest)
                print("Prepared eleven full-refit baseline files in", output)
            else:
                print("Verified eleven pinned full-refit baseline files.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError) as error:
        raise SystemExit(str(error))
