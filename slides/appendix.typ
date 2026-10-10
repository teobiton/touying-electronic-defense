#import "/touying.typ": *
#import "/master/lib.typ": *
#import "jump/schematics.typ": *

#show: appendix
#show: touying-set-config.with(
  config-store(
    header-with-mini-slides: false,
  ),
)

= Appendix <touying:hidden>

#focus-slide(
  [Thank you.],
)

== Bibliography <touying:hidden>

#v(-2em)
#bibliography(
  "/bibliography/bibliography.bib",
  title: none,
)

== Publications <touying:hidden>

#v(-2em)
#bibliography(
  "/bibliography/publications.bib",
  full: true,
  title: none,
  group: "publications",
)

// ---------------------------------------------------------------------------
// Area heatseeker + call rewinding
// ---------------------------------------------------------------------------

== Call rewinding and heatseeker hand in hand <touying:hidden>

#{
  set text(size: 0.8em)
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
    [CVA6 32-bit baseline], [17,906], [], [9,886], [],
    [\+ call rewinding], [18,028], [*+0.68~%*], [9,939], [*+0.53~%*],
    [\+ heatseeker], [18,310], [*+2.23~%*], [10,219], [*+3.31~%*],
    [\+ call rewinding & heatseeker],
    [18,360],
    [*+2.50~%*],
    [10,284],
    [*+3.95~%*],
    table.hline(stroke: 1pt),
  ))
}

// ---------------------------------------------------------------------------
// Sigreturn user mode false positive
// ---------------------------------------------------------------------------

== Corner case: `sigreturn` in U-mode <touying:hidden>

#grid(
  columns: (1fr, 1fr),
  gutter: 1.5em,
  [
    *Problem: false positive*
    - At the end of each handled signal, the address of the `sigreturn` syscall is written in `ra` and jumped to
    - This construct does not respect the ABI
    - Leads to a false positive
  ],
  [
    *Solution: exception handler*
    - Catches the exception
    - Allows the return if `ra` points to the `sigreturn` syscall in memory
  ],
)

// ---------------------------------------------------------------------------
// Ddisp
// ---------------------------------------------------------------------------

== Sizing $D_"dispatcher"$ <touying:hidden>

#{
  set align(center + top)
  v(-1em)
  image("/assets/d_dispatcher.png")
}

// ---------------------------------------------------------------------------
// Formal proof
// ---------------------------------------------------------------------------

== Proof of Detection with CBMC <touying:hidden>

#grid(
  columns: (1.7fr, 1fr),
  gutter: 1.5em,
  align: horizon,
  [
    #v(0.7em)
    #set text(size: 0.85em)
    *Attack model*: $"NumOp"$ steps $(italic("As")_i, italic("Ad")_i, R_i)$, alternating towards / from DG
    - DG size < #Ddisp, #RD #sym.eq.not #RF
    - Up to $"MaxR" = floor(N_"entries" \/ 2)$ registers holding the DG address
    - Gadget addresses distinct within windows of #Nent
  ],
  [
    #align(center, _proof)
    #set text(size: 0.8em)
    - $P_1$: the initial state satisfies $cal(I)$
    - $P_2$: any jump preserves $cal(I)$
    - $P_3$: from $cal(I)$, any attack raises an alarm
  ],
)

#key[$cal(I)$: well-formed LRU caches #sym.arrow.r detection from *any* reachable state]

== Proof Results and Limits <touying:hidden>

#grid(
  columns: (1fr, 1.2fr),
  gutter: 2em,
  align: horizon,
  [
    #set text(size: 0.85em)
    #align(center, table(
      columns: 4,
      align: center + horizon,
      stroke: none,
      inset: 0.5em,
      table.hline(stroke: 1pt),
      table.header([*#Nent*], [*MaxR*], [*NumOp*], [*Time*]),
      table.hline(stroke: 0.6pt),
      [3], [1], [5], [1.0~s],
      [4], [2], [9], [3.5~s],
      [5], [2], [11], [8.2~s],
      [6], [3], [15], [32.2~s],
      table.hline(stroke: 1pt),
    ))
    #caption[No counterexample found]
  ],
  [
    #set text(size: 0.9em)
    - #Nent = 3 proves the standard pattern
    - Larger caches tolerate more dispatcher registers
  ],
)
