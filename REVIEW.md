# Review Notes

This file records the review findings from the initial Codex review of
the Claude-drafted `caltech-memo` Quarto extension and the follow-up
fixes.

## Findings

1. The Typst format was not installable through the documented GitHub
   path. `quarto add jnkatz/caltech-memo` installs the extension under
   `_extensions/jnkatz/caltech-memo/`, but the Typst logo path and
   `font-paths` pointed only at `/_extensions/caltech-memo/...`.
   XeLaTeX worked because `logo-path.lua` used Quarto's extension-path
   resolver; Typst failed to find the SVG logo and bundled TeX Gyre
   Heros fonts.

2. The README described the GitHub install location incorrectly. It
   said `quarto add jnkatz/caltech-memo` installs into
   `_extensions/caltech-memo/`; the normal GitHub layout is
   `_extensions/jnkatz/caltech-memo/`.

3. There was no smoke test even though the extension depends on parity
   between two engines and on page-2 continuation behavior that is easy
   to break.

4. The bundled-font notice in `LICENSE` still referred to
   `_extensions/caltech-letter/fonts/` rather than this extension's
   `_extensions/caltech-memo/fonts/`.

## Fixes Applied

- Typst logo resolution now goes through `logo-path.lua`, which uses
  `quarto.utils.resolve_path()` and emits a root-relative Typst string
  so underscores in `_extensions` are not escaped by Pandoc.
- Typst `font-paths` now includes both the local development layout
  (`/_extensions/caltech-memo/fonts`) and the GitHub install layout
  (`/_extensions/jnkatz/caltech-memo/fonts`).
- `scripts/smoke-test.sh` renders local and namespaced installs with
  both engines, covering the template memo, committee example, minimal
  memo, and a forced second-page continuation header.
- README, AGENTS notes, LICENSE, and CHANGELOG were updated to match
  the fixed behavior.

## Verification

The fix was checked manually before the smoke test was added:

- Local checkout Typst render: `quarto render template.qmd --to
  caltech-memo-typst --output template-fixed-typst.pdf`
- Simulated GitHub layout under `_extensions/jnkatz/caltech-memo/`:
  both `caltech-memo-pdf` and `caltech-memo-typst` rendered
  successfully.

The durable verification command is:

```bash
bash scripts/smoke-test.sh
```
