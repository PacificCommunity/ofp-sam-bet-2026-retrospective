# Full refits are opt-in. --plan prints the recipe without loading model data.
fail <- function(text) stop(text, call. = FALSE)
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) || !args[[1L]] %in% c("--plan", "--run")) {
  fail("Use make refit-plan or make refit with INPUT, MFCL and a fresh absolute OUT.")
}
action <- args[[1L]]
args <- args[-1L]
if (length(args) != 6L || !identical(args[c(1L, 3L, 5L)], c("--input", "--out", "--mfcl"))) {
  fail("Expected --input PATH --out PATH --mfcl PATH.")
}
input <- args[[2L]]
out <- args[[4L]]
program <- args[[6L]]
selection <- Sys.getenv("RETRO_PEELS", "1:7")
if (grepl("^[0-9]+:[0-9]+$", selection)) {
  limits <- as.integer(strsplit(selection, ":", fixed = TRUE)[[1L]])
  if (anyNA(limits) || any(limits < 1L) || any(limits > 7L) || limits[1L] > limits[2L]) fail("Invalid case range.")
  cases <- seq.int(limits[1L], limits[2L])
} else {
  if (!grepl("^[0-9]+([,[:space:]]+[0-9]+)*$", selection)) fail("Cases must be a range or comma/space-separated integers.")
  cases <- as.integer(strsplit(selection, "[,[:space:]]+")[[1L]])
  if (anyNA(cases) || any(cases < 1L) || any(cases > 7L) || anyDuplicated(cases)) fail("Invalid or duplicate cases.")
}
cat("Retrospective full refit; cases:", paste(cases, collapse = " "), "\n")
cat("mfclkit c8d80c7d915441dff16dca101be6f452d0fb3482; FLR4MFCL ff8367fcec19baff98333170c0f1bca3f9903029\n")
cat("mfclshiny 542ac93b7ce0b6d0df70301891e668701d439857\n")
cat("Peels 1:7; INI 1007; mixing periods 2; model_phase_start 00.fixed.par; doitall refits; final convergence -4; tau=2.\n")
cat("INPUT:", input, "\nOUT:", out, "\nMFCL:", program, "\n")
cat("Requires the pinned installed packages and complete baseline files described in reproduce/mfclkit.md.\n")
cat("Native inputs, final PARs and logs will be retained. Historical output equality is unverified.\n")
if (identical(action, "--plan")) quit(status = 0L)

if (!identical(Sys.info()[["sysname"]], "Linux") || !Sys.info()[["machine"]] %in% c("x86_64", "amd64")) fail("The pinned MFCL engine requires Linux x86-64.")
condor <- Sys.getenv(c("_CONDOR_JOB_AD", "_CONDOR_SCRATCH_DIR", "CONDOR_ID"), unset = "")
if (any(nzchar(condor))) fail("Run outside an inherited Condor job: the historical self-test runner includes archive cleanup.")

# Metadata checks do not install packages or forward credentials.
package_pin <- function(name, sha) {
  info <- utils::packageDescription(name)
  if (!is.list(info) || is.null(info$RemoteSha) || !identical(info$RemoteSha, sha)) fail(paste("Install the exact source revision of", name, sha, "with authorised access."))
}
package_pin("mfclkit", "c8d80c7d915441dff16dca101be6f452d0fb3482")
package_pin("FLR4MFCL", "ff8367fcec19baff98333170c0f1bca3f9903029")
package_pin("mfclshiny", "542ac93b7ce0b6d0df70301891e668701d439857")

