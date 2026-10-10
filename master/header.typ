#import "/touying.typ": *

#let _header(master, title) = {
  set std.align(top)
  set text(size: 0.85em)

  if master.store.header-with-mini-slides {
    grid(
      rows: (auto, auto),
      block(
        above: 0pt,
        below: 0pt,
        height: 50%,
        inset: (top: -.25em, left: -.5em),
        fill: master.colors.secondary,
        stroke: (bottom: master.colors.primary.lighten(20%)),
        components.mini-slides(
          self: master,
          fill: master.store.mini-slides.at("fill", default: rgb("#ffffff")),
          alpha: master.store.mini-slides.at("alpha", default: 60%),
          display-section: master.store.mini-slides.at(
            "display-section",
            default: false,
          ),
          display-subsection: master.store.mini-slides.at(
            "display-subsection",
            default: true,
          ),
          linebreaks: master.store.mini-slides.at("linebreaks", default: true),
          short-heading: master.store.mini-slides.at(
            "short-heading",
            default: true,
          ),
          inline: master.store.mini-slides.at("inline", default: false),
        ),
      ),

      block(
        width: 100%,
        height: 2.4em,
        fill: master.colors.primary,
        place(
          left + horizon,
          text(
            fill: master.colors.secondary-lightest,
            size: 1.2em,
            if title != auto {
              utils.fit-to-width(grow: false, 100%, title)
            } else {
              utils.call-or-display(master, master.store.header)
            },
          ),
          dx: 1.5em,
        ),
      ),
    )
  } else {
    block(
      width: 100%,
      height: 2.4em,
      fill: master.colors.secondary-lighter,
      place(
        left + horizon,
        text(
          fill: master.colors.secondary-lightest,
          size: 1.2em,
          if title != auto {
            utils.fit-to-width(grow: false, 100%, title)
          } else {
            utils.call-or-display(master, master.store.header)
          },
        ),
        dx: 1.5em,
      ),
    )
  }
}
