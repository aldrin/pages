// ajd.typ -- Document template for technical narrative
//
// Fonts: IBM Plex Serif (body), IBM Plex Sans (headings/UI), IBM Plex Mono (code).
// Install via: brew install --cask font-ibm-plex-serif font-ibm-plex-sans font-ibm-plex-mono
// Geometry: US Letter, 20mm margins, ~70 characters per line.

#let serif = ("IBM Plex Serif",)
#let sans  = ("IBM Plex Sans",)
#let mono  = ("IBM Plex Mono",)
#let accent = rgb("#4682B4")

// -- Custom blocks -----------------------------------------------------------

#let callout(kind: "note", body) = {
  let colors = (
    note: accent,
    tip: rgb("#2d8a4e"),
    warning: rgb("#d4942a"),
    important: rgb("#c44040"),
  )
  let labels = (
    note: "Note",
    tip: "Tip",
    warning: "Warning",
    important: "Important",
  )
  let color = colors.at(kind, default: accent)
  block(
    width: 100%,
    inset: (left: 12pt, right: 10pt, top: 8pt, bottom: 8pt),
    stroke: (left: 2.5pt + color),
    fill: color.lighten(92%),
    radius: (right: 2pt),
    {
      text(size: 8pt, weight: "bold", fill: color, font: sans,
        upper(labels.at(kind, default: "Note")))
      v(3pt)
      text(size: 9.5pt, body)
    },
  )
}

#let aside(body) = block(
  width: 100%,
  inset: 10pt,
  fill: luma(247),
  radius: 2pt,
  text(size: 9.5pt, fill: luma(60), body),
)

#let key-point(body) = block(
  width: 100%,
  inset: 10pt,
  fill: accent.lighten(90%),
  radius: 2pt,
  stroke: 0.5pt + accent.lighten(60%),
  text(size: 10pt, body),
)

#let twocol(body) = {
  set par.line(numbering: none)
  columns(2, gutter: 12pt, body)
}

// -- Document configuration --------------------------------------------------

#let conf(
  title: none,
  subtitle: none,
  authors: (),
  keywords: (),
  date: none,
  lang: "en",
  region: "US",
  abstract-title: none,
  abstract: none,
  thanks: none,
  margin: (:),
  paper: "us-letter",
  font: (),
  fontsize: 10.5pt,
  mathfont: (),
  codefont: (),
  linestretch: auto,
  sectionnumbering: none,
  pagenumbering: "1",
  linkcolor: accent,
  citecolor: auto,
  filecolor: auto,
  cols: 1,
  doc,
) = {
  // -- Page ------------------------------------------------------------------
  set page(
    paper: paper,
    margin: (top: 24mm, bottom: 20mm, left: 20mm, right: 20mm),
    numbering: pagenumbering,
    header: context {
      set text(size: 8pt, fill: luma(140), font: sans)
      if counter(page).get().first() == 1 {
        h(1fr)
        if authors.len() > 0 { authors.map(a => a.name).join(", ") }
      } else {
        if title != none { smallcaps(title) }
        h(1fr)
        counter(page).display()
      }
    },
    footer: context {
      set text(size: 7.5pt, fill: luma(160), font: sans)
      if date != none { date }
      h(1fr)
      text(fill: luma(200), [CC BY 4.0])
      h(1fr)
      counter(page).display("1 of 1", both: true)
    },
  )

  // -- Body text -------------------------------------------------------------
  set text(
    font: if font.len() > 0 { font } else { serif },
    size: fontsize,
    lang: lang,
    region: region,
  )

  set par(leading: 0.65em, spacing: 1.2em, justify: true)
  set par.line(
    numbering: n => text(size: 6pt, fill: luma(200), font: sans, str(n)),
    number-clearance: 8pt,
  )

  // -- Headings --------------------------------------------------------------
  set heading(numbering: sectionnumbering)
  show heading: set text(font: sans)

  show heading.where(level: 1): it => {
    v(0.7em)
    text(size: 12pt, weight: "medium", it.body)
    v(0.2em)
  }

  show heading.where(level: 2): it => {
    v(0.5em)
    text(size: 10.5pt, weight: "medium", it.body)
    v(0.1em)
  }

  show heading.where(level: 3): it => {
    v(0.4em)
    text(size: 10.5pt, weight: "medium", it.body + [.])
    h(0.5em)
  }

  // -- Block quotes ----------------------------------------------------------
  show quote: it => {
    set text(size: 10pt, style: "italic", fill: luma(60))
    block(
      inset: (left: 14pt, right: 14pt, top: 6pt, bottom: 6pt),
      stroke: (left: 2.5pt + accent.lighten(40%)),
      it.body,
    )
  }

  // -- Code ------------------------------------------------------------------
  show raw.where(block: true): it => {
    set text(size: 8.5pt, font: mono)
    block(width: 100%, inset: 6pt, fill: rgb("#F5F5F5"), radius: 1pt, it)
  }
  show raw.where(block: false): set text(size: 9pt, font: mono)

  // -- Links -----------------------------------------------------------------
  show link: set text(fill: linkcolor)

  // -- Footnotes -------------------------------------------------------------
  set footnote.entry(separator: line(length: 25%, stroke: 0.3pt + luma(160)))
  show footnote.entry: set text(size: 8.5pt)

  // -- Tables ----------------------------------------------------------------
  set table(inset: (x: 6pt, y: 4pt), stroke: none)
  show table: set text(size: 9.5pt)
  show table.cell.where(y: 0): set text(size: 8.5pt, weight: "medium", font: sans)
  show table.cell.where(y: 0): set table.cell(
    stroke: (bottom: 0.6pt + luma(180)),
    inset: (x: 6pt, y: 5pt),
  )

  // -- Figures ---------------------------------------------------------------
  show figure.where(kind: table): set align(center)
  show figure.where(kind: table): set figure.caption(position: bottom)
  show figure.caption: set text(size: 9pt, fill: luma(100), style: "italic")

  // -- Lists -----------------------------------------------------------------
  set list(indent: 1.2em, spacing: 0.4em)
  set enum(indent: 1.2em, spacing: 0.4em)

  // -- Title block -----------------------------------------------------------
  if title != none {
    text(size: 17pt, weight: "bold", font: sans, title)
    v(0.6em)
  }

  // -- Abstract --------------------------------------------------------------
  if abstract != none {
    block(inset: (left: 1.5em, right: 1.5em), {
      if abstract-title != none {
        text(weight: "bold", size: 9pt, font: sans, upper(abstract-title))
        v(0.2em)
      }
      text(size: 9.5pt, abstract)
    })
    v(0.6em)
  }

  doc
}
