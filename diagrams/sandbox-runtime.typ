#set page(width: auto, height: auto, margin: 12pt, fill: none)
#set text(font: "IBM Plex Serif", size: 8pt)

#let sans = "IBM Plex Sans"
#let fg = luma(40)
#let mid = luma(110)

#let layer-label(body) = text(font: sans, size: 6.5pt, fill: mid, body)
#let node-label(body) = text(font: sans, size: 8pt, weight: "medium", fill: fg, body)
#let bold-label(body) = text(font: sans, size: 9pt, weight: "bold", fill: fg, body)
#let detail(body) = text(font: sans, size: 6.5pt, fill: luma(130), body)

#grid(
  columns: (auto, auto, auto),
  align: center + horizon,
  column-gutter: 14pt,

  // Left: Host
  box(
    width: 120pt,
    stroke: 0.6pt + luma(180),
    radius: 6pt,
    fill: luma(252),
    inset: (top: 22pt, bottom: 14pt, left: 14pt, right: 14pt),
  )[
    #place(top + left, dx: 10pt, dy: -15pt,
      box(fill: luma(252), inset: (x: 4pt), layer-label[Host]))

    #align(center)[
      #box(
        stroke: 0.8pt + luma(120),
        radius: 3pt,
        fill: white,
        inset: (x: 16pt, y: 10pt),
        {
          node-label[project/]
          v(2pt)
          detail[your code]
        },
      )
    ]
  ],

  // Arrow: bind mount
  {
    detail[bind mount]
    v(2pt)
    text(size: 16pt, fill: luma(160), sym.arrow.l.r)
  },

  // Right: Apple Container VM
  box(
    width: 260pt,
    stroke: 0.8pt + luma(140),
    radius: 5pt,
    fill: luma(245),
    inset: (top: 22pt, bottom: 14pt, left: 16pt, right: 16pt),
  )[
    #place(top + left, dx: 10pt, dy: -15pt,
      box(fill: luma(245), inset: (x: 4pt), node-label[Apple Container VM]))
    #place(top + right, dx: -10pt, dy: -15pt,
      box(fill: luma(245), inset: (x: 4pt), detail[limits data access]))

    #box(
      width: 100%,
      stroke: 0.8pt + luma(100),
      radius: 4pt,
      fill: luma(237),
      inset: (top: 22pt, bottom: 14pt, left: 16pt, right: 16pt),
    )[
      #place(top + left, dx: 10pt, dy: -15pt,
        box(fill: luma(237), inset: (x: 4pt), node-label[bubblewrap sandbox]))
      #place(top + right, dx: -10pt, dy: -15pt,
        box(fill: luma(237), inset: (x: 4pt), detail[limits code + network]))

      #align(center)[
        #box(
          stroke: 0.8pt + luma(60),
          radius: 3pt,
          fill: luma(228),
          inset: (x: 24pt, y: 10pt),
          bold-label[Claude Code],
        )
      ]
    ]
  ],
)
