# Copies the logo files used by the extension from their master copies in
# sea-through-science/logo/svg, and embeds the horizontal lockup in the Typst
# template, between the marker lines below. Typst reads files only inside the
# project of a report, and a template cannot name a path inside an installed
# extension, so the SVG is held in the template as text.
#
# Run from the repository root, with sea-through-science cloned beside this
# repository, after the logos change:
#   Rscript sync-logos.R
#   Rscript make-embedded-scss.R

master   <- "../sea-through-science/logo/svg"
ext_dir  <- "_extensions/sts"
variants <- c("lockup-horiz.svg", "lockup-horiz-white.svg")

stopifnot(
  dir.exists(master),
  file.copy(
    file.path(master, variants),
    file.path(ext_dir, variants),
    overwrite = TRUE
  )
)

template <- file.path(ext_dir, "typst-template.typ")
lines    <- readLines(template, warn = FALSE)
svg      <- readLines(file.path(ext_dir, "lockup-horiz.svg"), warn = FALSE)
start    <- which(lines == "// BEGIN sts-lockup (written by sync-logos.R)")
end      <- which(lines == "// END sts-lockup")

stopifnot(
  length(start) == 1,
  length(end) == 1,
  !any(grepl("```", svg, fixed = TRUE)),
  !any(grepl("$", svg, fixed = TRUE))
)

writeLines(
  c(
    lines[seq_len(start)],
    "#let sts-lockup = ```svg",
    svg,
    "```.text",
    lines[end:length(lines)]
  ),
  template
)
