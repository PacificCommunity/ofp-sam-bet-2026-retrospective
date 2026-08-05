# BET 2026 Diagnostic model retrospective

This public repository contains the compact, report-ready payload needed to
recreate the seven-peel retrospective report for the BET 2026 Diagnostic
model. It uses the completed model and retrospective outputs; it does not run
MFCL or refit any peel.

The payload contains the fitted Diagnostic model and the seven retrospective
peels ending in 2017--2023, with the full-data fit ending in 2024. Original
MFCL inputs, executables, raw logs, private paths, credentials, and Kflow
working files are excluded.

## Render

Install `mfclshiny` with the public retrospective-report API, then run:

```sh
./run-report
```

The runner verifies the payload hashes before rendering a self-contained HTML
report, publication PNG/PDF figures, and LaTeX tables in `results/`.

The report uses exactly the same completed retrospective payload as Kflow Job
22619 and is intended for report generation on Kflow Local.
