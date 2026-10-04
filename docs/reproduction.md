# BET 2026 Diagnostic model retrospective — reproduction details


Saved native files, checksum verification and current restoration limits are
documented in [native-file instructions](../reproduce/README.md).

[Repository overview](../README.md). Run all commands below from the repository root.

This public repository contains the compact, report-ready payload needed to
recreate the seven-peel retrospective report for the BET 2026 Diagnostic
model. It uses the completed model and retrospective outputs; it does not run
MFCL or refit any peel.

The payload contains the fitted Diagnostic model and the seven retrospective
peels ending in 2017--2023, with the full-data fit ending in 2024. The report payload contains derived tables and model objects. The original
PAR archive in `reproduce/` is separate; its missing per-peel inputs are
listed there.

## Render

Run:

```sh
make results
```

The runner reuses the pinned report runtime when available and otherwise
installs the exact FLR4MFCL, mfclkit, and mfclshiny revisions used for
the report. Source installation of mfclkit and mfclshiny requires authorised
access to their private repositories.

The runner verifies the payload hashes before rendering a self-contained HTML
report, publication PNG/PDF figures, and LaTeX tables in `results/`.


## New full refits

See the concise [mfclkit guide](../reproduce/mfclkit.md) for `make refit-plan` and
`make refit`, their pinned native-fit package revisions, and the missing prepared
start PAR. A new refit is separate from rendering the saved report.
