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

# The browser report is also used as a stand-alone supporting document.  It
# should therefore not expose manuscript placeholders such as "Figure XX" or
# "Table XX".  Manuscript numbering is assigned only when an item is included
# in the assessment report.
html_path <- result$html
html <- paste(readLines(html_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
html <- gsub(
  "Figure <span class=['\"]figure-number['\"][^>]*>XX</span>\\.",
  "Figure.",
  html,
  perl = TRUE
)
html <- gsub(
  "Table <span class=['\"]table-number['\"][^>]*>XX</span>\\.",
  "Table.",
  html,
  perl = TRUE
)
html <- gsub(
  "<a href=\"(https?://[^\"]+)\"",
  "<a href=\"\\1\" target=\"_blank\" rel=\"noopener noreferrer\"",
  html,
  perl = TRUE
)
writeLines(html, html_path, useBytes = TRUE)

message("Rendered retrospective report: ", result$html)
message("Diagnostic model retrospective peels: ", nrow(result$data$runs))
