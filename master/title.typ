#import "/touying.typ": *

#let _title(master, info) = {
  // Collect only the logos that are provided, all rendered at the same height
  let logos = (info.logo-academic, info.logo-cifre, info.logo-anrt)
    .filter(logo => logo != none)
    .map(logo => image(logo, height: 1.75em))

  let supervisors(supervisors) = if supervisors != none {
    set text(fill: master.colors.neutral-dark.darken(40%))
    let body = if type(supervisors) == array {
      supervisors.map(n => text(style: "oblique", n)).join(" and ")
    } else { supervisors }
    body = text("Supervised by " + body)
    block(spacing: 1.5em, body)
  }

  let jury(reviewers, examiners) = {
    set text(fill: master.colors.neutral-dark.darken(40%))
    if reviewers != none {
      let body = if type(reviewers) == array {
        reviewers.map(n => text(style: "oblique", n)).join(", ")
      } else { reviewers }
      body = text("Reviewers: " + body)
      block(spacing: 0.5em, body)
    }
    if examiners != none {
      let body = if type(examiners) == array {
        examiners.map(n => text(style: "oblique", n)).join(", ")
      } else { examiners }
      body = text("Examiners: " + body)
      block(spacing: 0.5em, body)
    }
  }

  let body = {
    set text(fill: master.colors.neutral-darkest)
    set std.align(top)
    block(
      width: 100%,
      inset: 2em,
      {
        text(size: 1.3em, weight: "medium", info.title)
        line(
          start: (0pt, -1.72pt),
          length: 91%,
          stroke: .03em + master.colors.primary,
        )
        place(dx: 91%, dy: -7% + 0.3pt, circle(
          radius: 1.5pt,
          stroke: .03em + master.colors.primary,
          fill: white,
        ))
        set text(size: 0.8em)
        if info.author != none {
          block(spacing: 0.7em, info.author)
        }
        if info.date != none {
          block(spacing: 0.7em, utils.display-info-date(master))
        }
        set text(size: 0.95em)
        supervisors(info.supervisors)
        jury(info.reviewers, info.examiners)
      },
    )

    // Logo row pinned to the bottom of the slide
    if logos.len() > 0 {
      place(
        bottom + left,
        dy: -0.5em,
        dx: 2em,
        grid(
          columns: logos.len(),
          column-gutter: 6em,
          align: horizon,
          ..logos,
        ),
      )
    }
  }

  body
}
