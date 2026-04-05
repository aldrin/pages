#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set page(width: auto, height: auto, margin: 8pt, fill: none)
#set text(font: "IBM Plex Serif", size: 8pt)

#let sans = "IBM Plex Sans"
#let mono = "IBM Plex Mono"
#let fg = luma(40)
#let mid = luma(110)

#let detail(body) = text(font: sans, size: 6.5pt, fill: luma(130), body)
#let cmd(body) = text(font: mono, size: 7.5pt, fill: fg, body)
#let label(body) = text(font: sans, size: 8pt, weight: "medium", fill: fg, body)

#diagram(
  node-stroke: 0.6pt + luma(150),
  node-fill: luma(248),
  node-corner-radius: 3pt,
  spacing: (20pt, 14pt),
  edge-stroke: 0.6pt + mid,

  // Row 0: init -> build -> run
  node((0, 0), [#cmd[init] \ #detail[scaffolds config]]),
  edge((0, 0), (1, 0), "-|>"),
  node((1, 0), [#cmd[build] \ #detail[installs Claude Code]]),
  edge((1, 0), (2, 0), "-|>"),
  node((2, 0), [#cmd[run] \ #detail[launches session]], stroke: 0.8pt + luma(100), fill: luma(240)),

  // Row 1: claude auth login -> keychain
  node((1, 1), [#cmd[claude auth login] \ #detail[on host]]),
  edge((1, 1), (2, 1), "-|>"),
  node((2, 1), [#label[keychain] \ #detail[OAuth token]]),

  // keychain -> run
  edge((2, 1), (2, 0), "-|>"),
)
