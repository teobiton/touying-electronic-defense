#import "/globals.typ": card, palette
#import "/master/lib.typ": *

= Conclusion and perspectives

== Contributions

#slide(title: "Contributions")[
  #pause
  #card(palette.primary)[Improve understanding of code-reuse attacks][
    - taxonomy of JOP dispatch mechanisms
    - code-reuse exposure methodology
  ]
  #pause
  #grid(
    columns: (13fr, 7fr),
    column-gutter: 1em,
    card(palette.primary)[Hardware-based control-flow integrity][
      - *Call rewinding*
        - detects return address overwrites in microarchitecture
        - almost no impact on hardware resources and performance
      #pause
      - *Heatseeker*
        - dynamically detects JOP's dispatcher gadgets
        - transparent to software
        - formally proven detection capabilities
      #pause
    ],

    card(palette.primary)[Supporting tools][
      - *_Inspecteur-gadget_*: a RISC-V and ARM gadget finder
      - *_Crætor_*: a code-reuse attack generator
      - *_Aspycot_*: a Spike and Python cosimulation testbench for hardware monitoring IPs
    ],
  )
]


== Perspectives

#slide(title: "Perspectives")[
  #card(palette.primary)[From exposure assessment to exploit][
    The exposure score is today a *static estimate* (not yet published)

    #v(0.3em)
    - Improve the analysis based on actual memory vulnerabilities
    - Automatic chaining of the most useful gadgets
  ]

  #pause

  #card(palette.primary)[Countermeasures beyond ROP and JOP][
    Generalization of *low-level signatures* for all code-reuse attacks, e.g. data-oriented programming, loop-oriented programming

    #v(0.3em)
    - Do such signatures exist for other code-reuse attacks?
    - Are they precise enough for hardware, and separable from legitimate code?
    - Are they applicable to other threat models?
  ]
]
