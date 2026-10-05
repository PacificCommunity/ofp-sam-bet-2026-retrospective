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

`refit-baseline.tar.gz` (11 MB) contains the original common inputs, recovered
`00.fixed.par`, source configuration and pinned F5 engine for new full refits.
It does not contain the missing historical peel-specific inputs.

```sh
make prepare INPUT=/absolute/new-baseline
```

`INPUT` must be absent, outside the checkout, with an existing parent directory.
`make verify` checks both archives and their member hashes. For the pinned private
package requirements and full-refit commands, see the [mfclkit guide](mfclkit.md).
