# Saved retrospective PARs

Both archives are included in a normal clone.

| Archive | Contents |
| --- | --- |
| [native.tar.gz](https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-retrospective/main/reproduce/native.tar.gz) (371 kB) | Seven original final PARs, one per peel |
| [refit-baseline.tar.gz](https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-retrospective/main/reproduce/refit-baseline.tar.gz) (11 MB) | Original common inputs, `00.fixed.par`, `doitall.sh`, source configuration and pinned F5 engine |

Run from the repository root:

```sh
make verify
make prepare INPUT=/absolute/new-baseline
```

`verify` checks both archives and their member hashes. `prepare` extracts the
baseline without running MFCL. `INPUT` must be absent, outside the checkout,
with an existing parent and no symlink ancestors.

To extract only the seven saved final PARs:

```sh
mkdir /tmp/bet-retro-pars
tar -xzf reproduce/native.tar.gz -C /tmp/bet-retro-pars
```

The original PAR bytes, permissions and checksums are recorded in
[files.json](files.json). Their generated FRQ, INI and TAG sets remain missing,
so `make rerun` stops. A common Diagnostic input cannot replace peeled data.

The [2026 results](https://pacificcommunity.github.io/ofp-sam-bet-2026-retrospective/retrospective-report.html)
remain available; `make results` rebuilds their report from the cached payload.
For new full refits and the required packages, see the [mfclkit guide](mfclkit.md).
