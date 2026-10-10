#let _rnd(st) = {
  let s = calc.rem(st * 1103515245 + 12345, 2147483647)
  (s, s / 2147483647.0)
}

/// PCB trace field, clipped to `width` x `height`.
/// `fade` is the slide background colour: the field dissolves into it
/// along `fade-angle` (45deg = opaque top-left -> visible bottom-right).
/// `pad-fill` fills the round pads at trace ends (none = hollow).
///
/// `keepout`: array of `(x0, y0, x1, y1)` grid-node ranges (inclusive)
///   that traces must never cross. Grid node (i, j) sits at (i*step, j*step).
/// `pins`: array of `(x:, y:, dir:, color:, thickness:)` dictionaries.
///   Each pin seeds a trace from node (x, y) heading `dir`
///   (0 = up, 1 = right, 2 = down, 3 = left); the first run always goes
///   straight out. Pin nodes may sit on a keepout border. `color`,
///   `thickness`, `pad-fill`, `min-segs`, `max-segs` and `max-run` are
///   optional per-pin overrides. Pins are routed before the
///   random traces, so they get first pick of the free space.
/// With empty `keepout`/`pins` the output is identical to the old version.
#let pcb-field(
  width: 360pt,
  height: 270pt,
  step: 9pt,
  seed: 11,
  traces: 120,
  bleed: 5,
  min-segs: 3,
  max-segs: 9,
  max-run: 5,
  straight-bias: 0.67,
  trace-color: rgb("#cfd6de"),
  thickness: 0.6pt,
  pad-radius: 1.5pt,
  pad-fill: white,
  fade: none,
  fade-angle: 30deg,
  keepout: (),
  pins: (),
) = {
  let xmax = calc.max(int(width / step), 2) + bleed
  let ymax = calc.max(int(height / step), 2) + bleed
  let w = xmax + 1
  let sk = thickness + trace-color
  let st = calc.rem(seed * 2654435761 + 1013904223, 2147483647)
  let occ = (false,) * (w * (ymax + 1))
  let out = ()
  let pads = () // drawn after every line so the fill hides the trace ends

  let idx(x, y) = y * w + x
  let dxs = (0, 1, 0, -1)
  let dys = (-1, 0, 1, 0)

  for k in keepout {
    let (x0, y0, x1, y1) = k
    for y in range(calc.max(y0, 0), calc.min(y1, ymax) + 1) {
      for x in range(calc.max(x0, 0), calc.min(x1, xmax) + 1) {
        occ.at(idx(x, y)) = true
      }
    }
  }

  // how far we can go from (cx, cy) along `dir` before hitting
  // an occupied node or the grid edge
  let free-run(grid, cx, cy, dir, maxlen) = {
    let n = 0
    while n < maxlen {
      let nx = cx + dxs.at(dir) * (n + 1)
      let ny = cy + dys.at(dir) * (n + 1)
      if nx < 0 or nx > xmax or ny < 0 or ny > ymax { break }
      if grid.at(idx(nx, ny)) { break }
      n += 1
    }
    n
  }

  let pad(px, py, s, f) = place(
    dx: px * step - pad-radius,
    dy: py * step - pad-radius,
    circle(radius: pad-radius, stroke: s, fill: f),
  )

  let npins = pins.len()
  let placed = 0
  let attempts = 0
  while (
    attempts < npins or (placed < traces and attempts < npins + traces * 8)
  ) {
    let is-pin = attempts < npins
    let pin = if is-pin { pins.at(attempts) } else { none }
    attempts += 1

    let r = none
    let cx = 0
    let cy = 0
    if is-pin {
      cx = pin.x
      cy = pin.y
      if cx < 0 or cx > xmax or cy < 0 or cy > ymax { continue }
    } else {
      r = _rnd(st)
      st = r.at(0)
      cx = int(r.at(1) * (xmax + 1))
      r = _rnd(st)
      st = r.at(0)
      cy = int(r.at(1) * (ymax + 1))
      if occ.at(idx(cx, cy)) { continue }
    }

    r = _rnd(st)
    st = r.at(0)
    let lo = if is-pin { pin.at("min-segs", default: min-segs) } else {
      min-segs
    }
    let hi = if is-pin { pin.at("max-segs", default: max-segs) } else {
      max-segs
    }
    let mr = if is-pin { pin.at("max-run", default: max-run) } else { max-run }
    let segs = lo + int(r.at(1) * (hi - lo + 1))
    r = _rnd(st)
    st = r.at(0)
    let dir = if is-pin { pin.dir } else { int(r.at(1) * 4) }
    let tsk = if is-pin {
      (
        pin.at("thickness", default: thickness)
          + pin.at("color", default: trace-color)
      )
    } else { sk }
    let tfill = if is-pin { pin.at("pad-fill", default: pad-fill) } else {
      pad-fill
    }

    let path = ((cx, cy),)
    occ.at(idx(cx, cy)) = true

    let j = 0
    while j < segs {
      r = _rnd(st)
      st = r.at(0)
      if r.at(1) > straight-bias and not (is-pin and j == 0) {
        r = _rnd(st)
        st = r.at(0)
        dir = calc.rem(dir + if r.at(1) < 0.5 { 1 } else { 3 }, 4)
      }
      r = _rnd(st)
      st = r.at(0)
      let want = 1 + int(r.at(1) * mr)
      let run = free-run(occ, cx, cy, dir, want)

      // blocked: try the other three headings before giving up
      let k = 0
      while k < 3 and run == 0 {
        dir = calc.rem(dir + 1, 4)
        run = free-run(occ, cx, cy, dir, want)
        k += 1
      }
      if run == 0 { break }

      let n = 1
      while n <= run {
        occ.at(idx(cx + dxs.at(dir) * n, cy + dys.at(dir) * n)) = true
        n += 1
      }
      cx += dxs.at(dir) * run
      cy += dys.at(dir) * run
      path.push((cx, cy))
      j += 1
    }

    if path.len() < 2 { continue }

    // pins start on the chip edge: no pad there, the chip covers it
    if not is-pin {
      pads.push(pad(path.first().at(0), path.first().at(1), tsk, tfill))
    }
    let i = 0
    while i < path.len() - 1 {
      let a = path.at(i)
      let b = path.at(i + 1)
      out.push(place(line(
        start: (a.at(0) * step, a.at(1) * step),
        end: (b.at(0) * step, b.at(1) * step),
        stroke: tsk,
      )))
      i += 1
    }
    pads.push(pad(cx, cy, tsk, tfill))
    if not is-pin { placed += 1 }
  }

  box(width: width, height: height, clip: true, {
    place(out.join())
    place(pads.join())
    if fade != none {
      place(rect(
        width: width,
        height: height,
        fill: gradient.linear(
          fade,
          fade.transparentize(45%),
          angle: fade-angle,
          space: color.rgb,
        ),
      ))
    }
  })
}


