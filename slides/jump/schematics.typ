#import "/globals.typ": *
#import "/master/lib.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

// Notation
#let As = $italic("As")$
#let Ad = $italic("Ad")$
#let Tga = $italic("Tga")$
#let Nent = $N_"entries"$
#let Gth = $G_"threshold"$
#let Ddisp = $D_"dispatcher"$
#let RD = $R_D$
#let RF = $R_F$

// Fan-in (gadgets -> dispatcher) or fan-out (dispatcher -> gadgets)
#let _fan(out: false) = {
  set text(size: 0.9em)
  let box-node(pos, body, name, c) = node(
    pos,
    body,
    name: name,
    stroke: 1.2pt + c,
    fill: c.lighten(88%),
    width: 2.4cm,
    inset: 7pt,
  )
  let x = if out { 2 } else { 0 }
  let reg = if out { RF } else { RD }
  diagram(
    spacing: (2.2cm, 0.45cm),
    edge-stroke: 1.3pt + teal,
    ..range(3).map(i => box-node(
      (x, i),
      $"FG"_#i$,
      label("f" + str(i)),
      navy,
    )),
    box-node((1, 1), [DG], <dg>, fuschia),
    ..range(3).map(i => {
      let (a, b) = if out { (<dg>, label("f" + str(i))) } else {
        (label("f" + str(i)), <dg>)
      }
      edge(a, b, "-|>", label: if i == 0 { reg }, label-side: left)
    }),
  )
}

// The three steps of the algorithm
#let _steps = {
  set text(size: 0.85em)
  let step(pos, body, name) = node(
    pos,
    body,
    name: name,
    stroke: 1.2pt + navy,
    fill: navy.lighten(85%),
    width: 5.2cm,
    height: 2.3cm,
  )
  let note(pos, body) = node(
    pos,
    text(fill: muted, style: "italic", body),
    stroke: none,
  )
  diagram(
    spacing: (0.9cm, 0.5cm),
    edge-stroke: 1.3pt + teal,
    node((0, 0), [#As, #Ad, $R$,\ instr. type], name: <in>, stroke: none),
    step((1, 0), [*Jump\ identification*], <s1>),
    step((2, 0), [*Control-flow\ state tracking*], <s2>),
    step((3, 0), [*Decision\ response*], <s3>),
    node((4, 0), hl(red)[alarm], name: <out>, stroke: none),
    note((1, 1), [indirect jump?]),
    note((2, 1), [two mirrored LRU caches]),
    note((3, 1), [three conditions]),
    edge(<in>, <s1>, "-|>"),
    edge(<s1>, <s2>, "-|>"),
    edge(<s2>, <s3>, "-|>"),
    edge(<s3>, <out>, "-|>", stroke: 1.3pt + red),
  )
}

// Execution trace of the running example (Table IV.1)
#let _trace-rows = (
  ("0", "0x5B8C", "0x3FAA", "x6", $"IG" -> "DG"$),
  ("1", "0x3FC0", "0x7E50", "x7", $"DG" -> "FG"_0$),
  ("2", "0x7E72", "0x3FAA", "x6", $"FG"_0 -> "DG"$),
  ("3", "0x3FC0", "0x4BB8", "x7", $"DG" -> "FG"_1$),
  ("4", "0x4BE4", "0x3FAA", "x6", $"FG"_1 -> "DG"$),
  ("5", "0x3FC0", "0x12D4", "x7", $"DG" -> "FG"_2$),
)
#let _trace(highlight: false, row: none) = {
  set text(size: 0.8em)
  if row != none {
    assert(row >= 0 and row <= 5)
  }
  let hi(step, body, ..args) = if int(step) == row {
    table.cell(fill: navy.lighten(85%), body, ..args)
  } else { body }
  let a(s) = if highlight and (s == "0x3FAA" or s == "0x3FC0") {
    hl(mint, raw(s))
  } else { raw(s) }
  let r(s) = if highlight { hl(fuschia, raw(s)) } else { raw(s) }
  table(
    columns: 5,
    align: center + horizon,
    stroke: none,
    inset: (x: 0.7em, y: 0.4em),
    table.hline(stroke: 1pt),
    table.header([*Step*], [*#As*], [*#Ad*], [*$R$*], [*Transition*]),
    table.hline(stroke: 0.6pt),
    .._trace-rows
      .map(((s, src, dst, reg, tr)) => (
        hi(s, s),
        hi(s, a(src)),
        hi(s, a(dst)),
        hi(s, r(reg)),
        hi(s, tr),
      ))
      .flatten(),
    table.hline(stroke: 1pt),
  )
}

// One cache (functional: kind "f", dispatcher: kind "d").
// rows: array of (reg, tag address, gadget address, counter, state)
// with state in ("new", "hit", none)
#let _cache(kind, rows) = {
  set text(size: 0.8em)
  let (k, t) = if kind == "f" { (Ad, As) } else { (As, Ad) }
  let body = ()
  for i in range(3) {
    body.push([*#i*])
    if i < rows.len() {
      let (r, key, tga, cnt, st) = rows.at(i)
      let fill = if st == "hit" { mint.lighten(80%) } else if st == "new" {
        luma(93%)
      } else { none }
      let c(x) = table.cell(fill: fill, x)
      body += (
        c(text(fill: fuschia, raw("x" + str(r)))),
        c(raw(key)),
        c(raw(tga)),
        c(if cnt >= 2 { hl(lila, str(cnt)) } else { str(cnt) }),
      )
    } else {
      body += ([], [], [], [])
    }
  }
  block(breakable: false)[
    #align(center, text(style: "italic")[#if (
      kind == "f"
    ) [Functional cache] else [Dispatcher cache]])
    #table(
      columns: (2em, 2.6em, 5.2em, 5.2em, 2.4em),
      align: center + horizon,
      stroke: 0.8pt + navy,
      inset: (x: 0.3em, y: 0.45em),
      table.header([], [*$R$*], [*#k*], [*#t*], [*cnt*]),
      ..body,
    )
  ]
}

