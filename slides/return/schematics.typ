#import "/globals.typ": *
#import "/master/lib.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let call-rw = hl(dark-pink)[◀◀]
#let rap = $"ra"_p$

#let diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

// Nominal call/return (rewind: false) or with call rewinding (rewind: true)
#let _call-panel(rewind: false) = {
  set text(size: 0.7em)
  let l(pos, body, name) = node(
    pos,
    align(left, raw(body)),
    name: name,
    width: 4.2cm,
    inset: 1.5pt,
    snap: false,
  )
  diagram(
    spacing: (1.2cm, 0.12cm),
    node-stroke: none,
    node-defocus: 0,
    mark-scale: 70%,
    l((0, 0), "f:", <m0>),
    l((0, 1), "  ...", <m1>),
    l((0, 2), "  call g", <m2>),
    l((0, 3), "  ...", <m3>),
    l((0, 4), "  ret", <m4>),
    l((1, 0), "g:", <f0>),
    l((1, 1), "  ...", <f1>),
    l((1, 2), "  ...", <f2>),
    l((1, 3), "  ...", <f2>),
    l((1, 4), "  ret", <f3>),
    node(enclose: (<m0>, <m4>), stroke: 1.4pt + navy, inset: 6pt, snap: false),
    node(enclose: (<f0>, <f3>), stroke: 1.4pt + navy, inset: 6pt, snap: false),
    edge((0.04, 1.9), (0.67, 1.3), "-|>", stroke: 1.2pt + teal),
    if rewind {
      edge(
        (0.67, 4),
        (0.04, 2.3),
        "-|>",
        stroke: 1.6pt + dark-pink,
        label: call-rw,
        label-side: left,
        mark-scale: 110%,
      )
    } else {
      edge((0.67, 4), (-0.2, 3.1), "-|>", stroke: 1.2pt + teal)
    },
  )
}

// Return address stack; `entries` is top of stack first.
// Opaque fills let a later stack cover an earlier one at the same position.
#let ras(entries, color: white) = {
  set text(size: 0.8em)
  let body-color = if color == white { navy } else { color }
  grid(
    columns: 2,
    column-gutter: 0.4em,
    align: horizon,
    rotate(-90deg, reflow: true, text(fill: navy, weight: "bold")[RAS]),
    table(
      columns: 2.2cm,
      rows: 1.4em,
      inset: 0pt,
      align: center + horizon,
      stroke: 1pt + navy,
      fill: (_, y) => if y == 0 { color.lighten(85%) } else { white },
      ..entries
        .enumerate()
        .map(((i, e)) => {
          if i == 0 { text(fill: body-color, raw(e)) } else { raw(e) }
        }),
    ),
  )
}

