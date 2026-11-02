// Sea Through Science report template, used by the sts-typst format.
// The reference list is produced by Pandoc (citeproc: true), so the
// template has no #bibliography call; end the document with a References
// heading and a ::: {#refs} ::: div.

#let article(

  title: "Report",

  subtitle: "Report subtitle",

  author: "Author",

  date: "Date",

  client: "Client",

  cover: "img/cover.png",

  tocimage: "img/pretty-fld.jpg",

  campaign: "Campaign",

  paper: "a4",

  body,

) = {

  set document(
    title: title,
    author: author,
    )

  set heading(numbering: "1.")

  set text(
    font: "Source Sans Pro",
  )

  set page(
    paper: paper,
    margin: 2.5cm,
    numbering: "1",
  )

  // table formatting
  let frame(stroke) = (x, y) => (
    left: if x > 0 { 0pt } else { stroke },
    right: stroke,
    top: if y < 2 { stroke } else { 0pt },
    bottom: stroke,
  )

  show table.cell.where(y: 0): set text(weight: "bold")

  set table(
    inset: 6pt,
    align: center,
    fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },
    stroke: frame(rgb("21222C")),
  )

  // Make figure captions italic
  show figure.caption: emph

  // Colour links
  show link: set text(fill: blue)
  show link: underline

  show heading.where(level: 1): it => {
    colbreak(weak: true)
    it
    v(0.5em)
  }

  // Cover page; mark_black.png is copied beside the document by the
  // format-resources entry in _extension.yml
  page(align(center + horizon)[
    #text(size: 2.5em)[#title]
    #v(4em, weak: true)
    #text(size: 2em)[#subtitle]
    #v(4em, weak: true)
    #image(cover, width: 80%)
    #v(4em, weak: true)
    #text("Prepared by " + author, size: 1em)
    #v(2em, weak: true)
    #image("mark_black.png", width: 40%)
    #v(2em, weak: true)
    #text("for " + client, size: 1em)
    #v(4em, weak: true)
    #text()[#date]
  ])

  // New page: Table of contents
  page(align(left + top)[
    #outline(
      depth: 2,
      indent: (level) => level * 1.5em,
      )
    #v(4em, weak: true)
    #align(center)[
      #image(tocimage, width: 70%)
      ]
  ])

  page(align(left)[
    #body
  ])

}
