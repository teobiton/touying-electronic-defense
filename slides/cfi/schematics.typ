#import "/globals.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

#let _label(x, y, body) = place(top + left, dx: x * 1pt, dy: y * 1pt, body)

// Corrupted stack + ROP gadget
#let _rop-figure = {
  set text(size: 0.72em)
  let cell(y, body, name, fill: none) = node(
    (0, y),
    raw(body),
    name: name,
    width: 3.2cm,
    height: 1.7em,
    shape: rect,
    stroke: 1.2pt + navy,
    fill: fill,
    inset: 0pt,
  )
  let pad = luma(92%)
  diagram(
    spacing: (1.3cm, 0pt),
    edge-stroke: 1pt + navy,
    cell(0, "...", <s0>),
    cell(1, "0x1452", <s1>),
    cell(2, "0xc1a0", <s2>),
    cell(2.9, "0x1afa", <s3>),
    cell(3.55, "0x2250", <s4>, fill: red.lighten(85%)),
    cell(4.2, "0xAAAA", <s5>, fill: pad),
    cell(4.9, "0xAAAA", <s6>, fill: pad),
    cell(5.91, "0xAAAA", <s7>, fill: pad),
    node((0, 7.6), text(size: 1em, fill: ink, "stack")),
    node((-0.7, 3.55), [`sp` #sym.arrow.r], stroke: none, name: <sp>),
    node(
      (2, 3.6),
      align(left, raw(
        block: true,
        "lw ra, 0xc(sp)\nmv a0, a5\nli a1, 0\nret",
      )),
      stroke: 1.2pt + navy,
      fill: white,
      inset: 8pt,
      name: <g>,
    ),
    node((2, 5), text(size: 1em, fill: ink, "gadget")),
    edge(<s4>, <g>, "-|>", label: encircle(1), label-side: right),
    edge(<g>, <s3>, "-|>", label: encircle(2), label-side: right),
    edge(<s3>, <s2>, "-", bend: 73deg, label: encircle(3), label-side: right),
    edge(
      <s2>,
      <s1>,
      "-",
      bend: 89deg,
      label: [#encircle("n")],
      label-side: center,
    ),
  )
}

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

#let _arrow(
  from,
  to,
  color: ink,
  thickness: 1pt,
  dash: none,
  head: 6,
) = {
  let (x1, y1) = from
  let (x2, y2) = to
  let a = calc.atan2(x2 - x1, y2 - y1)
  let spread = 25deg
  let p1 = (x2 - head * calc.cos(a - spread), y2 - head * calc.sin(a - spread))
  let p2 = (x2 - head * calc.cos(a + spread), y2 - head * calc.sin(a + spread))
  // Stop the shaft at the base of the head so thick lines do not poke through.
  let (xe, ye) = (x2 - head * 0.8 * calc.cos(a), y2 - head * 0.8 * calc.sin(a))
  place(top + left, line(
    start: (x1 * 1pt, y1 * 1pt),
    end: (xe * 1pt, ye * 1pt),
    stroke: (paint: color, thickness: thickness, dash: dash),
  ))
  place(top + left, polygon(
    fill: color,
    stroke: none,
    (x2 * 1pt, y2 * 1pt),
    (p1.at(0) * 1pt, p1.at(1) * 1pt),
    (p2.at(0) * 1pt, p2.at(1) * 1pt),
  ))
}

#let _cross(x, y, size: 6, color: scarlet) = {
  let s = size
  place(top + left, line(
    start: ((x - s) * 1pt, (y - s) * 1pt),
    end: ((x + s) * 1pt, (y + s) * 1pt),
    stroke: 2pt + color,
  ))
  place(top + left, line(
    start: ((x - s) * 1pt, (y + s) * 1pt),
    end: ((x + s) * 1pt, (y - s) * 1pt),
    stroke: 2pt + color,
  ))
}

