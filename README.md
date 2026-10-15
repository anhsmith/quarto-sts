# quarto-sts

Quarto extension holding the Sea Through Science revealjs format: theme, logo, title-slide layout and transitions.

## Installation

```bash
quarto add anhsmith/quarto-sts
```

## Usage

```yaml
format: sts-revealjs
```

A background video on the title slide is set per deck, with `title-slide-attributes`.

## Example deck

`example.qmd` uses the extension directly from `_extensions/sts`, with one slide for each style class. Render it after changing the theme:

```bash
quarto render
```

## Contents

- `sts.scss`: title-slide layout and the overlay-text classes (`.h2right`, `#all-white`, `#all-white-right`, `#all-white-fifteen`, `#all-dark`).
- `lockup-horiz.svg`: logo, copied from `sea-through-science/logo/svg/` (generated there; replace this copy when the generator is re-run).
- `reveal-header.lua` and `resources/`: copied from [shafayetShafee/reveal-header](https://github.com/shafayetShafee/reveal-header) v1.2.8 (MIT licence), which makes the logo a link (`footer-logo-link`).
