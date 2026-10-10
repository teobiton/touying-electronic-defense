#import "globals.typ": palette
#import "touying.typ": *
#import "master/lib.typ": *

#show: phd-theme.with(
  aspect-ratio: "16-9",
  header-with-mini-slides: true,
  palette: palette,
  mini-slides: (
    fill: rgb("#ffffff"),
    alpha: 67%,
    display-section: true,
    display-subsection: true,
    linebreaks: false,
    short-heading: true,
    inline: false,
  ),
  config-info(
    title: [Execution control and anomaly detection \ in real-time embedded systems],
    author: [Téo Biton],
    logo-academic: "/assets/ietr-logo.png",
    logo-cifre: none,
    logo-anrt: none,
    date: "November 3rd, 2026",
    supervisors: "-",
    reviewers: "-",
    examiners: "-",
  ),
  config-common(
    new-section-slide-fn: none,
  ),
  config-store(
    footer: [Téo Biton --- Execution control and anomaly detection in real-time embedded systems],
  ),
)

#set text(font: "Linux Biolinum O")

#show cite: set text(size: 0.9em, weight: "extrabold")
#show cite: it => h(0.2em) + it
#show bibliography: set heading(bookmarked: false, outlined: false, level: 2)
#show bibliography: set text(size: 0.7em)
#show bibliography: set par(leading: 0.65em, spacing: 0.8em)

#set cite(style: "chicago-shortened-notes")
#set footnote(numbering: "[1] ")

#show footnote: set super(typographic: false, size: 1em, baseline: 0em)
#show footnote.entry: set super(typographic: false, size: 1em, baseline: 0em)

#set super(size: 0.75em, baseline: 0em)
#show super: it => {
  text(palette.secondary-lighter)[#it]
}

#set figure(numbering: none)

#title-slide()

#include "slides/intro/intro.typ"
#include "slides/cfi/cfi.typ"
#include "slides/return/return.typ"
#include "slides/jump/jump.typ"
#include "slides/concl/conclusion.typ"
#include "slides/appendix.typ"
