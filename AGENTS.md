# AGENTS.md — caltech-memo

Context and working notes for AI agents (and humans) working on this
repository.

## What this is

`caltech-memo` is a [Quarto](https://quarto.org) **format extension**
for Caltech HSS memoranda. It is the memo companion to
`caltech-letter` (the letterhead extension this repo is modeled on)
and `caltech-revealjs`, sharing their visual identity.

**Goal.** Replace the legacy LaTeX memo workflow built on
`HSSCorrespondence.cls` (2015, by kcb@hss) with a Markdown/Quarto one.
Two design targets:

1. **Fidelity** to the `memo` environment of `HSSCorrespondence.cls`:
   Caltech wordmark + two-line division name top-left, then a labeled
   field block — TO and FROM on the left, DATE / E-MAIL / MAIL CODE /
   EXT in a right-hand column, SUBJECT spanning the full width — small
   sans labels, section headings allowed in the body, and a
   continuation header with an orange rule on page 2+. A local copy of
   the class lives at `~/Library/texmf/tex/latex/hss/HSSCorrespondence.cls`
   (also under `~/Dropbox/computing/texmf/`).
2. **Brand modernization** to the Caltech Identity Toolkit
   (https://identity.caltech.edu), matching `caltech-letter`: orange
   `#FF6C0C` (PMS 1585c), neutral gray `#76777B` (PMS Cool Gray 9),
   body in TeX Gyre Heros (replacing the old class's Times), division
   line in Georgia, the orange wordmark — never the seal.

## How it works

One `_extension.yml` contributes **two** formats:

| Format | Engine | Notes |
|---|---|---|
| `caltech-memo-pdf` | XeLaTeX | Default. |
| `caltech-memo-typst` | Typst | Near-identical; faster, self-contained. |

### Front-matter design (the part most worth scrutinizing)

Memo fields live under a `memo:` YAML block — `memo.to`, `memo.from`,
`memo.subject`, `memo.email`, `memo.mail-code`, `memo.phone` — accessed
in the Pandoc templates with dotted paths (`$memo.to$`,
`$for(memo.from)$$it$…`). This is forced, not stylistic:

- **`to` and `from` are reserved** at the top level of Quarto front
  matter. `from:` fails YAML validation (it is the Pandoc reader
  option); `to:` validates but is silently consumed as the output
  format (verified: `to: "Test Person"` produced "pdf-engine xelatex
  is not compatible with output format test person").
- **`date` must stay top-level.** Quarto resolves `date: today` and
  applies the extension's `date-format: "MMMM D, YYYY"` only to the
  standard `date` key. Nested under `memo:` it would pass through raw.

`memo.to`/`memo.from` accept a scalar or a list (Pandoc's `$for$`
iterates once over a scalar) — lists are for committee memos, one
sender per line. The E-MAIL / MAIL CODE / EXT stack is conditional
(shown only if provided), unlike the letter extension's baked-in
sender defaults, because a personal contact block is wrong on
committee memos. `memo.from` alone defaults to "Jonathan N. Katz".

### XeLaTeX path

- `header.tex` — preamble loaded verbatim via `include-in-header`
  (fonts, colors, `fancyhdr` page styles, memo label font + lengths,
  no-hyphenation). **No Pandoc template syntax here.**
- `partials/title.tex` — emptied, to suppress Quarto's default title
  block.
- `partials/before-body.tex` — draws the lockup and the field block
  (column arithmetic with `\memolabelwd`/`\memorightwd`), the orange
  separator rule, and fills `\contheadleft` for the page-2+ header.
- No `after-body.tex`: memos have no closing/signature block.
- The generated document class is plain **`article`, not KOMA** —
  `\setkomafont` is unavailable (this broke the first build). Section
  headings are restyled with an `\@startsection` redefinition, the
  same approach the old class used.

### Typst path

- `typst-template.typ` — defines the `memo()` function (lockup, field
  grid, orange rule, continuation header, body).
- `typst-show.typ` — forwards Pandoc metadata into `memo()`.
- `page-numbering: false` in `_extension.yml` is required: Quarto's
  outer Typst template otherwise emits `#set page(numbering: "1")`,
  which printed a centered footer page number that the LaTeX format
  (and the old class) does not have. Page numbers appear only in the
  page-2+ continuation header, in both engines.

### Logo and fonts

Identical to `caltech-letter` (assets copied from it):
`caltech-logo-orange.pdf` for XeLaTeX, `.svg` for Typst (which cannot
embed PDF), `logo-path.lua` resolving the PDF via
`quarto.utils.resolve_path`, the Typst logo path a root-relative
literal in the function default (Pandoc's Typst writer corrupts
`_extensions` paths routed through metadata). TeX Gyre Heros comes
from the TeX tree (kpathsea, `tex-gyre` package) for XeLaTeX and from
the bundled `fonts/` for Typst. Georgia is a system-font dependency.

## Build and test

```bash
# Render the committee-memo sample to each engine
quarto render example.qmd --to caltech-memo-pdf
quarto render example.qmd --to caltech-memo-typst
```

Samples: `template.qmd` (minimal, `date: today`, scalar to/from),
`example.qmd` (committee memo: list-valued `memo.from`, sections,
full contact stack).

**Visual verification**: compare the two engines' output page-for-page
(field block alignment, label column, orange rules). For the
continuation header, append filler paragraphs to force a second page
and check subject + date left, "Page N" right, orange rule, in both
engines. There is no smoke-test script yet (the letterhead repo's
`scripts/smoke-test.sh` is the model if one is added).

Requirements: Quarto ≥ 1.4, XeLaTeX with `tex-gyre`/`fontspec`/
`fancyhdr`/`ragged2e`, and the Georgia font. Typst is bundled with
Quarto.

## Known limitations / worth scrutinizing

- **Namespaced installs (from Codex review, unfixed)**: the Typst
  logo path (`typst-template.typ`) and `font-paths`
  (`_extension.yml`) are literals pointing at
  `/_extensions/caltech-memo/…`. A GitHub install (`quarto add
  jnkatz/caltech-memo`) lands in `_extensions/jnkatz/caltech-memo/`,
  where the Typst logo and bundled fonts will not resolve. The
  LaTeX path is immune (`logo-path.lua` uses
  `quarto.utils.resolve_path`). `caltech-letter` has the identical
  limitation; fix both together.
- **Body rhythm across engines is approximate, by design**: LaTeX
  `\parskip 0.8\baselineskip` vs. Typst `spacing: 0.9em`, and LaTeX
  `\@startsection` spacing vs. Typst text-size show rules. Verified
  visually acceptable; do not expect pixel parity.
- **Not ported from the old class**: `\cc`, `\encl`,
  `\distribution`, graphic signatures (`\ESign`), the `bw`/`dabney`
  mail-code options. Users can type cc/enclosure lines in the body.
- **Field-block spacing likewise differs slightly**: LaTeX minipage
  rows with `0.6\baselineskip` gaps vs. a single Typst grid with
  `row-gutter: 0.9em`.
- **Fixed column widths**: label column `4.2em` (Typst) vs. measured
  `\settowidth` on "SUBJECT" (LaTeX); right column hard-coded `2.2in`
  in both. A very long date or e-mail could wrap.
- **Continuation header is always on** (no toggle), and uses
  `memo.subject` + `date`; a very long subject will wrap awkwardly in
  the page-2+ header.
- **No graceful Georgia fallback** (XeLaTeX hard-errors if absent;
  Typst falls back silently) — inherited from the letter extension.
- **Generated artifacts**: root-level `*.pdf`/`*.tex`/`*.typ` are
  gitignored (the two `example-*.pdf` samples are local conveniences,
  not committed).

## Conventions

This repo is Quarto/LaTeX/Typst/Lua, not R. Keep the two engines at
parity: a change to the memo layout in one engine must be mirrored in
the other. Keep `_extension.yml` versioned. Do not commit generated
artifacts. The example memo content is invented; never reuse text
from real personnel memos in samples.
