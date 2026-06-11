// caltech-memo: Typst memo template. Defines a `memo` function that draws
// the Caltech lockup (logo + division line), the memo field block
// (TO / FROM / SUBJECT left; DATE / E-MAIL / MAIL CODE / EXT right), an
// orange separator rule, then the body. Called from typst-show.typ.

// Official Caltech palette: orange PMS 1585c, neutral PMS Cool Gray 9.
#let caltech-orange = rgb("#FF6C0C")
#let caltech-gray = rgb("#76777B")
#let today = datetime.today().display("[month repr:long] [day padding:none], [year]")

#let memo(
  to: (),
  from: ([Jonathan N. Katz],),
  subject: none,
  date: today,
  email: none,
  mail-code: none,
  phone: none,
  department: [Division of the Humanities and Social Sciences],
  logo: none,
  fontsize: 11pt,
  margin: (x: 1in, top: 1.05in, bottom: 1in),
  doc,
) = {
  set text(font: "TeX Gyre Heros", size: fontsize)
  set par(justify: false, leading: 0.65em, spacing: 0.9em, first-line-indent: 0pt)
  show heading.where(level: 1): set text(size: fontsize + 2pt)
  show heading.where(level: 2): set text(size: fontsize)

  let field-label(s) = text(size: 8pt, fill: caltech-gray)[#s]

  set page(
    paper: "us-letter",
    margin: margin,
    // Continuation header (page 2+): subject + date left, "Page N" right,
    // over a thin Caltech-orange rule.
    header: context {
      if counter(page).get().first() > 1 {
        set text(size: 9pt, fill: caltech-gray)
        grid(
          columns: (1fr, auto),
          align(left)[#if subject != none [#subject #h(2em)] #date],
          align(right)[Page #counter(page).display()],
        )
        v(-4pt)
        line(length: 100%, stroke: 0.5pt + caltech-orange)
      }
    },
  )

  // --- Lockup: logo + division line (memos carry no sender address block) ---
  if logo != none {
    image(logo, height: 0.55in)
  }
  v(6pt)
  text(font: "Georgia", size: 9pt, fill: caltech-gray)[#department]

  v(1.4em)

  // --- Memo field block ---
  let contact-stack = {
    let rows = ()
    if email != none { rows.push((field-label("E-MAIL"), email)) }
    if mail-code != none { rows.push((field-label("MAIL CODE"), mail-code)) }
    if phone != none { rows.push((field-label("EXT"), phone)) }
    grid(
      columns: (auto, 1fr),
      row-gutter: 0.5em,
      ..rows.map(((l, v)) => (l, align(right)[#v])).flatten(),
    )
  }
  grid(
    columns: (4.2em, 1fr, 2.2in),
    column-gutter: (0pt, 1.5em),
    row-gutter: 0.9em,
    field-label("TO"), to.join(linebreak()),
    grid(columns: (auto, 1fr), field-label("DATE"), align(right)[#date]),
    field-label("FROM"), from.join(linebreak()), contact-stack,
    field-label("SUBJECT"), grid.cell(colspan: 2)[#strong(if subject != none { subject } else { [] })],
  )

  v(0.5em)
  line(length: 100%, stroke: 0.5pt + caltech-orange)
  v(0.3em)

  // --- Body ---
  doc
}
