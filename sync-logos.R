# Copies the logo files used by the extension from their master copies in
# sea-through-science/logo/svg, and embeds the horizontal lockup in the Typst
# templates of the report and quotation formats, between the marker lines
# below. Typst reads files only inside the project of a document, and a
# template cannot name a path inside an installed extension, so the SVG is
# held in each template as text.
#
# Run from the repository root, with sea-through-science cloned beside this
# repository, after the logos change:
#   Rscript sync-logos.R
#   Rscript make-embedded-scss.R

master   <- "../sea-through-science/logo/svg"
ext_dir  <- "_extensions/sts"
variants <- c("lockup-horiz.svg", "lockup-horiz-white.svg")

templates <- c(
  file.path(ext_dir, "typst-template.typ"),
  "_extensions/sts-quotation/typst-template.typ"
)

stopifnot(
  dir.exists(master),
  file.copy(
    file.path(master, variants),
    file.path(ext_dir, variants),
    overwrite = TRUE
  )
)

svg <- readLines(file.path(ext_dir, "lockup-horiz.svg"), warn = FALSE)

# $ would be read as a Pandoc template variable, since the templates are
# Pandoc template partials
stopifnot(
  !any(grepl("```", svg, fixed = TRUE)),
  !any(grepl("$", svg, fixed = TRUE))
)

for (template in templates) {
  lines <- readLines(template, warn = FALSE, encoding = "UTF-8")
  start <- which(lines == "// BEGIN sts-lockup (written by sync-logos.R)")
  end   <- which(lines == "// END sts-lockup")

  stopifnot(
    length(start) == 1,
    length(end) == 1
  )

  con <- file(template, open = "w", encoding = "UTF-8")
  writeLines(
    c(
      lines[seq_len(start)],
      "#let sts-lockup = ```svg",
      svg,
      "```.text",
      lines[end:length(lines)]
    ),
    con
  )
  close(con)
}
