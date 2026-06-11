# Caltech Memo

A [Quarto](https://quarto.org/) format extension for Caltech HSS
memoranda. It reproduces the classic `HSSCorrespondence.cls` memo
layout — the Caltech wordmark and division lockup, then a labeled
TO / FROM / DATE / SUBJECT field block — restyled to Caltech's
modern identity standards (the same fonts and colors as
[`jnkatz/caltech-letter`](https://github.com/jnkatz/caltech-letter)).

It renders to PDF through two engines:

| Format | Engine | Notes |
|---|---|---|
| `caltech-memo-pdf` | XeLaTeX | Default. |
| `caltech-memo-typst` | Typst | Fast, self-contained; near-identical output. |

This is the memo companion to
[`jnkatz/caltech-letter`](https://github.com/jnkatz/caltech-letter)
and [`jnkatz/caltech-revealjs`](https://github.com/jnkatz/caltech-revealjs),
sharing their visual identity (orange `#FF6C0C`).

## Installation

```bash
quarto add jnkatz/caltech-memo
```

This installs the extension into `_extensions/caltech-memo/` in your
project.

## Usage

A complete memo is just front matter plus the body:

```yaml
---
format: caltech-memo-pdf
memo:
  to: "HSS Faculty"
  from: "Jonathan N. Katz"
  subject: "Subject of the memo"
date: today
---

Write the body of the memo here...
```

Render it:

```bash
quarto render memo.qmd
```

To use the Typst engine instead, change the format to
`caltech-memo-typst` (or pass `--to caltech-memo-typst`).

### Committee memos

`memo.to` and `memo.from` accept either a single string or a YAML
list (one line each), so a committee memo is:

```yaml
memo:
  to: "Tenured Social Science Faculty"
  from:
    - "Jonathan N. Katz (chair)"
    - "Second Member"
    - "Third Member"
```

See `template.qmd` for a starting point and `example.qmd` for a
complete committee memo with sections.

## Front-matter fields

Memo-specific fields live under a `memo:` block, chiefly because
`to` and `from` are reserved Pandoc options at the top level of
Quarto front matter. The exception is `date`, which must stay
top-level: Quarto resolves `today` and applies `date-format` only
to the standard date key.

| Field | Default | Purpose |
|---|---|---|
| `memo.to` | *(none)* | Addressee(s). String or list. |
| `memo.from` | Jonathan N. Katz | Sender(s). String or list. |
| `memo.subject` | *(none)* | Bold SUBJECT line; also the page-2+ running header. |
| `memo.email` | *(none)* | E-MAIL line in the right column. |
| `memo.mail-code` | *(none)* | MAIL CODE line in the right column. |
| `memo.phone` | *(none)* | EXT line in the right column. |
| `date` | today | Top-level. Use `today` or a literal string. |
| `department` | Division of the Humanities and Social Sciences | Serif line under the logo. |

The contact stack (E-MAIL / MAIL CODE / EXT) is shown only for the
fields you provide — handy for committee memos where a personal
contact block would be odd. The date is formatted as `MMMM D, YYYY`
(e.g. "June 11, 2026").

A continuation header ("subject / date / Page N" over a thin orange
rule, as in the old class) appears automatically on page 2 and
later; page 1 has none. Section headings (`##`) render as modest
bold headings in both engines.

## Fonts and colors

These follow the [Caltech Identity Toolkit](https://identity.caltech.edu)
and match the `caltech-letter` extension:

- **Body** — **TeX Gyre Heros**, a free Helvetica-metric face
  (replacing the old class's Times). XeLaTeX loads it from your TeX
  installation (the `tex-gyre` package); Typst uses the copies
  bundled in `_extensions/caltech-memo/fonts/`.
- **Division line** — **Georgia** (serif), the sanctioned free
  alternative to Adobe Caslon Pro, per Caltech's lockup standard.
- **Field labels** — small Cool Gray sans caps (TO, FROM, DATE, …),
  echoing the original HSS memo design.
- **Colors** — Caltech orange `#FF6C0C` (PMS 1585c) and neutral gray
  `#76777B` (PMS Cool Gray 9).

## What's included

```
_extensions/caltech-memo/
├── _extension.yml              # contributes the pdf + typst formats
├── header.tex                  # XeLaTeX preamble (fonts, colors, fancyhdr)
├── partials/
│   ├── title.tex               # emptied → suppresses the default title block
│   └── before-body.tex         # the memo heading (lockup + field block)
├── typst-template.typ          # the Typst `memo` function
├── typst-show.typ              # forwards metadata into memo()
├── logo-path.lua               # resolves the logo per engine
├── caltech-logo-orange.pdf     # official vector wordmark (XeLaTeX)
├── caltech-logo-orange.svg     # official vector wordmark (Typst)
└── fonts/                      # TeX Gyre Heros (for Typst)
```

## Requirements

- Quarto >= 1.4.0
- The **Georgia** font, for the division line (a system font on
  macOS and Windows; on Linux install `ttf-mscorefonts-installer`).
- For `caltech-memo-pdf`: a TeX installation with XeLaTeX and the
  `tex-gyre`, `fontspec`, `fancyhdr`, and `ragged2e` packages (all
  standard; Quarto's TinyTeX can install them).
- For `caltech-memo-typst`: nothing beyond Quarto and Georgia.

## License

MIT (see `LICENSE`). The Caltech wordmark is a trademark of the
California Institute of Technology.