// Impact schematic: build-time compiler feeding a run-time stack
// (application / operating system / hardware platform).
// Each layer is `false` (untouched), `true` (modified) or "partial" (support only).
#let _impact(caption, app: false, compiler: false, os: false, hw: false) = {
  let style(state) = if state == true {
    (fill: scarlet-soft, stroke: 1.2pt + scarlet)
  } else if state == "partial" {
    (
      fill: scarlet-soft.lighten(60%),
      stroke: (paint: scarlet, thickness: 1.2pt, dash: "dashed"),
    )
  } else {
    (fill: soft, stroke: 0.6pt + muted)
  }
  let n(x, y, w, h, body, state) = {
    let s = style(state)
    _node(x, y, w, h, body, fill: s.fill, stroke: s.stroke)
  }
  box({
    set text(size: 10pt)
    canvas(172, 96, {
      n(0, 2, 62, 26, [Compiler], compiler)
      _arrow((62, 15), (76, 15), color: muted)
      n(76, 2, 96, 26, [Application], app)
      n(76, 34, 96, 26, [OS], os)
      n(76, 66, 96, 26, [Hardware], hw)
    })
    v(2pt)
    align(center, text(size: 10pt, weight: "bold", caption))
  })
}

#let _impact-legend = {
  set text(size: 9pt)
  box(width: 10pt, height: 8pt, fill: scarlet-soft, stroke: 1.2pt + scarlet)
  [ modified #h(8pt)]
  box(width: 10pt, height: 8pt, fill: scarlet-soft.lighten(60%), stroke: (
    paint: scarlet,
    thickness: 1.2pt,
    dash: "dashed",
  ))
  [ runtime support #h(8pt)]
  box(width: 10pt, height: 8pt, fill: soft, stroke: 0.6pt + muted)
  [ untouched]
}

#let _memory-injection = canvas(300, 196, {
  set text(size: 10pt)
  _label(0, 0, text(weight: "bold")[Stack #text(fill: muted)[(RW-)]])
  _node(0, 20, 110, 26, [local vars])
  _node(
    0,
    46,
    110,
    60,
    [*shellcode*],
    fill: scarlet-soft,
    stroke: 1pt + scarlet,
  )
  _node(
    0,
    106,
    110,
    26,
    [ret addr],
    fill: scarlet-soft,
    stroke: 1pt + scarlet,
  )
  _node(0, 132, 110, 26, [caller frame])

  _label(190, 0, text(weight: "bold")[Code #text(fill: muted)[(R-X)]])
  _node(190, 20, 110, 138, [application \ instructions])

  // ret addr -> back into the injected shellcode
  place(top + left, line(
    start: (110pt, 119pt),
    end: (145pt, 119pt),
    stroke: 1.2pt + scarlet,
  ))
  place(top + left, line(
    start: (145pt, 119pt),
    end: (145pt, 76pt),
    stroke: 1.2pt + scarlet,
  ))
  _arrow((145, 76), (111, 76), color: scarlet, thickness: 1.2pt)
  _cross(145, 97)
})

#let _memory-reuse = canvas(300, 196, {
  set text(size: 10pt)
  _label(0, 0, text(weight: "bold")[Stack #text(fill: muted)[(RW-)]])
  _node(0, 20, 110, 26, [local vars])
  _node(
    0,
    46,
    110,
    26,
    [&gadget 1],
    fill: scarlet-soft,
    stroke: 1pt + scarlet,
  )
  _node(
    0,
    72,
    110,
    26,
    [&gadget 2],
    fill: scarlet-soft,
    stroke: 1pt + scarlet,
  )
  _node(
    0,
    98,
    110,
    26,
    [&gadget 3],
    fill: scarlet-soft,
    stroke: 1pt + scarlet,
  )
  _node(0, 124, 110, 34, [...], fill: scarlet-soft, stroke: 1pt + scarlet)

  _label(190, 0, text(weight: "bold")[Code #text(fill: muted)[(R-X)]])
  _node(190, 20, 110, 138, [])
  _node(
    197,
    28,
    96,
    34,
    text(size: 9pt)[`ld a0, 0(sp)` \ `ret`],
    fill: white,
  )
  _node(197, 72, 96, 34, text(size: 9pt)[`mv a1, a0` \ `ret`], fill: white)
  _node(197, 116, 96, 34, text(size: 9pt)[`ecall` \ `ret`], fill: white)

  _arrow((110, 59), (196, 45), color: scarlet, thickness: 1.1pt)
  _arrow((110, 85), (196, 89), color: scarlet, thickness: 1.1pt)
  _arrow((110, 111), (196, 133), color: scarlet, thickness: 1.1pt)
})

#let _free-bsd = canvas(290, 46, {
  set text(size: 9pt)
  _node(
    0,
    0,
    88,
    22,
    [buffer: 128 B],
    fill: green-soft,
    stroke: 0.8pt + green,
  )
  _node(
    88,
    0,
    202,
    22,
    [copy up to 400 B],
    fill: scarlet-soft,
    stroke: 0.8pt + scarlet,
  )
  _label(90, 26, text(
    size: 8.5pt,
    fill: scarlet,
  )[#sym.arrow.t return address overwritten])
})

#let _cfg = canvas(270, 190, {
  set text(size: 10pt)
  _node(95, 0, 80, 28, [`main`])
  _node(0, 80, 80, 28, [`f`])
  _node(95, 80, 80, 28, [`g`])
  _node(190, 80, 80, 28, [`h`])
  _node(95, 158, 80, 30, [gadget], fill: scarlet-soft, stroke: 1pt + scarlet)

  // legitimate edges (in the static CFG)
  _arrow((115, 28), (45, 79), color: green, thickness: 1.2pt)
  _arrow((135, 28), (135, 79), color: green, thickness: 1.2pt)
  _arrow((160, 28), (225, 79), color: green, thickness: 1.2pt)
  // attacker-controlled edge, not in the CFG
  _arrow(
    (230, 108),
    (165, 157),
    color: scarlet,
    thickness: 1.2pt,
    dash: "dashed",
  )
  _cross(198, 132)
  _label(10, 40, text(size: 9pt, fill: green)[in the CFG])
  _label(210, 132, text(size: 9pt, fill: scarlet)[not in \ the CFG])
})

#let _shadow = canvas(290, 170, {
  set text(size: 10pt)
  _label(0, 0, text(weight: "bold")[Stack])
  _node(0, 20, 110, 26, [local vars])
  _node(
    0,
    46,
    110,
    26,
    [ret addr],
    fill: scarlet-soft,
    stroke: 1pt + scarlet,
  )
  _node(0, 72, 110, 26, [caller frame])

  _label(180, 0, text(weight: "bold")[Shadow stack])
  _node(
    180,
    20,
    110,
    26,
    [ret addr],
    fill: green-soft,
    stroke: 1pt + green,
  )
  _node(180, 46, 110, 26, [...], fill: green-soft, stroke: 1pt + green)

  place(top + left, line(start: (112pt, 59pt), end: (178pt, 33pt), stroke: (
    paint: ink,
    thickness: 1pt,
    dash: "dashed",
  )))
  _label(122, 18, text(size: 9.5pt, fill: ink)[compare])

  _label(0, 108, box(width: 290pt, align(center, text(size: 12.5pt)[
    `call`: push the return address on *both* stacks \
    `ret`: pop both and *compare*
  ])))
  _label(0, 146, box(width: 290pt, align(center, text(
    size: 12.5pt,
    fill: scarlet,
  )[
    mismatch $arrow$ fault: the overwritten return address is caught
  ])))
})

#let k = 0.53pt
#let P(x, y) = (k * x, -k * y) // drawing coords (y down) -> fletcher xy (y up)

#let w-box = 2 * k // block outlines
#let w-rule = 1 * k // table rules
#let w-arrow = 2 * k // arrows
#let w-bubble = 1.2 * k // callout circles

#let BW = 193 // block width
#let BH = 91 // block height
#let PAD = 8 // text inset inside a block
#let LP = 25.5 // code line pitch
#let FS = 21.2 // code size
#let TS = 22 // caption size

#let code-block(x0, y0, ..lines) = node(
  P(x0 + BW / 2, y0 + BH / 2),
  box(
    width: BW * k,
    height: BH * k,
    inset: (left: PAD * k),
    align(
      left + horizon,
      grid(
        rows: (LP * k,) * lines.pos().len(),
        align: left + horizon,
        ..lines.pos().map(l => text(size: FS * k, weight: "bold", l)),
      ),
    ),
  ),
  stroke: w-box + navy,
  fill: white,
  inset: 0pt,
)

