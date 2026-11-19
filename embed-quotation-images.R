# Embeds the photo and the link icons of the quotation signature block in the
# Typst template of the sts-quotation format, between the marker lines below.
# Typst reads files only inside the project of a document, and a template
# cannot name a path inside an installed extension, so each image is held in
# the template as an SVG that wraps the image as a base64 data URI.
#
# The images are in quotation-images/: headshot.jpg (the photo, cut to a
# circle on a white ground) and linkedin.png, github.png and scholar.png.
# After replacing one, run from the repository root:
#   Rscript embed-quotation-images.R
# (needs the base64enc package, and magick to read the image dimensions)

library(base64enc)

image_dir <- "quotation-images"
template  <- "_extensions/sts-quotation/typst-template.typ"

images <- c(
  "sts-photo"         = "headshot.jpg",
  "sts-icon-linkedin" = "linkedin.png",
  "sts-icon-github"   = "github.png",
  "sts-icon-scholar"  = "scholar.png"
)

image_size <- function(path) {
  info <- magick::image_info(magick::image_read(path))
  c(info$width, info$height)
}

svg_wrapper <- function(path) {
  size <- image_size(path)
  mime <- if (grepl("\\.png$", path)) "image/png" else "image/jpeg"
  sprintf(
    paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" ',
      'xmlns:xlink="http://www.w3.org/1999/xlink" ',
      'viewBox="0 0 %1$d %2$d" width="%1$d" height="%2$d">',
      '<image width="%1$d" height="%2$d" xlink:href="data:%3$s;base64,%4$s"/>',
      '</svg>'
    ),
    size[1],
    size[2],
    mime,
    base64encode(path)
  )
}

block <- unlist(
  lapply(
    names(images),
    function(name) {
      c(
        paste0("#let ", name, " = ```svg"),
        svg_wrapper(file.path(image_dir, images[[name]])),
        "```.text"
      )
    }
  )
)

lines <- readLines(template, warn = FALSE, encoding = "UTF-8")
start <- which(lines == "// BEGIN sts-images (written by embed-quotation-images.R)")
end   <- which(lines == "// END sts-images")

stopifnot(
  length(start) == 1,
  length(end) == 1
)

con <- file(template, open = "w", encoding = "UTF-8")
writeLines(
  c(
    lines[seq_len(start)],
    block,
    lines[end:length(lines)]
  ),
  con
)
close(con)
