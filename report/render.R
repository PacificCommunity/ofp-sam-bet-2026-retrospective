private_library <- Sys.getenv("BET_RETRO_R_LIB", ".R-library")
if (dir.exists(private_library)) {
  .libPaths(unique(c(normalizePath(private_library), .libPaths())))
}

required <- c("mfclshiny")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop(
    "Missing required report package(s): ", paste(missing, collapse = ", "),
    ". Install the pinned public runtime described in README.md.",
    call. = FALSE
  )
}

if (!exists("build_retrospective_report", envir = asNamespace("mfclshiny"), inherits = FALSE)) {
  stop("Installed mfclshiny does not provide build_retrospective_report().", call. = FALSE)
}

result <- mfclshiny::build_retrospective_report(
  model_dir = "data/diagnostic",
  output_dir = "results",
  title = "Diagnostic model retrospective | Job 21641",
  provenance = data.frame(
    model_job = 21641L,
    check_job = 22028L,
    model_label = "Diagnostic model",
    stringsAsFactors = FALSE
  ),
  formats = c("png", "pdf"),
  dpi = 300L,
  render_html = TRUE
)

message("Rendered retrospective report: ", result$html)
message("Diagnostic model retrospective peels: ", nrow(result$data$runs))
