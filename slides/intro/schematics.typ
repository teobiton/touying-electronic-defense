#import "/globals.typ": *

#let _node(
  x,
  y,
  w,
  h,
  body,
  fill: soft,
  stroke: 0.8pt + ink,
  radius: 3pt,
) = place(
  top + left,
  dx: x * 1pt,
  dy: y * 1pt,
  rect(
    width: w * 1pt,
    height: h * 1pt,
    fill: fill,
    stroke: stroke,
    radius: radius,
    inset: 2pt,
  )[
    #set align(center + horizon)
    #body
  ],
)

#let _label(x, y, body) = place(top + left, dx: x * 1pt, dy: y * 1pt, body)

#let _seg(from, to, color: ink, thickness: 1pt, dash: none) = place(
  top + left,
  line(
    start: (from.at(0) * 1pt, from.at(1) * 1pt),
    end: (to.at(0) * 1pt, to.at(1) * 1pt),
    stroke: (paint: color, thickness: thickness, dash: dash),
  ),
)

#let _arrow(from, to, color: ink, thickness: 1pt, dash: none, head: 6) = {
  let (x1, y1) = from
  let (x2, y2) = to
  let a = calc.atan2(x2 - x1, y2 - y1)
  let spread = 25deg
  let p1 = (x2 - head * calc.cos(a - spread), y2 - head * calc.sin(a - spread))
  let p2 = (x2 - head * calc.cos(a + spread), y2 - head * calc.sin(a + spread))
  let tail = (x2 - head * 0.8 * calc.cos(a), y2 - head * 0.8 * calc.sin(a))
  _seg(from, tail, color: color, thickness: thickness, dash: dash)
  place(top + left, polygon(
    fill: color,
    stroke: none,
    (x2 * 1pt, y2 * 1pt),
    (p1.at(0) * 1pt, p1.at(1) * 1pt),
    (p2.at(0) * 1pt, p2.at(1) * 1pt),
  ))
}

#let _cross(x, y, size: 7, color: scarlet) = {
  _seg(
    (x - size, y - size),
    (x + size, y + size),
    color: color,
    thickness: 2.2pt,
  )
  _seg(
    (x - size, y + size),
    (x + size, y - size),
    color: color,
    thickness: 2.2pt,
  )
}

// The running example: the car's door-unlocking program, as a flowchart.
//   hijack: draw the attacker's shortcut that skips the key check
//   guard:  the shortcut is caught (not on the map of allowed routes)
#let _flow(hijack: false, guard: false) = canvas(290, 196, {
  set text(size: 10.5pt)
  _node(90, 12, 120, 34, [Receive the \ key's signal])
  _node(
    90,
    76,
    120,
    34,
    [Is the key valid?],
    fill: white,
    stroke: 1.2pt + ink,
  )
  _node(
    0,
    156,
    120,
    34,
    [Unlock the doors],
    fill: green-soft,
    stroke: 0.8pt + green,
  )
  _node(170, 156, 120, 34, [Stay locked])

  _arrow((150, 46), (150, 75))
  _arrow((125, 110), (60, 155), color: green, thickness: 1.2pt)
  _arrow((175, 110), (230, 155))
  _label(70, 122, text(size: 9.5pt, fill: green)[yes])
  _label(210, 122, text(size: 9.5pt)[no])

  _arrow((264, 29), (210, 29))
  _seg((264, 29), (264, 155))

  if hijack {
    // Jump from "receive" straight to "unlock", bypassing the check.
    _seg((90, 29), (24, 29), color: scarlet, thickness: 1.6pt, dash: "dashed")
    _arrow(
      (24, 29),
      (24, 155),
      color: scarlet,
      thickness: 1.6pt,
      dash: "dashed",
    )
    _label(0, 0, text(
      size: 9.5pt,
      fill: scarlet,
      weight: "bold",
    )[attacker's shortcut])
    if guard {
      _cross(24, 92)
      _label(36, 84, text(size: 9.5pt, fill: scarlet)[not on \ the map])
    }
  }
})

// Zoom from the object down to its program: car -> control unit -> processor -> program.
#let _zoom = canvas(640, 116, {
  set text(size: 11pt)
  let w = 128
  let h = 84
  let gap = 42
  let x(i) = i * (w + gap)
  let caption(i, body) = _label(x(i), h + 8, box(width: w * 1pt, align(
    center,
    text(size: 9.5pt, fill: muted, body),
  )))
  _node(x(0), 0, w, h, [*A car*])
  _node(x(1), 0, w, h, [*Door control unit*])
  _node(x(2), 0, w, h, [*Processor*])
  _node(x(3), 0, w, h, fill: green-soft, stroke: 1pt + green)[
    #set align(left)
    #set text(size: 10pt)
    #pad(left: 6pt)[
      *Program* \
      1. read the car's key \
      2. check the key \
      3. unlock
    ]
  ]
  caption(0, [the device])
  caption(1, [one of its small computers])
  caption(2, [the chip that executes])
  caption(3, [steps written by developers])
  for i in range(3) {
    _arrow(
      (x(i) + w + 4, h / 2),
      (x(i + 1) - 4, h / 2),
      color: muted,
      thickness: 1.2pt,
    )
  }
})
