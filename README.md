# BET 2026 Diagnostic model retrospective

[View results](https://pacificcommunity.github.io/ofp-sam-bet-2026-retrospective/retrospective-report.html).

This repository contains the saved results for the seven-peel retrospective
analysis of the BET 2026 Diagnostic model. The peels end in 2017–2023;
the full-data fit ends in 2024.

## Render

From the repository root:

```sh
./run-report
```

The runner checks payload hashes, then writes a self-contained HTML report,
PNG/PDF figures and LaTeX tables to `results/`. Rendering uses completed
model outputs and does not refit the peels.

The seven exact peel PARs are retained in `reproduce/` and can be checked
with `python3 reproduce/restore.py --verify`. The matching peeled input sets
are incomplete, so the restoration helper currently refuses native reruns.
See [native-file status](reproduce/README.md) and
[runtime instructions](docs/reproduction.md). Installing the pinned private
report packages from source requires authorised access.
