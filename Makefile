.PHONY: all

all:
	./run-report

# Saved results and new full refits are separate operations.
INPUT ?=
OUT ?=
MFCL ?=
RETRO_PEELS ?= 1:7

.PHONY: help verify results rerun refit-plan refit

help:
	@printf '%s\n' 'make verify       Check the preserved source and saved files.' 'make results      Rebuild the report from saved results.' 'make rerun        Explain the missing saved native closure.' 'make refit-plan   Show the pinned full-refit recipe without executing it.' 'make refit INPUT=/absolute/baseline OUT=/absolute/fresh MFCL=/absolute/mfclo64' 'See reproduce/mfclkit.md for prerequisites and RETRO_PEELS selection.'

verify:
	python3 ci/verify-preserved-files.py
	python3 reproduce/restore.py --verify

results: all

rerun:
	@printf '%s\n' 'Saved-PAR native reruns need the matching peeled input files; the seven saved PARs alone are insufficient.' 'Use make results for the saved report, or read reproduce/mfclkit.md for new full refits.' >&2
	@exit 2

refit-plan:
	RETRO_PEELS="$(RETRO_PEELS)" Rscript --vanilla reproduce/refit.R --plan --input "$(INPUT)" --out "$(OUT)" --mfcl "$(MFCL)"

refit:
	RETRO_PEELS="$(RETRO_PEELS)" Rscript --vanilla reproduce/refit.R --run --input "$(INPUT)" --out "$(OUT)" --mfcl "$(MFCL)"

.PHONY: prepare _verify-refit-baseline _help-refit-baseline

verify: _verify-refit-baseline
help: _help-refit-baseline

_verify-refit-baseline:
	python3 reproduce/baseline.py --verify

_help-refit-baseline:
	@printf '%s\n' 'make prepare INPUT=/absolute/new-baseline   Extract the pinned full-refit inputs and MFCL engine.'

prepare: export BET_RETRO_BASELINE_INPUT = $(INPUT)
prepare:
	python3 reproduce/baseline.py --prepare