absolute_clean <- function(path) {
  if (!nzchar(path) || identical(path, "/") || !startsWith(path, "/") || grepl("//", path, fixed = TRUE) || grepl("[\r\n]", path) || any(strsplit(path, "/", fixed = TRUE)[[1L]] %in% c(".", ".."))) fail("INPUT, OUT and MFCL must be clean absolute paths.")
  path <- sub("/+$", "", path)
  chain <- path
  while (nzchar(chain) && !identical(chain, "/")) {
    link <- Sys.readlink(chain)
    if (!is.na(link) && nzchar(link)) fail(paste("Symbolic link in path:", chain))
    chain <- dirname(chain)
  }
  path
}
input <- absolute_clean(input)
out <- absolute_clean(out)
program <- absolute_clean(program)
if (!dir.exists(input)) fail("INPUT must be an existing prepared baseline directory.")
if (file.exists(out) || dir.exists(out)) fail("OUT must not exist; use a fresh folder.")
if (!dir.exists(dirname(out))) fail("The parent of OUT must already exist.")
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
if (length(script_arg) != 1L) fail("Cannot resolve wrapper source path.")
repo <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE)))
inside <- function(path, root) identical(path, root) || startsWith(path, paste0(root, "/"))
if (inside(out, repo) || inside(out, input)) fail("OUT must be outside the repository and INPUT.")
regular <- function(path) {
  info <- file.info(path)
  link <- Sys.readlink(path)
  if (!file_test("-f", path) || is.na(info$size) || isTRUE(info$isdir) || (!is.na(link) && nzchar(link))) fail(paste("Missing regular source file:", path))
}
checksum_program <- Sys.which("sha256sum")
if (!nzchar(checksum_program)) fail("sha256sum is required to check the pinned source files.")
sha256 <- function(path) {
  regular(path)
  lines <- system2(checksum_program, shQuote(path), stdout = TRUE, stderr = TRUE)
  status <- attr(lines, "status")
  if ((!is.null(status) && status != 0L) || length(lines) != 1L) fail("SHA256 command failed.")
  value <- strsplit(lines[[1L]], "[[:space:]]+")[[1L]][[1L]]
  if (!grepl("^[0-9a-f]{64}$", value)) fail("Invalid SHA256 result.")
  value
}
pins <- data.frame(
  path = c("bet.frq", "bet.ini", "bet.tag", "bet.age_length", "bet.reg_scaling", "mfcl.cfg", "doitall.sh", "model-inputs/S0.90-F2.conf", "selectivity-models/F2.csv"),
  bytes = c(2932052, 66790, 110051, 1403841, 1186, 31, 40697, 98, 825),
  sha256 = c("d0d84f0a498e6a62681f2a58ffc1ba53dab9e3d6af856b4ad1fd907196250004", "5292938d4743c1dfdd2f1a095c1aa87482c9c17f78b8d879671fe6851d58646f", "b140e66eb52f2b7e022ef2c562134f8bc9baf3dede18ce95283a001acd2b013f", "426859b825bd815aa69c8d97c9dd93097027ed1eb6b9e444d88b69562097a00c", "5f047ddb4053d1f6df9ace18e85e440b11553de246d024ce8138b427f5f9f7e3", "2ec8a291fae62c6f37541aec1de37444626d42b3290b371bb42b63d510034eae", "5c53802daf44e700ee91aa8108f0b2289473c0344d7feecf04cab458dc49ca77", "ce2c1dbf67d9eecb3ceaeda81ac9124cb7dbe81f42181f6abfb8f246b4f3a048", "790e21a01054349a20f4fbbb7db926f6452d059344815a3a9d6a5de51db3310a"),
  stringsAsFactors = FALSE
)
paths <- file.path(input, pins$path)
for (i in seq_len(nrow(pins))) {
  regular(paths[[i]])
  if (file.info(paths[[i]])$size != pins$bytes[[i]] || !identical(sha256(paths[[i]]), pins$sha256[[i]])) fail(paste("Baseline source pin differs:", pins$path[[i]]))
}
regular(file.path(input, "00.fixed.par"))
if (!identical(unname(tools::md5sum(file.path(input, "00.fixed.par"))), "01c9056f7268fb643cfc77382980ace0")) fail("The original prepared 00.fixed.par is required; no automatic initialization fallback.")
regular(program)
if (file.access(program, 1L) != 0L || file.info(program)$size != 34549392 || !identical(sha256(program), "f5bc1e232a86e51f920bce7271d8e0930d0b160e4d18dc46de44078f0fa24cd0")) fail("MFCL must be the pinned F5 engine (34,549,392 bytes).")
source_paths <- c(paths, file.path(input, "00.fixed.par"), program)
bindings <- function() data.frame(path = source_paths, bytes = file.info(source_paths)$size, sha256 = vapply(source_paths, sha256, character(1L)), stringsAsFactors = FALSE)
before <- bindings()
if (!dir.create(out, mode = "0700")) fail("Could not create fresh OUT.")
utils::write.csv(before, file.path(out, "source-bindings.before.csv"), row.names = FALSE)
run_refit <- function() {
  on.exit({
    after <- bindings()
    utils::write.csv(after, file.path(out, "source-bindings.after.csv"), row.names = FALSE)
    if (!identical(before, after)) fail("Original INPUT or engine changed during the refit.")
  }, add = TRUE)
  staged <- file.path(out, "inputs")
  if (!dir.create(staged)) fail("Could not create input copy.")
  relative <- c(pins$path, "00.fixed.par")
  for (name in relative) {
    target <- file.path(staged, name)
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    if (!file.copy(file.path(input, name), target, overwrite = FALSE, copy.mode = TRUE)) fail(paste("Could not copy:", name))
    if (!identical(sha256(file.path(input, name)), sha256(target))) fail("Staged file differs.")
  }
  Sys.chmod(file.path(staged, "doitall.sh"), "0755")
  # The original template carries tau=2. Package functions prepare only copies.
  Sys.unsetenv(c("MODEL_STOP_AFTER_PHASE0", "BET_PHASE10_11_CONVERGENCE", "SELECTIVITY_PRINT_CONTROLS", "SELECTIVITY_AUDIT_PAR", "REGIONAL_RECRUITMENT_PENALTY"))
  Sys.setenv(MODEL_ID = "S0.90-F2", PROGRAM_PATH = program)
  backend <- mfclkit::mfk_native_backend(program_path = program)
  capture.output(sessionInfo(), file = file.path(out, "session-info.txt"))
  result <- lapply(cases, function(peel) {
    info <- mfclkit::mfk_run_retro(
      backend = backend, input_dir = staged, model_dir = file.path(out, "models"),
      peel = peel, par = file.path(staged, "00.fixed.par"),
      start_par_name = "00.fixed.par", start_strategy = "model_phase_start",
      n_mixing_periods = 2L, convergence_exponent = -4L, hessian = FALSE,
      doitall_fallback = FALSE, allow_new_ini_version_write = FALSE,
      remove_par_files = TRUE, rewrite_par = FALSE, makepar_start = FALSE,
      parallel = FALSE, run_messages = TRUE
    )
    # Do not invoke the original checks-repository compact-output pruning.
    if (!isTRUE(info$run_completed) || !isTRUE(info$converged)) fail(paste("Peel did not complete and converge:", peel, "Inspect the retained native files."))
    info
  })
  saveRDS(result, file.path(out, "new-retro-runs.rds"), compress = "xz")
}
run_refit()
cat("New fit files retained under", out, "; compare them with the original receipts before claiming historical reproduction.\n")
