#import "/touying.typ": *

#let _footer(master) = {
  set std.align(bottom)
  set text(size: 0.6em)
  block(
    width: 100%,
    height: 1.5em,
    fill: master.colors.secondary-lighter,
    place(
      bottom,
      pad(
        .5em,
        components.left-and-right(
          text(
            fill: master.colors.secondary-lightest,
            utils.call-or-display(master, master.store.footer),
          ),
          text(fill: master.colors.secondary-lightest, utils.call-or-display(
            master,
            master.store.footer-right,
          )),
        ),
      ),
    ),
  )
  if master.store.footer-progress {
    place(bottom, components.progress-bar(
      height: 2pt,
      master.colors.secondary,
      master.colors.secondary-lightest.darken(40%),
    ))
  }
}
