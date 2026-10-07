# Saved retrospective PARs

All three archives are included in a normal clone.

| Archive | Contents |
| --- | --- |
| [native.tar.gz](https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-retrospective/main/reproduce/native.tar.gz) (371 kB) | Seven original final PARs, one per peel |
| [saved-results.tar.gz](saved-results.tar.gz) (7.9 MB) | Seven original `retro_info.rds` files, including losslessly stored PAR and REP bytes |
| [refit-baseline.tar.gz](https://raw.githubusercontent.com/PacificCommunity/ofp-sam-bet-2026-retrospective/main/reproduce/refit-baseline.tar.gz) (11 MB) | Original common inputs, `00.fixed.par`, `doitall.sh`, source configuration and pinned F5 engine |

Run from the repository root:

```sh
make verify
make prepare INPUT=/absolute/new-baseline
```

`verify` checks all three archives and their member hashes. `prepare` extracts the
baseline without running MFCL. `INPUT` must be absent, outside the checkout,
with an existing parent and no symlink ancestors.

Extract the seven final PARs or the detailed original RDS into new folders:

```sh
make saved-pars OUT=/absolute/new-retro-pars
make extract OUT=/absolute/new-retro-results
```

Both commands verify every member before extraction. They use base R and
`sha256sum` (or `shasum`), without Python. `make list` lists the saved peels.

The original PAR bytes, permissions and checksums are recorded in
[files.json](files.json). Their generated FRQ, INI and TAG sets remain missing,
so `make rerun` stops. A common Diagnostic input cannot replace peeled data.

The [2026 results](https://pacificcommunity.github.io/ofp-sam-bet-2026-retrospective/retrospective-report.html)
remain available; `make results` rebuilds their report from the cached payload.
For new full refits and the required packages, see the [mfclkit guide](mfclkit.md).

For the detailed original RDS, use `make extract` above and read `peel_1/retro_info.rds` through `peel_7/retro_info.rds`
with `readRDS()`. Member checksums are in [saved-results.json](saved-results.json).
The archived REP bytes preserve the original reports; matching peeled inputs
are still needed for native reruns.