// The bold caption that sits just above a block.
#let block-title(x0, mid, body) = node(
  P(x0 + BW / 2, mid),
  box(
    width: BW * k,
    align(left, text(size: TS * k, weight: "semibold", body)),
  ),
  stroke: none,
  inset: 0pt,
)

// A lettered callout bubble.
#let bubble(cx, cy, body) = node(
  P(cx, cy),
  text(size: TS * k, body),
  shape: fletcher.shapes.ellipse,
  width: 46 * k,
  height: 39 * k,
  stroke: w-bubble + navy,
  fill: soft,
  inset: 0pt,
)

// An orthogonal arrow through a list of waypoints.
#let flow(..pts) = edge(
  ..pts.pos().map(((x, y)) => P(x, y)),
  "-|>",
  stroke: w-arrow + navy,
  mark-scale: 100%,
)

// The jump table: five entries and an ellipsis.
// Built with `grid`, not `table`, so a `show table:` rule in a slide theme
// cannot restyle it.
#let jump-table = grid(
  columns: (187 * k,),
  rows: (33.5 * k,) * 6,
  stroke: w-rule + navy,
  fill: white,
  inset: (left: PAD * k, rest: 0pt),
  align: left + horizon,
  raw("0x1804"),
  raw("0x0812"),
  raw("0x2304"),
  raw("0x3744"),
  raw("0x6700"),
  [#"..."],
)

