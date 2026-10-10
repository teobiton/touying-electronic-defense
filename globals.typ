#import "master/lib.typ": *

#let palette = palette-colors("indigo")

// colors outisde of the palette
#let navy = rgb("#242a75")
#let teal = rgb("#2e9fb5")
#let dark-pink = rgb("#b5236f")
#let red = rgb("#d1242f")
#let ink = luma(25%)
#let muted = luma(40%)
#let soft = luma(94%)
#let scarlet = rgb("#c0392b")
#let scarlet-soft = scarlet.lighten(92%)
#let green = rgb("#2e7d32")
#let green-soft = green.lighten(92%)
#let fuschia = rgb("#c94b69")
#let mint = rgb("#4bc9ab").darken(15%)
#let lila = rgb("#6c4bc9")

#let arrow = $arrow.r.open$
#let green-tick = text(fill: green, weight: "bold")[$checkmark$]
#let warning-triangle = text(
  fill: red.lighten(10%),
  weight: "bold",
)[$triangle.stroked.nested$]

#let cite-at(idx, ..keys) = only(idx, keys.pos().map(k => cite(k)).join())
#let canvas(w, h, body) = box(width: w * 1pt, height: h * 1pt, body)
#let schematic(body, scale-value: 100%) = align(center, scale(
  scale-value,
  body,
  reflow: true,
))
#let hl(c, body) = text(fill: c, weight: "bold", body)
#let caption(body) = align(center, text(
  style: "italic",
  fill: muted,
  size: 0.8em,
  body,
))
#let key(body) = align(center, block(
  fill: teal.lighten(88%),
  inset: 0.6em,
  radius: 3pt,
  body,
))
#let encircle(n) = box(baseline: 0.2em, circle(
  radius: 0.62em,
  stroke: 0.8pt + navy,
  inset: 0pt,
  align(center + horizon, text(size: 0.8em, fill: navy, str(n))),
))

#let card(
  accent,
  title,
  body,
  height: auto,
  inset: (x: 9pt, y: 8pt),
  radius: 4pt,
  left-stroke: 2.5pt,
  title-size: 1em,
  body-size: 0.88em,
) = block(
  width: 100%,
  breakable: false,
  height: height,
  inset: inset,
  radius: radius,
  fill: accent.lighten(92%),
  stroke: (left: left-stroke + accent),
  {
    text(fill: accent, weight: "bold", size: title-size, title)
    v(-0.35em)
    text(size: body-size, body)
  },
)

#let pillar(title, question, fill: soft, stroke: muted) = rect(
  width: 100%,
  height: 100%,
  fill: fill.lighten(92%),
  stroke: (
    left: 1.8pt + fill.lighten(69%),
    top: 1.8pt + fill.lighten(69%),
    right: 1.8pt + fill.lighten(19%),
    bottom: 1.8pt + fill.lighten(19%),
  ),
  radius: 3pt,
  inset: 20pt,
)[
  #align(center + horizon, text(size: 1.05em, weight: "bold", title))
  #v(-.3em)
  #align(center, text(size: .8em, style: "italic", fill: fill, question))
]