/// Keep-out rectangle `rect` (grid cells) with pins on its edges, for the
/// focus slide. Returns `()` when `rect` is none.
#let focus-rect-pins(rect, color, pad-fill: auto, pin-pitch: 2) = {
  if rect == none { return () }
  let (x0, y0, x1, y1) = rect
  let f = if pad-fill == auto { color } else { pad-fill }
  let pin(x, y, dir) = (x: x, y: y, dir: dir, color: color, pad-fill: f)
  let pins = ()
  for y in range(y0 + 1, y1) {
    pins.push(pin(x0, y, 3))
    pins.push(pin(x1, y, 1))
  }
  for x in range(x0 + 2, x1 - 1, step: pin-pitch) {
    pins.push(pin(x, y0, 0))
    pins.push(pin(x, y1, 2))
  }
  pins
}

/// Focus-slide board: traces leaving the rectangle are `pin-color`, the rest
/// of the board is a darker background field. Background pads are filled with
/// the slide colour so the trace never shows through them.
#let focus-slide-pcb(
  master,
  width: 840pt,
  height: 473pt,
  rect: none,
  pin-color: white.darken(20%),
  trace-color: auto,
) = pcb-field(
  width: width,
  height: height,
  step: 10pt,
  seed: 2555656,
  traces: 400,
  trace-color: if trace-color == auto {
    master.colors.neutral-dark.lighten(17%)
  } else { trace-color },
  pad-fill: master.colors.neutral-dark,
  keepout: if rect == none { () } else { (rect,) },
  pins: focus-rect-pins(rect, pin-color),
)

