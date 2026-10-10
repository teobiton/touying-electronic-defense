#import "/globals.typ": *
#import "/master/lib.typ": *
#import "/slides/cfi/schematics.typ": _jop-figure
#import "schematics.typ": *

= Signature-based detection

// ---------------------------------------------------------------------------
// 1. JOP attacks and their signature
// ---------------------------------------------------------------------------
== Jump-oriented programming

#schematic(_jop-figure, scale-value: 105%)

#pause
#v(0.6em)
#grid(
  columns: (7fr, 4fr),
  gutter: 1em,
  align: left + top,
  [
    #text(fill: muted.darken(60%), size: 0.85em)[
      Existing heuristics (indirect-jump rate, gadget length) are imprecise \
      #pause
      #arrow prone to *false positives* \
      #arrow evaded by *delay gadgets*
    ]
  ],
  [
    #uncover("4-")[
      #set text(size: 0.85em, fill: red)
      #warning-triangle More complex dispatcher gadget structures can be considered.
    ]
  ],
)

== A structural signature

*Proposal*: focus on the JOP dispatch mechanism
#v(1.6em)
#pause
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center + horizon,
  [
    #_fan(out: false)
    #caption[$N$ sources #sym.arrow.r *same* #Ad (DG start), same #RD]
  ],
  [
    #_fan(out: true)
    #caption[*Same* #As (DG end), same #RF #sym.arrow.r $N$ targets]
  ],
)

#pause
#v(1em)
#key[Track the triple *(#As, #Ad, $R$)* of every indirect jump]

// ---------------------------------------------------------------------------
// 2. The heatseeker algorithm
// ---------------------------------------------------------------------------
== The heatseeker algorithm

- Detects JOP *at runtime*: no CFG, no instrumentation, no metadata
- Converges towards the *start and end addresses of the dispatcher gadget*

#v(0.6em)
#align(center, _steps)

== Two mirrored caches

#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  [
    #align(left, image("assets/functional-entry.pdf", width: 85%))
    *Functional cache*: \
    #text(size: 0.85em)[#arrow $T = (R, #Ad)$, #Tga = #As] \
    #text(size: 0.85em)[#arrow Gadgets converging *towards* the dispatcher]
  ],
  [
    #align(left, image("assets/dispatcher-entry.pdf", width: 85%))
    *Dispatcher cache*: \
    #text(size: 0.85em)[#arrow $T = (R, #As)$, #Tga = #Ad] \
    #text(size: 0.85em)[#arrow Dispatcher departing *towards* the gadgets]
  ],
)

#pause
#v(1.4em)
#text(size: 0.85em)[
  - Caches with #Nent lines, least-recently-used policy
  - *Cache miss* #arrow insert at the top with counter = 1
  - *Cache hit* #arrow move to the top, and if #Tga differs, counter + 1 (up to threshold #Gth = 2)
]

== Running example: execution trace

#v(2.4em)
#grid(
  columns: (auto, 1fr),
  gutter: 2em,
  align: horizon,
  [
    #alternatives(_trace(), _trace(highlight: true))
  ],
  [
    - Dispatcher gadget from `0x3FAA` to `0x3FC0`
    - #RD = `x6`: gadgets #sym.arrow.r DG
    - #RF = `x7`: DG #sym.arrow.r gadgets
    #pause
    #v(0.2em)
    - Repeated pairs: (#hl(fuschia, `x6`), #hl(mint, `0x3FAA`)) and (#hl(fuschia, `x7`), #hl(mint, `0x3FC0`))
    - Paired with a *new* address each time
  ],
)

== Running example: cache updates

#text(size: 0.9em, alternatives(
  _cache-step(0),
  _cache-step(1),
  _cache-step(2),
  _cache-step(3),
))

#v(0.2em)
#text(size: 0.85em, alternatives(
  [Miss in both caches: new entries with counter = 1],
  [Miss in both caches: new entries pushed on top],
  [Functional hit on (`x6`, `0x3FAA`) with a new #Tga: counter = 2 = #Gth],
  [Dispatcher hit on (`x7`, `0x3FC0`) with a new #Tga: *both caches hold a full entry*],
))

== Decision response

#align(center, image("assets/heatseeker-example.pdf", width: 80%))

#pause
#text(size: 0.9em)[
  Alarm when the most recent full entries of both caches satisfy:
  + Both counters reach #Gth = 2
  + Different registers: #RD #sym.eq.not #RF
  + $|italic("As")_"disp" - italic("Ad")_"func"| < D_"dispatcher"$: start and end of one dispatcher
]

#pause
#v(0.2em)
#text(size: 0.8em, fill: muted)[
  #Ddisp = 64: calibrated via static analysis
]

// ---------------------------------------------------------------------------
// 3. Results
// ---------------------------------------------------------------------------

== Security evaluation

#{
  set text(size: 0.9em)
  align(center, table(
    columns: (auto, 15em),
    align: (
      left + horizon,
      center + horizon,
    ),
    stroke: none,
    inset: 0.5em,
    table.hline(stroke: 1pt),
    table.vline(x: 1, end: 2),
    table.header(
      table.cell(align: left + bottom)[*Attack*],
      table.cell[*Heatseeker algorithm*],
    ),
    table.hline(stroke: 0.6pt),
    [JOP attack], green-tick,
    [JOP attack + delay gadgets], green-tick,
    table.hline(stroke: 0.6pt),
    table.vline(x: 1, start: 2, end: 4),
  ))
}

