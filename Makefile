.PHONY: all

all:
	./run-report

# Saved results and new full refits are separate operations.
INPUT ?=
OUT ?=
MFCL ?= $(if $(strip $(INPUT)),$(INPUT)/mfclo64,)
RETRO_PEELS ?= 1:7

.PHONY: help verify results list extract saved-pars rerun refit-plan refit

help:
	@printf '%s\n' 'make verify       Check the preserved source and saved files with R.' 'make results      Rebuild the report from saved results.' 'make list         List the seven saved peel folders.' 'make extract OUT=/absolute/new-results' 'make saved-pars OUT=/absolute/new-pars' 'make rerun        Explain the missing saved native closure.' 'make refit-plan   Show the pinned full-refit recipe without executing it.' 'make refit INPUT=/absolute/baseline OUT=/absolute/fresh' 'MFCL defaults to INPUT/mfclo64. See reproduce/mfclkit.md for packages and RETRO_PEELS.'

verify:
	Rscript --vanilla reproduce/verify.R --verify
	Rscript --vanilla reproduce/verify.R --pars-list

list:
	Rscript --vanilla reproduce/verify.R --list

extract:
	Rscript --vanilla reproduce/verify.R --extract "$(OUT)"

saved-pars:
	Rscript --vanilla reproduce/verify.R --pars "$(OUT)"

results: all

rerun:
	@printf '%s\n' 'Saved-PAR native reruns need the matching peeled input files; the seven saved PARs alone are insufficient.' 'Use make results for the saved report, or read reproduce/mfclkit.md for new full refits.' >&2
	@exit 2

refit-plan:
	RETRO_PEELS="$(RETRO_PEELS)" Rscript --vanilla reproduce/refit.R --plan --input "$(INPUT)" --out "$(OUT)" --mfcl "$(MFCL)"

refit:
	RETRO_PEELS="$(RETRO_PEELS)" Rscript --vanilla reproduce/refit.R --run --input "$(INPUT)" --out "$(OUT)" --mfcl "$(MFCL)"

.PHONY: prepare baseline-list _verify-refit-baseline _help-refit-baseline

verify: _verify-refit-baseline
help: _help-refit-baseline

_verify-refit-baseline:
	Rscript --vanilla reproduce/baseline.R --verify

_help-refit-baseline:
	@printf '%s\n' 'make prepare INPUT=/absolute/new-baseline   Extract the pinned full-refit inputs and MFCL engine.'

prepare:
	Rscript --vanilla reproduce/baseline.R --prepare "$(INPUT)"

baseline-list:
	Rscript --vanilla reproduce/baseline.R --list
