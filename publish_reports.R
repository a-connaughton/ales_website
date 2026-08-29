## publish_reports.R
## Purpose: Copy the rendered survey summaries into the website repository and
##   list them in the sitemap. Renders nothing; run render_summaries.R first.
##   Stages files only, so review with `git status` and `git diff --stat`
##   before committing.
## Inputs: ../survey_summaries/2025/*.html, ../survey_summaries/reports.html,
##   sitemap.xml
## Outputs: reports/2025/*.html, reports.html, sitemap.xml
## Called by: Rscript publish_reports.R, from the repository root

## Paths ------------------

# the repository is wherever this script sits
script_path <- sub("^--file=", "",
                   grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE))
repo <- normalizePath(dirname(script_path))

summaries <- file.path(repo, "..", "survey_summaries")
src_reports <- file.path(summaries, "2025")
src_home <- file.path(summaries, "reports.html")
dest_reports <- file.path(repo, "reports", "2025")
sitemap <- file.path(repo, "sitemap.xml")

site_url <- "https://localelectionssurveys.org"
today <- format(Sys.Date(), "%Y-%m-%d")

stopifnot(dir.exists(src_reports), file.exists(src_home), file.exists(sitemap))

## Copy reports ------------------

dir.create(dest_reports, showWarnings = FALSE, recursive = TRUE)

files <- sort(list.files(src_reports, pattern = "\\.html$", full.names = FALSE))
stopifnot(length(files) > 0)

# reports removed upstream would otherwise linger in the repository
gone <- setdiff(list.files(dest_reports, pattern = "\\.html$"), files)
if (length(gone)) file.remove(file.path(dest_reports, gone))

copied <- file.copy(file.path(src_reports, files),
                    file.path(dest_reports, files), overwrite = TRUE)
stopifnot(all(copied))
stopifnot(file.copy(src_home, file.path(repo, "reports.html"), overwrite = TRUE))

## Sitemap ------------------

# the report entries sit in a marked block so this script can replace them
# without touching the hand-maintained entries for the rest of the site
open_tag <- "  <!-- reports:2025 -->"
close_tag <- "  <!-- /reports:2025 -->"

entries <- paste0(
  "  <url>\n",
  "    <loc>", site_url, "/reports/2025/", files, "</loc>\n",
  "    <lastmod>", today, "</lastmod>\n",
  "    <changefreq>yearly</changefreq>\n",
  "    <priority>0.6</priority>\n",
  "  </url>",
  collapse = "\n"
)
block <- paste(open_tag, entries, close_tag, sep = "\n")

xml <- paste(readLines(sitemap, warn = FALSE), collapse = "\n")
if (grepl(open_tag, xml, fixed = TRUE)) {
  pattern <- paste0(open_tag, "(?s).*?", close_tag)
  xml <- sub(pattern, block, xml, perl = TRUE)
} else {
  xml <- sub("</urlset>", paste0(block, "\n</urlset>"), xml, fixed = TRUE)
}

# the landing page changes whenever the reports do
xml <- sub(paste0("(<loc>", site_url, "/reports\\.html</loc>\\s*<lastmod>)[^<]*"),
           paste0("\\1", today), xml, perl = TRUE)

writeLines(xml, sitemap)

stopifnot(length(gregexpr("/reports/2025/", xml, fixed = TRUE)[[1]]) == length(files))
