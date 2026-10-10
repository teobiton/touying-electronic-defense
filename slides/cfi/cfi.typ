#import "/globals.typ": *
#import "/master/lib.typ": *
#import "schematics.typ": *

= Control-flow integrity

//--------------------------------------------------------------------------
// 0. A program's control flow
// -------------------------------------------------------------------------

== A program's control flow

#slide(title: "A program's control flow")[
  #grid(
    columns: (1.25fr, 0.9fr),
    gutter: 1.5em,
    align: top,
    [
      #set text(size: .75em)
      #show raw.where(block: true): block.with(
        fill: luma(235),
        inset: 12pt,
        radius: 4pt,
        width: 100%,
      )
      ```c
      void read_key(char *key) {

        if (!strcmp(key, "good")) { // conditional branch
          unlock_doors();           // function call
        }

        return;                     // function return

      }
      ```
    ],
    [
      #set text(size: .85em)
      #pause
      Two kinds of control-flow transfers:
      #uncover("2-")[
        - *Backward edge*: transfer to a previously executed block through *function returns*
      ]
      #uncover("3-")[
        - *Forward edge*: all other transfers, e.g. *function calls*, *conditional branches*
      ]
      #uncover("4-")[$arrow$ Sometimes a target is *dynamically computed*]
    ],
  )

  #v(1em)
  #uncover("5-")[$arrow$ How do targets get *overwritten*?]

]

//--------------------------------------------------------------------------
// 1. Vulnerabilities
// ---------------------------------------------------------------------------

== Prerequisites: software vulnerabilities

#slide(title: "Prerequisites: software vulnerabilities")[
  #set text(size: .85em)
  *Software vulnerabilities*
  - Memory-safety bugs let an attacker *corrupt memory at runtime*
  - Growing code size and product volume $arrow$ larger attack surface
  - Bugs survive for *decades*, despite reviews
  #pause
  #v(1em)
  *Recent acceleration: AI-driven discovery*
  #pause

  Claude Mythos Preview @mythos found thousands of zero-days in every major OS and web browser

  $arrow$ *CVE-2026-4747*: 17-year-old stack overflow in FreeBSD's NFS server
  #schematic(_free-bsd)
  $arrow$ Found *and* exploited autonomously
]

// ---------------------------------------------------------------------------
// 2. Software injection to reuse
// ---------------------------------------------------------------------------

== From software injection to reuse

#slide(title: "From code injection to code reuse", composer: (1fr, 1fr))[
  #set text(size: .85em)
  *Code injection* @stack-smash
  - Corrupt a code pointer (e.g. return address) to jump into attacker data
  #schematic(_memory-injection)
][
  #text(size: .85em)[#only("2-")[
    *Code-reuse attacks (CRAs)*
    - Use *control-flow instructions* within existing code to alter its behavior
    #schematic(_memory-reuse)
  ]]
]

// ---------------------------------------------------------------------------
// 4. Return-oriented programming
// ---------------------------------------------------------------------------

== Return-oriented programming

#slide(title: "Return-oriented programming")[
  #grid(
    columns: (1fr, 1.15fr),
    gutter: 1.5em,
    [
      #v(2em)
      #schematic(_rop-figure, scale-value: 90%)
    ],
    [
      #set text(size: .85em)
      #v(5em)
      #only("2-")[
        - Hijacks *backward edges* using `ret` instructions
        - *Gadget* @shacham: short sequence of existing instructions ending with a control-flow operation
        - Each `ret` chains to the next gadget
      ]
    ],
  )
]

// ---------------------------------------------------------------------------
// 5. Existing protections
// ---------------------------------------------------------------------------

== Existing protections

#slide(title: "Existing protections: shadow stacks", composer: (1fr, 1fr))[
  #set text(size: .85em)
  - Keep a protected copy of every return address
  - Covers *backward edges*, the core of ROP
  #schematic(_shadow)
][
  #text(size: .85em)[#only("2-")[
    - *Software*: instrumented function prologues and epilogues @sokstack
    - *Hardware-assisted*: specific instructions handling shadow stacks @cva6-cfi
  ]]
  #only("3-")[
    #v(.3em)
    #align(center)[
      #grid(
        columns: 2,
        column-gutter: 14pt,
        _impact(
          "Software shadow stack",
          app: true,
          compiler: true,
          os: "partial",
        ),
        _impact(
          "Hardware shadow stack",
          app: true,
          compiler: true,
          os: true,
          hw: true,
        ),
      )
      #_impact-legend
    ]]
]

== Jump-oriented programming

#slide(title: "Jump-oriented programming")[

  #v(1em)

  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5em,
    [
      #schematic(_jop-figure, scale-value: 105%)
    ],
    [
      #set text(size: .85em)
      #v(2em)
      #only("2-")[- Hijacks *forward edges* (`jr`), not returns @jop]
      #uncover("3-")[- Bypasses shadow stacks] \
      #uncover("4-")[- *Initializer gadget*: sets up the attack]
      #uncover("5-")[
        - *Dispatcher gadget*: jumps to the next entry of a *dispatch table*
      ]
      #uncover("6-")[
        - *Functional gadgets*: compute, then jump back to the dispatcher
      ]

    ],
  )
]

#slide(title: "Existing protections: enforcing the CFG", composer: (1fr, 1fr))[
  #set text(size: .85em)
  - Extract the *CFG* ahead of time
  - Check each indirect branch against its allowed targets
  #schematic(_cfg)
][
  #text(size: .85em)[#only("2-")[
    - *Software*: compiler inserts target checks before indirect calls @hpcfi
    - *Hardware-assisted*: indirect branches must target *landing pad* instructions @cva6-cfi
  ]]
  #only("3-")[
    #v(.3em)
    #align(center)[
      #grid(
        columns: 2,
        column-gutter: 14pt,
        _impact("Software CFI", app: true, compiler: true),
        _impact("Landing pads", app: true, compiler: true, os: true, hw: true),
      )
      #_impact-legend
    ]]
]

// ---------------------------------------------------------------------------
// 6. Towards hardware control-flow integrity
// ---------------------------------------------------------------------------

== Towards hardware control-flow integrity

#slide(title: "Towards hardware control-flow integrity", composer: (3fr, 2fr))[
  #set text(size: .88em)
  - *Pervasive* vulnerabilities, now weaponized by AI
  - Assume *any* software can be breached
    #pause
  - Existing CFI solutions:
    - Software: *performance* and *memory* overhead, and themselves exposed, being software
    - Hardware-assisted: efficient, but require modifying the *compiler, OS and application*
  #pause
  $arrow$ *Hardware* as a last bastion against CRAs, with minimal impact on the rest of the stack
][
  #align(center + horizon)[
    #scale(130%, reflow: true, _impact("Objective", hw: true, os: "partial"))
    #v(.5em)
    #_impact-legend
  ]
]