// Return correctly predicted by the RAS
#let _ras-hit = {
  set text(size: 0.8em)

  let call-addr = "0x1000"
  let ret-addr = "0x1004" // call-addr + 4: the value pushed by the call

  diagram(
    spacing: (2.4cm, 1.3cm),
    node-stroke: none,
    edge-stroke: 1.2pt + teal,

    // The small declared height is intentional. The stack is still drawn at
    // full size, but it doesn't stretch row 1 or the call→ret distance.
    node(
      (-0.07, 0),
      [#text(fill: muted, raw(call-addr))#h(0.8em)`call g`],
      name: <c>,
    ),
    node(
      (-0.7, 0.65),
      ras(("0xcafe", "0xdeca", "...")),
      height: 1em,
      inset: 0pt,
    ),
    pause,
    node(
      (-0.7, 0.65),
      ras((ret-addr, "0xcafe", "0xdeca"), color: teal),
      height: 1em,
      inset: 0pt,
    ),
    node((1, 0.75), text(fill: teal, `g`), name: <f>),
    edge(<c>, <f>, "-|>"),
    pause,
    node((0, 2), "", name: <r_hidden>),
    edge(<f>, <r_hidden>, "-|>", label: `ret`, label-side: left),
    pause,
    node(
      (-0.15, 2),
      [#text(fill: muted, raw(ret-addr))#h(0.8em)#rap],
      name: <r>,
    ),
    node(
      (-0.7, 0.65),
      ras(("0xcafe", "0xdeca", "...")),
      height: 1em,
      inset: 0pt,
    ),
    edge(
      (-0.065, 0),
      (-0.065, 2),
      "--|>",
      stroke: 1pt + muted,
      label: [+4],
      label-side: right,
    ),
  )
}

// Mispredicted return: rewinding
#let _ras-miss = {
  set text(size: 0.8em)

  let call-addr = "0x1000"
  let ret-addr = "0x1004" // pushed by the call
  let bad-addr = "0x????" // corrupted ra actually used by ret

  diagram(
    spacing: (2.4cm, 1.3cm),
    node-stroke: none,
    edge-stroke: 1.2pt + teal,

    // 1. Call site, RAS before the call
    node(
      (-0.08, 0),
      [#text(fill: muted, raw(call-addr))#h(0.8em)`call g`],
      name: <c>,
    ),
    pause,

    // 2. Call: return address pushed
    node((1, 0.75), text(fill: teal, `g`), name: <f>),
    edge(<c>, <f>, "-|>"),
    pause,

    // 3. Return to a corrupted ra: RAS top no longer matches
    node(
      (-0.19, 2),
      [#text(fill: muted, raw(bad-addr))#h(0.8em)`ra`],
      name: <r>,
    ),
    edge(
      <f>,
      (0, 2),
      "-|>",
      stroke: 1.2pt + red,
      label: `ret`,
      label-side: left,
    ),
    pause,
    edge(
      <f>,
      (0, 2),
      "-|>",
      stroke: 1.2pt + teal,
      label: `ret`,
      label-side: left,
    ),
    node(
      (-0.25, 2),
      rect(fill: white, width: 6em, height: 1em),
      name: <r>,
      layer: 1,
      snap: false,
    ),
    node(
      (-0.19, 2),
      [#text(fill: muted, raw(ret-addr))#h(0.8em)`ra`],
      name: <r>,
      layer: 1,
    ),

    // 4. Rewinding: entry popped, call-site check fails
    edge(
      (-0.4, 2),
      (-0.4, 0),
      "-|>",
      stroke: 1.3pt + dark-pink,
      bend: 60deg,
      label: call-rw,
      label-side: left,
    ),
  )
}

// Call-preceded gadget (RV32GC)
#let _cp-gadget = {
  set text(size: 0.8em)
  let i(body, fill: black) = text(fill: fill, weight: "bold", raw(body))
  block(stroke: 1.2pt + navy, inset: 10pt, grid(
    columns: (1.6em, auto),
    row-gutter: 0.55em,
    align: left,
    [], [#i("c.jal 1b8488", fill: dark-pink) #text(fill: teal, raw("# call"))],

    text(fill: dark-pink)[#sym.arrow.r], i("c.li   s0, 0"),
    [], i("c.lwsp ra, 0xc(sp)"),
    [], i("c.mv   a0, s0"),
    [], i("c.lwsp s0, 8(sp)"),
    [], i("c.lwsp s1, 4(sp)"),
    [], i("c.addi sp, 0x10"),
    [], i("c.jr   ra", fill: red),
  ))
}

// Integration in CVA6 (execute and fetch stages)
#let _impl-figure = {
  import fletcher.cetz.draw: *
  set text(size: 0.6em)
  let wire = (
    stroke: 1.3pt + dark-pink,
    mark: (end: "stealth", fill: dark-pink),
  )
  let lbl(body) = text(size: 0.85em, raw(body))
  let blk(a, b, body) = {
    rect(a, b, stroke: 1.2pt + navy.darken(15%), fill: navy.lighten(73%))
    content((a, 50%, b), align(center, body))
  }
  let new(a, b, body) = {
    rect(a, b, stroke: 1.2pt + lila, fill: lila.lighten(78%))
    content((a, 50%, b), align(center, body))
  }
  let dot(p) = circle(p, radius: 0.06, fill: dark-pink, stroke: none)
  fletcher.cetz.canvas(length: 1.15cm, {
    // Stages
    rect((0, 0), (5.6, 5), stroke: 1.5pt + navy, fill: navy.lighten(92%))
    content((0.2, 4.85), anchor: "north-west", strong[Execute stage])
    rect(
      (0.4, 0.3),
      (5.2, 3.9),
      stroke: 1pt + navy,
      fill: navy.lighten(86%),
    )
    content((0.6, 3.75), anchor: "north-west", text(size: 0.85em)[Branch unit])
    rect(
      (6.2, 0),
      (14.4, 5),
      stroke: 1.5pt + navy,
      fill: navy.lighten(92%),
    )
    content((6.4, 4.85), anchor: "north-west", strong[Fetch stage])
    // Blocks
    blk((1.6, 0.7), (2.6, 1.7), [\= ?])
    new((3.3, 1.8), (4.5, 2.6), [\- 4])
    blk((6.6, 3.0), (9.2, 4.3), [Instruction\ scan])
    blk((11.8, 3.2), (13.6, 4.2), [RAS])
    new((11.8, 0.5), (13.6, 2.95), [*Rewind*])
    // Inputs
    content((-0.3, 2.2), anchor: "east", lbl("addr"))
    content((-0.3, 0.95), anchor: "east", lbl("predict_addr"))
    line((-0.2, 2.2), (3.3, 2.2), ..wire)
    line((1.0, 2.2), (1.0, 1.45), (1.6, 1.45), ..wire)
    dot((1.0, 2.2))
    line((-0.2, 0.95), (1.6, 0.95), ..wire)
    // Execute -> Fetch
    line((2.6, 1.2), (11.8, 1.2), ..wire)
    line((3.9, 1.2), (3.9, 1.8), ..wire)
    dot((3.9, 1.2))
    line((4.5, 2.2), (11.8, 2.2), ..wire)
    content((8.8, 2.28), anchor: "south", lbl("rewinded_addr"))
    content((8.8, 1.28), anchor: "south", lbl("is_mispredict_ret"))
    // Fetch
    line((9.2, 3.7), (11.8, 3.7), ..wire)
    content((10.5, 3.78), anchor: "south", lbl("instr_type"))
    line((10.0, 3.7), (10.0, 2.65), (11.8, 2.65), ..wire)
    dot((10.0, 3.7))
    // Outputs
    line((13.6, 3.7), (15.0, 3.7), ..wire)
    content((15.1, 3.7), anchor: "west", lbl("predict_addr"))
    line((13.6, 2.2), (15.0, 2.2), ..wire)
    content((15.1, 2.2), anchor: "west", [exception])
    line((13.6, 1.2), (15.0, 1.2), ..wire)
    content((15.1, 1.2), anchor: "west", [skip])
  })
}
