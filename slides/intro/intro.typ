#import "/globals.typ": *
#import "/master/lib.typ": *
#import "schematics.typ": *

= Introduction

// ---------------------------------------------------------------------------
// 1. Embedded systems
// ---------------------------------------------------------------------------

== Embedded systems

#slide(title: "Embedded systems")[
  Small, constrained computers  hidden inside everyday objects: cars, planes, pacemakers, phones...
  As of 2026, nearly *98%* of microprocessors are used in such *embedded systems*.
  #pause
  #v(.5fr)
  #arrow Most are *sensitive* and contain private data, e.g. health-related \
  #arrow Many are *critical*: a failure endangers missions, infrastructure or lives

  #v(1fr)
  #align(center)[
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 3.5em,
      align: center + horizon,
      image("assets/cars.jpeg", width: 100%, height: 5cm, fit: "cover"),
      image("assets/airplane.jpeg", width: 100%, height: 5cm, fit: "cover"),
    )
  ]
  #v(1fr)
]

// ---------------------------------------------------------------------------
// 2. Inside every device: a program (transition to the recipe slide)
// ---------------------------------------------------------------------------

== Inside every device: a program

#slide(title: "Inside every device: a program")[
  Each of these objects is driven by *small computers*: a car alone contains dozens of them.
  #v(1fr)
  #schematic(_zoom, scale-value: 120%)
  #v(1fr)
  #pause
  Whatever the device does (unlock the doors, deploy an airbag) is decided by its *program*.
  #v(3em)
]

// ---------------------------------------------------------------------------
// 3. What a program is
// ---------------------------------------------------------------------------

== A program is a recipe

#slide(title: "A program is a recipe", composer: (1.2fr, 1fr))[
  #set text(size: .9em)
  - A program: *steps*, followed one after another
  - Some steps are *conditional*
  - Their order is represented by the #underline[*control-flow graph*] (CFG)
  #pause
  #align(left)[
    #arrow *Security relies on this order*
  ]
  #v(.5fr)
][
  #meanwhile
  #v(-.5fr)
  #schematic(_flow(), scale-value: 120%)
  #v(1fr)
]

// ---------------------------------------------------------------------------
// 5. Reusing the program against itself
// ---------------------------------------------------------------------------

== Turning the program against itself

#slide(title: "Turning the program against itself", composer: (1.2fr, 1fr))[
  #pause
  #set text(size: .9em)
  - New steps from the attacker are *refused*
  #pause
  - So the attacker *reuses* existing ones, *reordered*
  #v(.5fr)
][
  #meanwhile
  #v(-.5fr)
  #schematic(
    alternatives(repeat-last: true, _flow(), _flow(hijack: true)),
    scale-value: 120%,
  )
  #v(1fr)
]

// ---------------------------------------------------------------------------
// 6. Guarding the route
// ---------------------------------------------------------------------------

== Guarding the route

#slide(title: "Guarding the route", composer: (1.2fr, 1fr))[
  #set text(size: .9em)
  - *Map* the allowed routes in advance (*CFG*)
  #v(.1em)
  #pause
  - *Check every jump* against the map
  #arrow #underline[*Control-flow integrity*] #cite-at("2-", <abadi-cfi>)
  #pause
  #v(.5em)
  *Existing guards have a cost*
  - In software: *slower*, *larger* programs
  - In processors: *rebuild* all the software
][
  #meanwhile
  #v(-.5fr)
  #schematic(_flow(hijack: true, guard: true), scale-value: 120%)
  #v(1fr)
]

// ---------------------------------------------------------------------------
// 7. This thesis
// ---------------------------------------------------------------------------

== This thesis

#slide(title: "This thesis")[
  #align(center)[
    Build security mechanisms *into the processor itself*: \
    monitor transfers while software runs *unchanged*
  ]
  #pause
  #v(1.6em)
  #grid(
    columns: (1fr, 1fr, 1fr),
    rows: 5.2cm,
    column-gutter: 1em,
    pillar(
      fill: palette.primary,
      "Understand",
      "How do attackers re-orchestrate a program?",
    ),
    pause,
    pillar(
      fill: palette.primary,
      "Protect",
      "How can hardware catch control-flow deviations?",
    ),

    pause,
    pillar(
      fill: palette.primary,
      "Assess",
      "What can an attacker still do despite the enhanced security?",
    ),
  )
]

// ---------------------------------------------------------------------------
// 8. Outline
// ---------------------------------------------------------------------------

== Outline

#outline-slide(
  hl-all: true,
  extend-top: 31.5pt,
  extend-bottom: 30pt,
)
