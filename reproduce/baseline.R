# Restore the original common baseline for new refits; never run MFCL.
script <- grep("^--file=", commandArgs(), value = TRUE)
stopifnot(length(script) == 1L)
source(file.path(dirname(normalizePath(sub("^--file=", "", script))), "verify.R"))
root <- reader_root()
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) args <- "--verify"
assert(args[[1L]] %in% c("--verify", "--list", "--prepare"), "Use make baseline-list, verify or prepare INPUT=/absolute/new-folder.")
prepare <- args[[1L]] == "--prepare"
assert(length(args) == if (prepare) 2L else 1L, "Expected one new INPUT path for preparation.")
if (prepare) fresh_output(args[[2L]], root)
manifest <- read_json(file.path(root, "reproduce", "refit-baseline.json"))
expected <- c("00.fixed.par", "bet.age_length", "bet.frq", "bet.ini", "bet.reg_scaling", "bet.tag", "doitall.sh", "mfcl.cfg", "mfclo64", "model-inputs/S0.90-F2.conf", "selectivity-models/F2.csv")
assert(identical(manifest$archive$path, "refit-baseline.tar.gz") &&
  identical(vapply(manifest$files, function(r) r$path, character(1L)), expected), "Baseline must contain the eleven specified files.")
for (row in manifest$files) assert(row$mode == if (row$path %in% c("doitall.sh", "mfclo64")) 493 else 420, "Baseline file mode differs.")
bundle <- checked_tar(root, manifest, keep = prepare)
if (prepare) {
  write_members(args[[2L]], bundle, root)
  cat("Prepared eleven original full-refit baseline files in", args[[2L]], "; no model executed.\n")
} else if (args[[1L]] == "--list") {
  cat(paste(expected, collapse = "\n"), "\n", sep = "")
} else cat("Verified eleven original full-refit baseline files; no model executed.\n")