/// Geometry of the centred text rectangle on a focus slide of `width` x `height`.
/// `body` must already be styled (size and colour) as it will be shown.
/// Returns the rectangle in grid cells (`grid`), in points (`x`, `y`, `w`, `h`)
/// and the width available to the text inside it (`inner-w`).
#let focus-geometry(
  body,
  width,
  height,
  step: 10pt,
  max-width: 40%,
  inset: (x: 1.4em, y: 1em),
) = {
  let cols = int(width / step)
  let rows = int(height / step)
  let mw = if type(max-width) == ratio { width * max-width } else { max-width }
  let ix = measure(h(inset.x)).width
  let iy = measure(v(inset.y)).height
  let bh = measure(block(width: mw - 2 * ix, body)).height + 2 * iy
  let rw = calc.min(calc.ceil(mw / step), cols - 2)
  let rh = calc.max(3, calc.ceil(bh / step))
  let x0 = calc.max(1, int((cols - rw) / 2))
  let y0 = calc.max(1, int((rows - rh) / 2))
  (
    grid: (x0, y0, x0 + rw, y0 + rh),
    x: x0 * step,
    y: y0 * step,
    w: rw * step,
    h: rh * step,
    inner-w: rw * step - 2 * ix,
  )
}

#let title-slide-pcb(master) = pcb-field(
  width: 840pt,
  height: 473pt,
  step: 10pt,
  seed: 4654,
  traces: 666,
  trace-color: master.colors.neutral-darkest.lighten(76%),
  fade: master.colors.neutral-lightest,
)


