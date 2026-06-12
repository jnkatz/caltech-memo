#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/caltech-memo-smoke.XXXXXX")"

cleanup() {
  if [[ -n "${KEEP_SMOKE:-}" ]]; then
    printf 'Keeping smoke-test workspace: %s\n' "$TMP_ROOT"
  else
    rm -rf "$TMP_ROOT"
  fi
}
trap cleanup EXIT

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

copy_inputs() {
  local project="$1"
  # A _quarto.yml makes this a Quarto project, which is required for
  # subdirectory renders: without it Quarto looks for _extensions only
  # in the document's own directory.
  printf 'project:\n  type: default\n' > "$project/_quarto.yml"
  cp "$ROOT/template.qmd" "$project/template.qmd"
  cp "$ROOT/example.qmd" "$project/example.qmd"

  cat >"$project/minimal.qmd" <<'QMD'
---
format: caltech-memo-pdf
memo:
  to: "HSS Faculty"
  subject: "Minimal Smoke Memo"
date: today
---

This is a minimal memo without optional sender contact fields.
QMD

  cat >"$project/long.qmd" <<'QMD'
---
format: caltech-memo-pdf
memo:
  to: "HSS Faculty"
  subject: "Long Smoke Memo"
date: today
---

This memo exists only to force a second page during smoke testing.

{{< pagebreak >}}

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.

This paragraph repeats neutral placeholder prose so that the continuation
header can be checked without relying on real memo content.
QMD
}

install_extension() {
  local project="$1"
  local layout="$2"

  case "$layout" in
    local)
      mkdir -p "$project/_extensions"
      cp -R "$ROOT/_extensions/caltech-memo" \
        "$project/_extensions/caltech-memo"
      ;;
    namespaced)
      mkdir -p "$project/_extensions/jnkatz"
      cp -R "$ROOT/_extensions/caltech-memo" \
        "$project/_extensions/jnkatz/caltech-memo"
      ;;
    *)
      printf 'Unknown extension layout: %s\n' "$layout" >&2
      exit 1
      ;;
  esac
}

render_pair() {
  local source="$1"
  local stem="$2"

  quarto render "$source" --to caltech-memo-pdf \
    --output "$stem-latex.pdf"
  quarto render "$source" --to caltech-memo-typst \
    --output "$stem-typst.pdf"
}

assert_text() {
  local pdf="$1"
  local expected="$2"
  local page_args=()

  if [[ "$#" -eq 3 ]]; then
    page_args=(-f "$3" -l "$3")
  fi

  if ! pdftotext "${page_args[@]}" "$pdf" - | grep -Fq "$expected"; then
    printf 'Expected text not found in %s: %s\n' "$pdf" "$expected" >&2
    exit 1
  fi
}

# Typst falls back to a substitute font SILENTLY when font-paths is wrong,
# so text assertions alone cannot catch a font regression. Require the
# bundled face to actually be embedded.
assert_font() {
  local pdf="$1"
  local face="$2"

  if ! pdffonts "$pdf" | grep -q "$face"; then
    printf 'Font %s not embedded in %s (silent fallback?)\n' "$face" "$pdf" >&2
    exit 1
  fi
}

run_layout() {
  local layout="$1"
  local project="$TMP_ROOT/$layout"

  mkdir -p "$project"
  install_extension "$project" "$layout"
  copy_inputs "$project"

  printf '==> Testing %s install layout\n' "$layout"
  (
    cd "$project"
    render_pair template.qmd template
    render_pair example.qmd example
    render_pair minimal.qmd minimal
    render_pair long.qmd long

    # Subdirectory render: root-relative Typst asset paths must resolve
    # from a document below the project root, in both layouts.
    mkdir -p memos
    cp template.qmd memos/subdir.qmd
    render_pair memos/subdir.qmd subdir

    assert_text template-latex.pdf "Subject of the memo"
    assert_text template-typst.pdf "Subject of the memo"
    assert_text example-latex.pdf "Graduate Curriculum Committee"
    assert_text example-typst.pdf "Graduate Curriculum Committee"
    assert_text minimal-latex.pdf "Minimal Smoke Memo"
    assert_text minimal-typst.pdf "Minimal Smoke Memo"
    assert_text long-latex.pdf "Long Smoke Memo" 2
    assert_text long-latex.pdf "Page 2" 2
    assert_text long-typst.pdf "Long Smoke Memo" 2
    assert_text long-typst.pdf "Page 2" 2

    # In project mode, --output lands at the project root, not the
    # input's directory.
    assert_text subdir-latex.pdf "Subject of the memo"
    assert_text subdir-typst.pdf "Subject of the memo"

    assert_font template-typst.pdf "TeXGyreHeros"
    assert_font example-typst.pdf "TeXGyreHeros"
    assert_font subdir-typst.pdf "TeXGyreHeros"
  )
}

need quarto
need pdftotext
need pdffonts

run_layout local
run_layout namespaced

printf 'Smoke tests passed.\n'
