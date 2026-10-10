#import "/globals.typ": *
#import "/master/lib.typ": *
#import "schematics.typ": *

= Return address protection

// ---------------------------------------------------------------------------
// 1. Introductive slide: limits of shadow stacks
// ---------------------------------------------------------------------------
== Shadow stacks: precise, but costly

#let ss-defect = card.with(
  left-stroke: 3pt,
  inset: 0.5em,
  radius: 2pt,
  body-size: 0.72em,
)

#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  align: top,
  [
    #pause
    #ss-defect(red, height: 3.4em)[Performance][
      Extra memory accesses on every call and return
    ]
  ],
  [
    #pause
    #ss-defect(red, height: 3.4em)[Hardware][
      Custom instructions and specific MMU handling
    ]
  ],

  [
    #pause
    #ss-defect(red, height: 4.4em)[Memory footprint][
      One shadow stack per running application
    ]
  ],
  [
    #pause
    #ss-defect(red, height: 4.4em)[Implementation complexity][
      Legacy binaries left out, OS support, `setjmp`/`longjmp` support, exceptions, coroutines, dynamic libraries...
    ]
  ],
)

#pause
#align(
  center,
)[#arrow Needed: a backward-edge protection that is *lightweight*, *stateless* and *transparent to the binary*]


// ---------------------------------------------------------------------------
// 2. Call Rewinding
// ---------------------------------------------------------------------------
== Call rewinding: principle

#align(center, block(
  fill: teal.lighten(88%),
  inset: 0.6em,
  radius: 3pt,
)[*Property:* legitimate return addresses target *call-preceded* instructions])

#pause

#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  gutter: 1em,
  [
    #_call-panel(rewind: false)
    #caption[Nominal function call and return]
  ],
  [
    #pause
    #_call-panel(rewind: true)
    #caption[With #text(fill: dark-pink)[call rewinding]]
  ],
)

#pause
On return, *rewind* by one instruction: the target must follow a call, otherwise assume malicious behavior.

#pause
#arrow in microarchitecture, this check can be optimized

== Leveraging branch prediction: return address stack

#v(1em)
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  gutter: 1em,
  [
    #_ras-miss
    #v(0.28em)
    #caption[No prediction]
  ],
  [
    #pause
    #_ras-hit
    #v(0.4em)
    #caption[Correctly predicted return: `ra` = #rap]
  ],
)

#pause
#v(1.4em)
- Correctly predicted return addresses already satisfy the property
- Only *mispredicted* returns are checked #arrow less impact on performance

// ---------------------------------------------------------------------------
// 4. Security detection
// ---------------------------------------------------------------------------

== Security assessment

#grid(
  columns: (1.2fr, 1fr),
  gutter: 1.5em,
  align: horizon,
  [
    *Illegal return addresses detected*
    #pause
    - ROP #arrow at the *very first gadget*
    #pause
    - Any return to a non-call-preceded instruction
    #pause
    *Limit: coarse-grained CFI*
    - No match between a return address and its original call site
    - Call-preceded gadgets remain usable
    #pause
    *Static analysis*
    - 99% of ROP gadgets eliminated

    #v(1em)
    #arrow *what about the remaining 1%?*
  ],
  [
    #uncover("4-")[
      #align(center, _cp-gadget)
      #caption[Example call-preceded gadget (RV32GC)]
    ]
  ],
)

// ---------------------------------------------------------------------------
// 5. Exposure assessment of the remaining gadgets
// ---------------------------------------------------------------------------

== Exposure assessment: beyond gadget counting

#grid(
  columns: (1fr, 1fr),
  gutter: 2.8em,
  align: horizon,
  [
    #card(navy, height: 4em)[Objective][
      Exposure $cal(E) in [0, 100]$
    ]
    #card(teal, height: 4em)[Prerequisites][
      Weakest register control over target registers
    ]
    #card(dark-pink, height: 4em)[Target registers][
      Register control $"RC" in [0, 100]$: can the register be set to a _suitable_ value?
    ]
  ],
  [
    #pause
    #set text(size: 0.8em)
    + *Extract* gadgets
    + *Build* a register dependency graph\
    + *Score* the control over each target register\
    + *Search for* the register ordering maximizing control\
    + *Aggregate* the scores up the hierarchy
  ],
)

== Exposure of call-preceded gadgets

#text(size: 0.8em)[
  - *Target*: standard C library (`libc`)
  - *Objective*: attempt to read and extract the contents of a file
  - *CPROP*: call-preceded ROP gadgets
]