// Cache states after each step of the running example (Table IV.2)
#let _states = (
  (
    f: ((6, "0x3FAA", "0x5B8C", 1, "new"),),
    d: ((6, "0x5B8C", "0x3FAA", 1, "new"),),
  ),
  (
    f: ((7, "0x7E50", "0x3FC0", 1, "new"), (6, "0x3FAA", "0x5B8C", 1, none)),
    d: ((7, "0x3FC0", "0x7E50", 1, "new"), (6, "0x5B8C", "0x3FAA", 1, none)),
  ),
  (
    f: ((6, "0x3FAA", "0x7E72", 2, "hit"), (7, "0x7E50", "0x3FC0", 1, none)),
    d: (
      (6, "0x7E72", "0x3FAA", 1, "new"),
      (7, "0x3FC0", "0x7E50", 1, none),
      (6, "0x5B8C", "0x3FAA", 1, none),
    ),
  ),
  (
    f: (
      (7, "0x4BB8", "0x3FC0", 1, "new"),
      (6, "0x3FAA", "0x7E72", 2, none),
      (7, "0x7E50", "0x3FC0", 1, none),
    ),
    d: (
      (7, "0x3FC0", "0x4BB8", 2, "hit"),
      (6, "0x7E72", "0x3FAA", 1, none),
      (6, "0x5B8C", "0x3FAA", 1, none),
    ),
  ),
)

#let _cache-step(i) = {
  schematic(_trace(row: i, highlight: true), scale-value: 100%)
  let step = 1.2em
  place(dx: 25%, dy: -46.2% + i * step, text(size: 1.7em, fill: navy, arrow))
  v(0.3em)
  align(center, grid(
    columns: 2,
    column-gutter: 1.6em,
    _cache("f", _states.at(i).f), _cache("d", _states.at(i).d),
  ))
}

// Proof structure: P1 / P2 / P3
#let _proof = {
  set text(size: 0.8em)
  diagram(
    spacing: (2.2cm, 1cm),
    edge-stroke: 1.2pt + teal,
    node((0, 0), [Init], name: <init>, stroke: 1.2pt + muted, inset: 8pt),
    edge(<init>, <inv>, "-|>", label: [$P_1$], label-side: left),
    node(
      (1, 0),
      [$cal(I)$],
      name: <inv>,
      shape: circle,
      stroke: 1.5pt + navy,
      fill: navy.lighten(85%),
      radius: 0.6cm,
    ),
    edge(<inv>, <inv>, "-|>", bend: 130deg, loop-angle: 90deg, label: [$P_2$]),
    node(
      (2, 0),
      hl(red)[alarm],
      name: <al>,
      stroke: 1.2pt + red,
      inset: 8pt,
    ),
    edge(
      <inv>,
      <al>,
      "-|>",
      stroke: 1.2pt + red,
      label: [$P_3$],
      label-side: left,
    ),
  )
}

