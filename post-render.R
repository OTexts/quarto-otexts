# Tidy the rendered HTML with the otexts extension's htmlreplace.pl
files <- strsplit(Sys.getenv("QUARTO_PROJECT_OUTPUT_FILES"), "\n")[[1]]
files <- files[endsWith(files, ".html")]
# _extensions/OTexts/otexts/ when installed from GitHub, _extensions/otexts/ locally
script <- c(
  "_extensions/OTexts/otexts/htmlreplace.pl",
  "_extensions/otexts/htmlreplace.pl"
)
script <- script[file.exists(script)][1]
if (is.na(script)) stop("Can't find the otexts extension's htmlreplace.pl")
if (length(files) > 0) {
  system2("perl", c("-i", script, shQuote(files)))
}
