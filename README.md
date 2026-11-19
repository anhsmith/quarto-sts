# quarto-sts

Quarto extensions holding three Sea Through Science formats: `sts-revealjs` for slide decks (theme, logo, title-slide layout and transitions), `sts-typst` for PDF reports (cover page, contents page, table style and reference list), and `sts-quotation-typst` for PDF quotations (title banner, table of packages and fees, and signature block).

## Installation

```bash
quarto add anhsmith/quarto-sts
```

## Usage

```yaml
format: sts-revealjs
```

A background video on the title slide is set per deck, with `title-slide-attributes`.

Level-1 headings (`#`) become section slides with a navy background. To use another colour in one deck, set `sts-section-bg: "#027DBF"` in its YAML; to change one section slide, give its heading a `background-color` attribute.

## Reports

```yaml
title: "Survey Report"
subtitle: "Stereo-BRUV survey of Northland 2026"
author: "Dr Adam N. H. Smith (Director)"
date: today
bibliography: ../library.bib
format: sts-typst
params:
  client: "Fisheries New Zealand"
  cover: "img/cover.png"
  tocimage: "img/toc.jpg"
```

The cover page shows the title, subtitle, `cover` image, author, Sea Through Science lockup, client and date, and the second page shows the contents and the `tocimage` image. The paths to both images are relative to the report. The lockup is embedded in the template, so no logo file is needed in the project or copied beside the report.

The logo files in the extension are copies of the master files in `sea-through-science/logo/svg`. After the logos change, run `Rscript sync-logos.R`, which also embeds the lockup in the report and quotation templates, and then `Rscript make-embedded-scss.R` from the repository root, with `sea-through-science` cloned beside this repository.

Citations are processed by Pandoc (`citeproc: true`) with the Elsevier Vancouver style, rather than by Typst. Pandoc reads a bibliography outside the project folder, such as `../library.bib`, which Typst does not read, and accepts the `year` fields that Typst fails to parse. End the report with:

```markdown
# References {.unnumbered}

::: {#refs}
:::
```

The template sets the font to Source Sans Pro; Typst falls back to its default font, with a warning, when Source Sans Pro is not installed.

## Quotations

The `sts-quotation-typst` format lays out a quotation as a title banner with the lockup, a line naming the client, date and purpose, the body, and a signature block with photo, bio and contact details. `example-quotation.qmd` holds a quotation with generic text in each section, to copy as a starting point.

```yaml
title: "Indicative quotation"
subtitle: "Project title"
client: "Client name"
purpose: "purpose of the estimate"
date: today
format: sts-quotation-typst
fees:
  currency: NZD
  symbol: "$"
  tax: "excluding GST"
  rate: "x,xxx"
  options: [Minimum, Recommended]
  packages:
    - name: "A — Package name"
      description: "Work included in the package, and what it delivers."
      days: [2, 3]
    - name: "B — Package name"
      days: [5, 8]
  note: "Note on work that can be added at the daily rate."
```

The table of packages and fees is built from the `fees` field and placed where the body has an empty `fees` div:

```markdown
# Packages and fees

::: {.fees}
:::
```

Each package takes one value of `days` for each of the `options`. Without `options`, the table has a single set of columns, and each package takes a single value of `days`. Days shown in the table are rounded to two decimals.

Under `fees`, `rate` is the daily rate, and `symbol` (default `€`), `currency` (a code such as NZD or EUR; default none) and `tax` (default "excluding taxes") are optional. With a number for `rate`, each option has a Fee column, and the fee of each package is the number of days multiplied by `rate`, so the fees and totals cannot disagree with the days. A number may be written with thousands separators, as `"1,200"`. With placeholder text for `rate` that contains no digits, such as `"x,xxx"`, every fee and the rate are printed as that text (`$x,xxx`), as in the example above; this keeps rates out of the repository. Text that contains digits but is not a number, such as `"1.200,00"`, stops the render with an error. Without `rate`, the table has Days columns only. Below the table, a note states the currency, the tax treatment and the daily rate, followed by `note`.

Level-1 headings are unnumbered, and the lists use en-dash markers. The font is Calibri; Typst falls back to its default font, with a warning, when Calibri is not installed. The page has no page number.

The signature block holds Adam's name, role, bio, locality (Red Beach, New Zealand), email, website, LinkedIn, GitHub and Google Scholar profile by default. The full postal address is not stored in this repository; give it under `signature` as `address` where a quotation needs it. Any of these fields can be replaced under `signature`, and set to `false` to drop it from the block; `signature: false` drops the whole block:

```yaml
signature:
  role: "Principal Statistician"
  scholar: false
```

The photo and the icons are embedded in the template, as is the lockup, so the format needs no image files beside the quotation. The source images are in `quotation-images/`; after replacing one, run `Rscript embed-quotation-images.R` from the repository root (needs the base64enc and magick packages).

## Design

- Typeface: IBM Plex Sans, the typeface of the wordmark (regular, italic, medium and semibold). The fonts are embedded in the compiled CSS, so decks need no internet connection.
- Palette, from the logo SVGs and the website: navy `#051838`, blue `#027DBF`, aqua `#54B5CB`, sky `#99D9EA`, bright blue `#00A2E8`. The SCSS variables are `$sts-navy`, `$sts-blue`, `$sts-aqua`, `$sts-sky` and `$sts-bright`.
- Content slides are white, with navy headings and an aqua bar under each slide title. Section slides are navy, with white headings, and the logo turns white on them.
- Title-slide text is white with a shadow, for legibility over footage. The white lockup sits under the author block, and the corner logo is hidden on the title slide.

## Example deck

`example.qmd` uses the extension directly from `_extensions/sts`, with one slide for each style class, and `example-quotation.qmd` uses `_extensions/sts-quotation`. Render both after changing either format:

```bash
quarto render
```

## Contents

- `sts.scss`: brand palette, typeface, title-slide layout, section-slide styling and the overlay-text classes (`.h2right`, `#all-white`, `#all-white-right`, `#all-white-fifteen`, `#all-dark`).
- `sections.lua`: sets the background colour of section slides.
- `fonts/`: IBM Plex Sans `.woff2` files from the IBM/plex release `@ibm/plex-sans@1.1.0`, with their licence (`OFL.txt`, SIL Open Font License 1.1).
- `embedded.scss`: `@font-face` rules for the fonts and the `$sts-lockup-white` variable, with the files embedded as base64 data URIs. Generated by `make-embedded-scss.R`. Quarto does not rewrite `url()` paths in an extension theme, so relative paths to files in the extension fail. To regenerate after replacing a font or logo file, run `Rscript make-embedded-scss.R` (needs the base64enc package).
- `lockup-horiz.svg` (corner logo) and `lockup-horiz-white.svg` (title slide): copied from `sea-through-science/logo/svg/`, where they are generated. Replace these copies when the generator is re-run.
- `reveal-header.lua` and `resources/`: copied from [shafayetShafee/reveal-header](https://github.com/shafayetShafee/reveal-header) v1.2.8 (MIT licence), which makes the logo a link (`footer-logo-link`).

In `_extensions/sts-quotation/`:

- `typst-template.typ`: page layout, title banner, the `sts-fees` table and the `sts-signature` block, with the lockup (written by `sync-logos.R`) and the photo and icons (written by `embed-quotation-images.R`) embedded as SVG text.
- `typst-show.typ`: passes the YAML fields to the template.
- `quotation.lua`: builds the call to `sts-fees` from the `fees` field, and passes the `signature` fields to the template.