#pause
#v(0.3em)
#{
  set text(size: 0.78em)
  let hi(..args) = table.cell(fill: teal.lighten(88%), ..args)
  table(
    columns: (1.4fr, 1fr, 1fr, 1fr),
    align: (left + horizon,) + (center + horizon,) * 4,
    stroke: none,
    inset: 0.5em,
    // Lines declared up front so `pause` never wraps them
    table.vline(x: 1, stroke: 0.4pt),
    table.vline(x: 2, stroke: 1pt),
    table.vline(x: 3, stroke: 0.1pt),
    table.hline(y: 4, stroke: 1pt),
    // bottom rule
    table.hline(stroke: 1pt),
    table.header(
      table.cell(rowspan: 2)[],
      table.cell[*Baseline*],
      hi(colspan: 2)[*With call rewinding*],
      table.hline(start: 1, end: 3, stroke: 0.4pt),
      table.hline(start: 3, end: 5, stroke: 0.4pt),
      [*ROP*],
      hi[*ROP*], hi[*CPROP*],
    ),
    table.hline(stroke: 0.6pt),
    [Number of gadgets], [3,803], hi([*0*]), hi([24]),
    table.hline(stroke: 1pt),
    pause,
    [Exposure $cal(E)$], [97], hi([*0*]), hi[*0*],
  )
}

#pause
The few call-preceded ROP gadgets lack register control

#arrow The ≈1% of gadgets surviving call rewinding yield *no attack path*

// ---------------------------------------------------------------------------
// 6. Proof of concept
// ---------------------------------------------------------------------------

== Proof-of-concept implementation

#v(1em)

#align(center, _impl-figure)

#pause

#place(
  dx: 17%,
  dy: 15%,
  text(
    size: 0.8em,
    [
      - Resolve branch prediction
      - Compute the rewind address
    ],
  ),
)

#pause

#place(
  dx: 47%,
  dy: 15%,
  text(
    size: 0.8em,
    [
      - Decode rewind instruction
      - Skip rewind instructions
    ],
  ),
)

// ---------------------------------------------------------------------------
// 7. Experimental results
// ---------------------------------------------------------------------------

== Experimental results

#{
  set text(size: 0.8em)
  let hi(body) = table.cell(fill: teal.lighten(88%), body)
  table(
    columns: (1.6fr, 0.9fr, 1.6fr, 0.9fr),
    align: (
      left + horizon,
      center + horizon,
      center + horizon,
      center + horizon,
    ),
    stroke: none,
    inset: 0.4em,
    table.hline(stroke: 1pt),
    table.header([], [*Performance*], [*Hardware resources*], [*Code size*]),
    table.hline(stroke: 0.6pt),

    hi[*Call rewinding* (CVA6)],
    hi[*0.12~%*],
    hi[*0.09~%* LUTs, *0.16~%* FFs],
    hi[*none*],

    [Return address protection @riscv-ra-protect],
    [> 2~%],
    [≈ 1~%],
    [---],

    [HAFIX @hafix],
    [2~%],
    [1.0~% LUTs, 2.49~% FFs],
    [---],

    [Zicfiss @cva6-cfi],
    [4.66~%],
    [2.20~% LUTs, 0.28~% FFs],
    [≈ +10~%],

    table.hline(stroke: 1pt),
  )
}
#v(-0.4em)
#text(size: 0.67em, fill: muted)[
  Hardware platforms differ across works.
]

#pause
*Security:* RIPE @hope-ripe and ROP-Generator #footnote[https://gepgitlab.laas.fr/matana/bench/rop-generator] attacks detected

// ---------------------------------------------------------------------------
// 8. Conclusion
// ---------------------------------------------------------------------------

#slide(title: "Conclusion on call rewinding")[

  #card(palette.primary)[Advantages][
    - Much lower overheads than shadow stacks
    - Reuses the existing RAS
    - *Stateless*: nothing to save on context switches, `setjmp`/`longjmp` supported by design
    - *No impact on the binary*: suits legacy code and constrained systems
  ]

  #pause
  #card(palette.primary)[Limits][
    - Coarser granularity than shadow stacks
    - False positives in the Linux kernel
  ]

  #pause
  #v(0.6em)
  #card(
    palette.secondary,
    title-size: 1.2em,
    height: 1.6em,
  )[What about other code-reuse attacks ?][]
]
