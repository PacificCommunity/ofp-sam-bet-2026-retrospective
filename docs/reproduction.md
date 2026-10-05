# BET 2026 Diagnostic model retrospective — reproduction details

[View results](https://pacificcommunity.github.io/ofp-sam-bet-2026-retrospective/retrospective-report.html)
or return to the [repository overview](../README.md).

The seven peels end in 2017–2023; the full-data fit ends in 2024.
These saved results are ready to read without running MFCL.

| Results | Contents |
| --- | --- |
| [HTML report](../results/retrospective-report.html) | Methods, diagnostics and interpretation |
| [Trajectories](../results/figures/retrospective-diagnostics-diagnostic-model.png) | Retrospective estimates |
| [Recent management quantities](../results/figures/retrospective-recent-management-diagnostic-model.png) | Recent-period comparisons |
| [Tables](../results/tables/) | Peel diagnostics, Mohn's rho and recent endpoints, in LaTeX |
| [Saved R objects](../data/diagnostic/S0.90-F2-tau2-fixed/retro/) | `retro_info`, `retro_input_info` and `retro_metrics` for each peel |

The seven original final PARs and compact full-refit baseline are described in
the [native-file instructions](../reproduce/README.md).

## Render

Run from the repository root:

```sh
make results
```

The runner checks saved payload hashes and writes HTML, PNG/PDF figures and
LaTeX tables to `results/`, without refitting the model. The repository already
contains the HTML, five PNGs and fourteen tables; PDFs are produced by rendering.

The report runtime is listed in [run-report](../run-report). When its packages
are not already available, installation needs authorised access to the private
mfclkit and mfclshiny repositories.

## New full refits

The [mfclkit guide](../reproduce/mfclkit.md) explains `make prepare`,
`make refit-plan` and `make refit`. The compact baseline now includes the
original `00.fixed.par`. Matching historical peel-specific inputs remain
incomplete; new full refits have not been compared with the saved results.