#pause

#text(size: 0.9em)[
  #arrow Evaluated on an FPGA target (CVA6) \
  #pause
  #arrow *Proven* on a C model against formalized JOP attacks
]

#pause

#text(
  fill: red,
  size: 1.1em,
)[#warning-triangle More complex dispatch structures ?]

== Complex dispatcher gadgets

#v(-1em)

#grid(
  columns: (1fr, 1fr, 1fr),
  inset: (x: 0.5em, y: 0.4em),
  // schematics sit on a common baseline, text hangs below
  align: center + horizon,

  // Row 1: schematics
  schematic(_disp_reg_trans, scale-value: 115%),
  pause,
  schematic(_parallel_disp, scale-value: 115%),

  pause, schematic(_serial_disp, scale-value: 115%),

  // Row 2: category names
  text(size: 0.9em, uncover("1-")[*Dispatcher register transfers*]),
  text(size: 0.9em, uncover("2-")[*Parallel dispatcher* gadgets]),
  text(size: 0.9em, uncover("3-")[*Serial dispatcher* gadgets]),

  // Row 3: how to cover categories
  text(size: 0.85em, uncover("4-")[#arrow increase #Nent]),
  text(size: 0.85em, uncover("5-")[#arrow increase #Nent]),
  text(size: 0.85em, uncover(
    "6-",
  )[#arrow covered by an extension of the algorithm]),
)

#uncover("7-")[
  #text(size: 0.77em)[
    #Nent = 3 covers the standard pattern; #Nent #sym.gt.eq 4 covers foreseeable variants *not yet* in the literature
  ]]

== Impact on legitimate applications

The algorithm *should not* raise *false positives (FP)*

#pause

#v(0.5em)
#{
  set text(size: 0.8em)
  align(center, table(
    columns: (auto, auto, auto),
    align: (
      left + horizon,
      center + horizon,
      center + horizon,
    ),
    stroke: none,
    inset: 0.5em,
    table.hline(stroke: 1pt),
    table.header([*Target*], [*Linux boot*], [*SPEC CPU 2017*]),
    table.hline(stroke: 0.6pt),
    [CVA6], [0 FP], [0 FP],
    [x86 (Pin)], [---], [0 FP],
    table.hline(stroke: 1pt),
  ))
}

#v(-0.5em)
#h(11.6em)
#text(size: 0.8em, fill: muted)[
  For #Nent #sym.in {3, 4, 5}, with the most aggressive setting #Gth = 2
]

#v(0.6em)
#pause
By contrast: \
#arrow SCRAP @scrap raises false positives on SPEC CPU 2017 (x86) \
#arrow JOP-Alarm @jopalarm exceeds its threshold on all benchmarks (x86)

== Hardware evaluation

#{
  set text(size: 0.8em)
  let hi(body) = table.cell(fill: teal.lighten(85%), body)
  align(center, table(
    columns: (auto, auto, auto, auto, auto),
    align: (
      left + horizon,
      right + horizon,
      right + horizon,
      right + horizon,
      right + horizon,
    ),
    stroke: none,
    inset: 0.5em,
    table.hline(stroke: 1pt),
    table.header(
      [*Configuration*],
      table.cell(colspan: 2, align: center)[*LUTs*],
      table.cell(colspan: 2, align: center)[*FFs*],
    ),
    table.hline(stroke: 0.6pt),
    [CVA6 baseline], [17,906], [], [9,886], [],
    hi[\+ heatseeker, #Nent = 3],
    hi[18,310],
    hi[*+2.23~%*],
    hi[10,219],
    hi[*+3.31~%*],
    [\+ heatseeker, #Nent = 4], [18,364], [+2.52~%], [10,283], [+3.94~%],
    [\+ heatseeker, #Nent = 5], [18,375], [+2.58~%], [10,347], [+4.56~%],
    table.hline(stroke: 1pt),
  ))
}

#v(0.7em)
#only("2-")[
  - Zicfilp landing pads on CVA6 @cva6-cfi: +2.26~% LUTs, +0.20~% FFs
    - fewer flip-flops, but *requires recompilation*; heatseeker runs unmodified binaries
]
#only("3-")[
  #v(0.6em)
  - Off the *critical path*: no impact on frequency
]
#only("4-")[
  - In *parallel with execution*: no impact on performance
]

// ---------------------------------------------------------------------------
// 5. Conclusion
// ---------------------------------------------------------------------------

#slide(title: "Takeaways and limits")[

  #card(palette.primary)[Takeaways][
    - Structural signature: dispatcher fan-in and fan-out
    - Detection at the *second* dispatcher iteration, immune to delay gadgets
    - *Proven* detection capabilities
    - No false positives: SPEC CPU 2017, Linux boot, and x86 via Pin (#Ddisp~=~128)
    - +2.23~% LUTs, *no performance overhead*, *unmodified binaries*
  ]

  #pause
  #card(palette.primary)[Limits][
    - Dispatcher-less and autonomous-dispatcher JOP out of scope
    - Cache state not saved on context switches
  ]
]
