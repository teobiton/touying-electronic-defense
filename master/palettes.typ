#let palettes = (
  mono-red: (
    name: "Monochrome and red",
    primary: rgb("#c0272d"),
    primary-light: rgb("#f3cfd0"),
    secondary: rgb("#101010"),
    secondary-lighter: rgb("#2e2e2e"),
    secondary-light: rgb("#fafafa"),
    secondary-lightest: rgb("#f0f0f0"),
    neutral-lightest: rgb("#ffffff"),
    neutral-dark: rgb("#555555"),
    neutral-darkest: rgb("#111111"),
  ),
  indigo: (
    name: "Indigo",
    primary: rgb("#3b3b8f"),
    primary-light: rgb("#c9c9e6"),
    secondary: rgb("#1a1a3d"),
    secondary-lighter: rgb("#2a2a63"),
    secondary-light: rgb("#f7f7fc"),
    secondary-lightest: rgb("#f0f0f5"),
    neutral-lightest: rgb("#ffffff"),
    neutral-dark: rgb("#4e4f66"),
    neutral-darkest: rgb("#17182e"),
  ),
)

#let color-keys = (
  "primary",
  "primary-light",
  "secondary",
  "secondary-lighter",
  "secondary-light",
  "secondary-lightest",
  "neutral-lightest",
  "neutral-dark",
  "neutral-darkest",
)

// Returns only the colour keys of a palette, ready to spread into `config-colors(..palette-colors("navy"))`.
// Accepts either a key from `palettes` or a palette dictionary.
#let palette-colors(p) = {
  let d = if type(p) == str { palettes.at(p) } else { p }
  let out = (:)
  for k in color-keys {
    out.insert(k, d.at(k))
  }
  out
}
