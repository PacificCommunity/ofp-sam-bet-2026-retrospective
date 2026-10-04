# Saved retrospective PARs

[Download the PAR archive](https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-retrospective/main/reproduce/native.tar.gz). It is included in a normal clone.

`native.tar.gz` preserves the seven original peel PARs, recovered losslessly
from the archived model payload. Their native bytes, permissions and checksums
are recorded in `files.json`.

```sh
make verify
```

To extract only the seven saved PARs into a new directory:

```sh
mkdir /tmp/bet-retro-pars
tar -xzf reproduce/native.tar.gz -C /tmp/bet-retro-pars
```

The verification command checks the saved PAR archive without executing MFCL. The generated
FRQ, INI and TAG files for the seven peels are still missing. The restoration
helper refuses native reruns until those matching input sets are recovered or
independently regenerated and checked. A shared Diagnostic input cannot replace
peel-specific data.

The existing report and cached results remain readable and reproducible using
`make results`. Those results do not close the missing native inputs. Do not
remove the original retrospective source files on the basis of this archive.

For new full refits with the pinned private package, see the [mfclkit guide](mfclkit.md).