/// Outline as a circuit board: every section is a chip, traces run out of
/// its pins and the rest of the board routes around the chips.
///
/// `sections`: array of content (one per level-1 heading).
/// `current`:  index of the section to highlight, or none (default):
///             with none, every chip and trace uses the same colours.
/// `pin-color`: colour of the traces leaving the chips; none = `trace-color`.
/// Chips snap to the trace grid so their edges line up with the routing.
/// Must be called in a context (it measures the section titles).
#let outline-slide-pcb(
  sections,
  current: none,
  width: 760pt,
  height: 380pt,
  step: 10pt,
  seed: 13,
  traces: 300,
  number-format: "01",
  cascade: 8, // total horizontal drift of the chip column, in grid cells
  pin-pitch: 2, // spacing of pins on top/bottom edges, in grid cells
  inset: (x: 1em, y: 0.7em),
  accent: rgb("#1f6feb"),
  chip-fill: white,
  chip-stroke: rgb("#3a4450"),
  text-color: rgb("#1c2128"),
  muted: 55%, // how much non-current chips fade when one is current
  trace-color: rgb("#dde3ea"),
  pin-color: rgb("#9aa6b2"),
  fade: none,
  fade-angle: 30deg,
  ..field-args,
) = {
  let n = sections.len()
  if n == 0 { return }

  let is-dim(i) = current != none and i != current
  let badge(i) = box(
    inset: (x: 0.35em, y: 0.2em),
    radius: 2pt,
    fill: if i == current { accent } else { chip-stroke },
    text(
      fill: chip-fill,
      weight: "bold",
      size: 0.8em,
      font: ("DejaVu Sans Mono", "Liberation Mono"),
      numbering(number-format, i + 1),
    ),
  )
  let inner(i) = grid(
    columns: 2,
    column-gutter: 0.7em,
    align: horizon,
    badge(i),
    text(
      fill: if is-dim(i) { text-color.transparentize(muted) } else {
        text-color
      },
      weight: if i == current { "bold" } else { "regular" },
      sections.at(i),
    ),
  )

  // chip size in grid cells: uniform width, tall enough for side pins
  let sizes = range(n).map(i => measure(inner(i)))
  let ix = measure(h(inset.x)).width
  let iy = measure(v(inset.y)).height
  let cw = calc.ceil((calc.max(..sizes.map(s => s.width)) + 2 * ix) / step)
  let ch = calc.max(3, calc.ceil(
    (calc.max(..sizes.map(s => s.height)) + 2 * iy) / step,
  ))

  let cols = int(width / step)
  let rows = int(height / step)
  cw = calc.min(cw, cols - 2)
  let gap = calc.max(1, int((rows - n * ch) / (n + 1)))
  let total = n * ch + (n - 1) * gap
  let top = calc.max(0, int((rows - total) / 2))
  let drift = if n > 1 { calc.min(cascade, cols - cw - 2) } else { 0 }
  let left0 = calc.max(1, int((cols - cw - drift) / 2))

  let chips = range(n).map(i => {
    let x0 = (
      left0 + if n > 1 { int(calc.round(drift * i / (n - 1))) } else { 0 }
    )
    let y0 = top + i * (ch + gap)
    (x0: x0, y0: y0, x1: x0 + cw, y1: y0 + ch)
  })

  let pin-of(i, x, y, dir) = (
    x: x,
    y: y,
    dir: dir,
    color: if i == current { accent } else if pin-color == none {
      trace-color
    } else { pin-color },
    thickness: if i == current { 0.9pt } else { 0.6pt },
    // the highlighted chip reaches further across the board
    min-segs: if i == current { 6 } else { 3 },
    max-segs: if i == current { 14 } else { 9 },
    max-run: if i == current { 7 } else { 5 },
  )
  // side pins first (they form the long horizontal buses),
  // current chip before the others so its traces get the best routes
  let order = if current == none { range(n) } else {
    (current,) + range(n).filter(i => i != current)
  }
  let pins = ()
  for i in order {
    let c = chips.at(i)
    for y in range(c.y0 + 1, c.y1) {
      pins.push(pin-of(i, c.x0, y, 3))
      pins.push(pin-of(i, c.x1, y, 1))
    }
  }
  // top/bottom pins only where there is room to route away from them:
  // between tightly packed chips they would just form a comb of stubs
  let roomy = gap >= 3
  for i in order {
    let c = chips.at(i)
    for x in range(c.x0 + 2, c.x1 - 1, step: pin-pitch) {
      if roomy or i == 0 { pins.push(pin-of(i, x, c.y0, 0)) }
      if roomy or i == n - 1 { pins.push(pin-of(i, x, c.y1, 2)) }
    }
  }

  box(width: width, height: height, {
    place(pcb-field(
      width: width,
      height: height,
      step: step,
      seed: seed,
      traces: traces,
      trace-color: trace-color,
      fade: fade,
      fade-angle: fade-angle,
      keepout: chips.map(c => (c.x0, c.y0, c.x1, c.y1)),
      pins: pins,
      ..field-args,
    ))
    for i in range(n) {
      let c = chips.at(i)
      place(
        dx: c.x0 * step,
        dy: c.y0 * step,
        rect(
          width: cw * step,
          height: ch * step,
          inset: (x: ix, y: 0pt),
          radius: 1.5pt,
          fill: chip-fill,
          stroke: if i == current { 1.2pt + accent } else {
            (
              0.8pt
                + if is-dim(i) { chip-stroke.transparentize(40%) } else {
                  chip-stroke
                }
            )
          },
          align(left + horizon, inner(i)),
        ),
      )
    }
  })
}
