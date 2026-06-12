# Changelog

All notable changes to `caltech-memo` are documented here.

## 0.1.0 — 2026-06-11

Initial release. The sections below record the pre-release review
rounds (Codex review of the initial draft, then hardening of those
fixes).

### Fixed

- The Typst template now asserts that the logo path was injected by
  `logo-path.lua` instead of silently rendering a memo without the
  Caltech wordmark (and the lockup spacing no longer assumes a
  logo-less path exists).
- The smoke test now asserts that TeX Gyre Heros is actually embedded
  in the Typst PDFs (`pdffonts`); Typst substitutes fonts silently,
  so text checks alone could not catch a `font-paths` regression.

### Added

- The smoke test now also renders from a subdirectory of the project
  in both layouts, verifying that the root-relative Typst asset paths
  resolve below the project root (manually confirmed for both engines
  before being added).

### Fixed (initial Codex review)

- Fixed Typst rendering after `quarto add jnkatz/caltech-memo` by
  resolving the SVG logo through the Lua filter and including the
  namespaced install font path.
- Corrected the README's GitHub extension install path.
- Corrected the bundled-font path in `LICENSE`.

### Added

- Added `scripts/smoke-test.sh`, covering local and namespaced
  extension layouts, both engines, minimal and committee memos, and
  second-page continuation headers.
- Added `REVIEW.md` documenting the review findings, fixes, and
  verification workflow.
