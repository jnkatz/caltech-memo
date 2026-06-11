# Changelog

All notable changes to `caltech-memo` are documented here.

## Unreleased

### Fixed

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