// ===========================================================================
#let _jop-figure = diagram(edge-corner-radius: 0pt, {
  // ---- caller --------------------------------------------------------------
  block-title(40, 29)[Initializer gadget]
  code-block(40, 43, [lw a5, 8(sp)], [lw s1, 12(sp)], [jr a5])

  // ---- dispatcher ----------------------------------------------------------
  block-title(260, 133)[Dispatcher gadget]
  code-block(260, 149, [lw a6, 0(s1)], [addi s1, s1, 4], [jr a6])

  // ---- jump table ----------------------------------------------------------
  block-title(580, 135)[Dispatch table]
  node(
    P(673, 251.5),
    text(size: FS * k, jump-table),
    stroke: none,
    inset: 0pt,
  )

  // ---- callees: a pile of identical blocks ---------------------------------
  block-title(249, 290)[Functional gadgets]
  for (ox, oy) in ((19, -22), (9, -11)) {
    node(
      P(223 + ox + BW / 2, 328 + oy + BH / 2),
      [],
      width: BW * k,
      height: BH * k,
      stroke: w-box + navy,
      fill: white,
      inset: 0pt,
    )
  }
  code-block(223, 328, [#"..."], [#"..."], [jr a5])

  // ---- control flow --------------------------------------------------------
  // (a) caller tail-jumps into the dispatcher
  flow((259, 81.5), (350, 81.5), (350, 120))
  // (b) the dispatcher walks the table of target addresses
  edge(
    P(466, 167.5),
    P(559, 167.5),
    "<|-|>",
    stroke: (thickness: w-arrow, dash: (6.5 * k, 5 * k), paint: navy),
    mark-scale: 100%,
  )
  // (c) dispatcher jumps to the selected callee
  flow((243, 211.5), (176.5, 211.5), (176.5, 346.5), (208, 346.5))
  // (d) callee returns to the dispatcher
  flow((209, 386.5), (142.5, 386.5), (142.5, 168.5), (238, 168.5))

  // ---- callouts ------------------------------------------------------------
  bubble(308.5, 54)[a]
  bubble(512.5, 132)[b]
  bubble(210.5, 245)[c]
  bubble(107, 358)[d]
})

