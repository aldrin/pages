#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(font: "IBM Plex Serif", size: 8pt)

#let sans = "IBM Plex Sans"
#let fg = luma(40)
#let mid = luma(110)
#let sub(body) = text(size: 6pt, fill: mid, body)
#let label(body) = text(font: sans, size: 8pt, weight: "medium", fill: fg, body)
#let bold-label(body) = text(font: sans, size: 10pt, weight: "bold", fill: fg, body)

#diagram(
  node-stroke: 0.6pt + luma(180),
  node-fill: luma(245),
  node-corner-radius: 4pt,
  spacing: (24pt, 16pt),
  edge-stroke: 0.6pt + mid,

  // Row 0: visuals pipeline
  node((0, 0), [#label[plots/] \ #sub[plotnine]]),
  edge((0, 0), (1, 0), "-|>"),
  node((1, 0), [#label[images/] \ #sub[SVG]], stroke: 0.8pt + luma(140)),
  edge((2, 0), (1, 0), "-|>"),
  node((2, 0), [#label[diagrams/] \ #sub[CeTZ, fletcher]]),

  // images/ feeds down into make
  edge((1, 0), (1, 1), "-|>"),

  // Row 1: document pipeline
  node((0, 1), [#bold-label[.org] \ #sub[write here]], stroke: 0.8pt + luma(100)),
  edge((0, 1), (1, 1), "-|>"),
  node((1, 1), [#label[make] \ #sub[pandoc + typst]], fill: luma(250), stroke: 0.7pt + luma(150)),
  edge((1, 1), (2, 1), "-|>"),
  node((2, 1), [#bold-label[.pdf] \ #sub[docs/]], stroke: 0.8pt + luma(100)),
)
