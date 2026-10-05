[![Preservation checks](https://github.com/PacificCommunity/ofp-sam-bet-2026-retrospective/actions/workflows/verify-preserved-results.yml/badge.svg?branch=main)](https://github.com/PacificCommunity/ofp-sam-bet-2026-retrospective/actions/workflows/verify-preserved-results.yml?query=branch%3Amain)

# BET 2026 Diagnostic model retrospective

[View results](https://pacificcommunity.github.io/ofp-sam-bet-2026-retrospective/retrospective-report.html).

This repository contains the saved results for the seven-peel retrospective
analysis of the BET 2026 Diagnostic model. The peels end in 2017–2023;
the full-data fit ends in 2024.

## Render

From the repository root:

```sh
make verify
make results
```

The runner checks payload hashes, then writes a self-contained HTML report,
PNG/PDF figures and LaTeX tables to `results/`. Rendering uses completed
model outputs and does not refit the peels.

The seven original peel PARs are retained, but their matching peeled input
sets are incomplete, so saved-PAR native reruns remain unavailable. See
[native-file status](reproduce/README.md). The [mfclkit guide](reproduce/mfclkit.md)
provides `make prepare`, `make refit-plan` and `make refit` for new full refits.
The compact baseline includes the recovered original `00.fixed.par` and pinned
MFCL engine; private mfclkit package access is still required.
`make help` lists the commands; [runtime instructions](docs/reproduction.md)
cover the saved report.
