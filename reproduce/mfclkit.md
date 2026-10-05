# Retrospective reproduction

From the repository root, `make verify` checks the preserved files and seven
saved PARs. `make results` rebuilds the saved report, and `make help` lists the
entry points. These commands do not refit the peels.

The seven original final PARs are retained, but their matching peeled input
sets are incomplete. `make rerun` therefore stops. See the
[saved-file status](README.md).

## Full refits with mfclkit

Use R on Linux x86-64 with `sha256sum`, the pinned MFCL engine, and authorised
access to the private packages or their exact installed source revisions:

| Package | Source revision |
| --- | --- |
| mfclkit | `c8d80c7d915441dff16dca101be6f452d0fb3482` (0.0.0.9040) |
| FLR4MFCL | `ff8367fcec19baff98333170c0f1bca3f9903029` (1.7.2) |
| mfclshiny | `542ac93b7ce0b6d0df70301891e668701d439857` |

These are the original native-fit revisions; the saved-report runtime uses
other pinned revisions. The wrapper checks installed `RemoteSha` values.
It does not install packages, obtain credentials or submit jobs.

The 11 MB `refit-baseline.tar.gz` includes the original common inputs from the pinned
[Diagnostic model](https://github.com/PacificCommunity/ofp-sam-bet-2026-diagnostic/tree/3abf0c64fb9b0c2d70b9c672dc7d9a655d3060d6/model):
`bet.frq`, `bet.ini`, `bet.tag`, `bet.age_length`, `bet.reg_scaling`, `mfcl.cfg`,
`doitall.sh`, `model-inputs/S0.90-F2.conf`, and `selectivity-models/F2.csv`.
It also contains the recovered original prepared `00.fixed.par`
(MD5 `01c9056f7268fb643cfc77382980ace0`) and the published
[F5 engine](https://github.com/PacificCommunity/ofp-sam-bet-2026-jitter/blob/bb3f4016b2d145f42c7a76072ed2b10b49aff71f/data/diagnostic/mfcl/mfclo64)
(SHA256 `f5bc1e232a86e51f920bce7271d8e0930d0b160e4d18dc46de44078f0fa24cd0`).

Prepare a fresh directory, then inspect or run the full-refit recipe:

```sh
make prepare INPUT=/absolute/bet-baseline
make refit-plan INPUT=/absolute/bet-baseline OUT=/absolute/new-retro MFCL=/absolute/bet-baseline/mfclo64
make refit INPUT=/absolute/bet-baseline OUT=/absolute/new-retro MFCL=/absolute/bet-baseline/mfclo64
```

`prepare` verifies and extracts the eleven files without running MFCL. `INPUT`
must be absent, outside the checkout, with an existing parent and no symlink
ancestors. `refit-plan` only prints the recipe; it does not validate readiness.
`refit` creates a fresh `OUT` outside the repository and
copies the baseline there; it checks original files before and after.
The parent folder of `OUT` must exist. Leave `OUT` absent until `refit` creates it.

The wrapper calls the pinned `mfk_run_retro()` and its `mfk_apply_retro_peel()`
for peels 1–7: INI version 1007, two mixing periods, `model_phase_start` from
`00.fixed.par`, unchanged start-PAR bytes, `doitall` refits, final convergence
exponent −4, and fixed tag overdispersion τ=2. Automatic fallback and Hessian
calculation are disabled. To select a peel, add `RETRO_PEELS=1`; ranges and
comma-separated peel numbers are also accepted. Peels run serially.

The original checks-repository compact-output pruning is omitted, retaining
new native inputs, final PARs and logs under `OUT`. This is a retention-only
change. Historical peeled inputs are still missing, and no new full refits have
been executed or checked. Exact regenerated input identity and native acceptance
of this wrapper remain unverified; the historical Retro execution engine hash
also remains unknown. The archive supplies the F5 engine pinned by this wrapper.