#let k = 0.47pt
#let P(x, y) = (k * x, -k * y) // drawing coords (y down) -> fletcher xy (y up)

#let w-box = 2 * k // block outlines
#let w-arrow = 2 * k // arrows

#let BW = 193 // block width
#let BH = 91 // block height
#let PAD = 8 // text inset inside a block
#let LP = 25.5 // code line pitch
#let FS = 21.2 // code size
#let TS = 22 // caption size

#let GX = 60          // horizontal gap between blocks
#let GY = 75          // vertical gap between blocks
#let HS = BW + GX     // column pitch
#let VS = BH + GY     // row pitch

#let SVS = BH + (GY / 2)

#let code-block(x0, y0, name: none, ..lines) = node(
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
        ..lines.pos().map(l => text(size: FS * k, weight: "medium", l)),
      ),
    ),
  ),
  name: name,
  stroke: w-box + navy,
  fill: white,
  inset: 0pt,
)

#let block-title(x0, mid, body) = node(
  P(x0 + BW / 2, mid),
  box(
    width: BW * k,
    align(left, text(size: TS * k, fill: muted, weight: "regular", body)),
  ),
  stroke: none,
  inset: 0pt,
)

#let arrow-edge(from, to) = edge(
  from,
  to,
  "-|>",
  stroke: w-arrow + navy.darken(5%),
)

#let flow(..pts) = edge(
  ..pts.pos().map(((x, y)) => P(x, y)),
  "-",
  stroke: w-arrow + muted,
  mark-scale: 100%,
)

// (1) Two FGs feed one shared DG
#let _disp_reg_trans = diagram(edge-corner-radius: 0pt, {
  block-title(HS / 2, -20)[Functional gadgets]
  code-block(0, 0, name: <fg0>, [#"..."], [#"..."], [jr #hl(fuschia)[a5]])
  code-block(HS, 0, name: <fg1>, [#"..."], [#"..."], [jr #hl(mint)[s2]])

  block-title(HS / 2, VS + BH + 20)[Dispatcher gadget]
  code-block(HS / 2, VS, name: <dg>, [lw a6, 0(s1)], [addi s1, s1, 4], [jr a6])

  arrow-edge(<fg0>, <dg>)
  arrow-edge(<fg1>, <dg>)
})

// (2) One DG per FG
#let _parallel_disp = diagram(edge-corner-radius: 0pt, {
  block-title(HS / 2, -20)[Functional gadgets]
  code-block(0, 0, name: <fg0>, [#"..."], [#"..."], [jr a5])
  code-block(HS, 0, name: <fg1>, [#"..."], [#"..."], [jr a5])

  block-title(HS / 2, VS + BH + 20)[Dispatcher gadgets]
  code-block(
    0,
    VS,
    name: <dg0>,
    [lw #hl(fuschia)[a6], 0(s1)],
    [addi s1, s1, 4],
    [jr #hl(fuschia)[a6]],
  )
  code-block(
    HS,
    VS,
    name: <dg1>,
    [lw #hl(mint)[s6], 0(s1)],
    [addi s1, s1, 4],
    [jr #hl(mint)[s6]],
  )
  arrow-edge(<fg0>, <dg0>)
  arrow-edge(<fg1>, <dg1>)
})

// (3) Chained DGs
#let _serial_disp = diagram(edge-corner-radius: 0pt, {
  block-title(15, -20)[Functional gadget]
  code-block(0, 0, name: <fg0>, [#"..."], [#"..."], [jr a5])

  block-title(15, 370)[Dispatcher gadgets]
  code-block(0, SVS, name: <dg0>, [jr #hl(mint)[s6]])
  code-block(0, 2 * SVS, name: <dg1>, [lw a6, 0(s1)], [addi s1, s1, 4], [jr a6])
  arrow-edge(<fg0>, <dg0>)
  arrow-edge(<dg0>, <dg1>)
  flow((195, 120), (202, 120), (202, 357), (195, 357))
})
