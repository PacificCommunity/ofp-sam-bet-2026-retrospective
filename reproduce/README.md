# Saved retrospective PARs

`native.tar.gz` preserves the seven original peel PARs, recovered losslessly
from the archived model payload. Their native bytes, permissions and checksums
are recorded in `files.json`.

```sh
python3 reproduce/restore.py --verify
```

This verifies the saved PAR archive without executing MFCL. The generated
FRQ, INI and TAG files for the seven peels are still missing. The restoration
helper refuses native reruns until those matching input sets are recovered or
independently regenerated and checked. A shared Diagnostic input cannot replace
peel-specific data.

The existing report and cached results remain readable and reproducible using
`./run-report`. Those results do not close the missing native inputs. Do not
remove the original retrospective source files on the basis of this archive.
