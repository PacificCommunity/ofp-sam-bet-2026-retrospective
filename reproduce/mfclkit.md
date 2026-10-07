# Retrospective reproduction

[View the 2026 results](https://pacificcommunity.github.io/ofp-sam-bet-2026-retrospective/retrospective-report.html).
The saved results cover seven peels ending in 2017–2023, against the full-data
fit ending in 2024. [Figures, tables and saved R objects](../docs/reproduction.md)
are included in the repository.

From the repository root:

```sh
make verify
make results
```

`make results` rebuilds the report from saved model objects. `make help`
lists the commands. The [saved-file guide](README.md) describes the native
archives and the missing historical peel inputs.

## Full refits with mfclkit

Use R on Linux x86-64 with `sha256sum` and the exact installed packages below.
Source installation requires authorised access to the private repositories.
The wrapper checks each package's `RemoteSha`; these native-fit revisions
differ from the saved-report runtime.

| Package | Source revision |
| --- | --- |
| [mfclkit](https://github.com/PacificCommunity/ofp-sam-mfclkit/commit/c8d80c7d915441dff16dca101be6f452d0fb3482) | `c8d80c7d915441dff16dca101be6f452d0fb3482` (0.0.0.9040) |
| [FLR4MFCL](https://github.com/PacificCommunity/ofp-sam-flr4mfcl/commit/ff8367fcec19baff98333170c0f1bca3f9903029) | `ff8367fcec19baff98333170c0f1bca3f9903029` (1.7.2) |
| [mfclshiny](https://github.com/PacificCommunity/mfclshiny/commit/542ac93b7ce0b6d0df70301891e668701d439857) | `542ac93b7ce0b6d0df70301891e668701d439857` |

The 11 MB `refit-baseline.tar.gz` contains the recovered `00.fixed.par`,
original common inputs, `doitall.sh`, source configuration and F5 engine.
It uses the pinned
[Diagnostic inputs](https://github.com/PacificCommunity/ofp-sam-bet-2026-diagnostic/tree/3abf0c64fb9b0c2d70b9c672dc7d9a655d3060d6/model)
and [published F5 engine](https://github.com/PacificCommunity/ofp-sam-bet-2026-jitter/blob/bb3f4016b2d145f42c7a76072ed2b10b49aff71f/data/diagnostic/mfcl/mfclo64).
Their file hashes are recorded in [the baseline manifest](refit-baseline.json).

```sh
make prepare INPUT=/absolute/bet-baseline
make refit-plan INPUT=/absolute/bet-baseline OUT=/absolute/new-retro
make refit INPUT=/absolute/bet-baseline OUT=/absolute/new-retro
```

`prepare` verifies and extracts the eleven files with base R, without running
MFCL. `make baseline-list` lists them; `MFCL` defaults to `INPUT/mfclo64`.
Verification needs `sha256sum` (or `shasum`), with no Python.
Leave `INPUT` absent until `prepare` creates it and `OUT` absent until `refit`
creates it. Use absolute paths outside the checkout, with existing parents.
`refit-plan` prints the recipe only; it does not check execution readiness.
Run outside an inherited Condor job.

The wrapper calls `mfk_run_retro()` and `mfk_apply_retro_peel()` for peels 1–7:
INI version 1007, two mixing periods, the original `00.fixed.par` start,
`doitall` refits, final convergence exponent −4 and fixed tag overdispersion
τ=2. Fallback and Hessian calculation are disabled. Add `RETRO_PEELS=1` for
one peel. Runs are serial; new inputs, final PARs, logs and
`new-retro-runs.rds` remain under `OUT`.

The seven original final PARs are preserved, but their matching peeled inputs
remain incomplete, so `make rerun` stops. These full refits have not been run
or compared with the 2026 results. Exact regenerated input identity and the
historical Retro engine hash remain unverified.
