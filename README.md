# PhD Defense

This repository contains the slides of my PhD defense on the following subject: “Execution control and anomaly detection in real-time embedded systems”.
The slides are in English and are written in [Typst](https://typst.app/) with the [Touying](https://github.com/touying-typ/touying) presentation framework.

## Getting the sources

Touying is included as a git submodule (pinned to version 0.8.0), so clone the repository with its submodules:

```bash
git clone --recurse-submodules https://github.com/teobiton/touying-electronic-defense.git
```

If you already cloned it without submodules:

```bash
git submodule update --init
```

## Structure of the repository

- `defense.typ` is the entry point: it sets up the theme and the document structure, and includes the slides; no slide content is written in this file.
- `globals.typ` and `touying.typ` hold shared definitions and the Touying import used across the slides.
- `master/` contains the master slide components (theme, palettes, header, footer, title slide).
- `slides/` contains the content of the defense, one directory per part (`intro`, `cfi`, `return`, `jump`, `concl`), each with its own schematics and assets, plus `appendix.typ`.
- `assets/` contains the logos and shared images.
- `bibliography/` contains the bibliography and the list of publications (BibTeX).
- `vendor/touying/` is the Touying submodule.
- `defense.pdfpc` is the [pdfpc](https://pdfpc.github.io/) presenter configuration (45-minute timer).

## Compile the slides into PDF

Requirements:

- [Typst](https://github.com/typst/typst) (CI uses version 0.15.1), e.g. `cargo install typst-cli --locked`.
- The Linux Libertine / Biolinum fonts (`fonts-linuxlibertine` on Debian/Ubuntu), used for the main text.

Compile the slides:

```bash
typst compile defense.typ
```

Recompile on save:

```bash
typst watch defense.typ
```

Display the generated PDF:

```bash
evince defense.pdf &
```

Or present it with pdfpc, which picks up `defense.pdfpc` automatically:

```bash
pdfpc defense.pdf
```

## CI

### GitHub Actions

The workflow (`.github/workflows/defense.yml`) runs on every push and pull request with changes to `.typ` files, and consists of two jobs:

1. **`format`** — checks that all `.typ` files are formatted according to [typstyle](https://github.com/typstyle-rs/typstyle) (`typstyle --check defense.typ globals.typ slides master`).
   The job fails if any file is not correctly formatted; it does not auto-format.
2. **`build`** — compiles `defense.typ` with the Typst CLI, to ensure the document always builds.
   The resulting PDF (`defense-<commit>.pdf`) is uploaded as a workflow artifact and kept for 7 days.

Both `typst` and `typstyle` are installed via `cargo install` and cached between runs.

### GitLab CI

The GitLab pipeline (`.gitlab-ci.yml`) mirrors the GitHub workflow with two stages, `format` and `build`, under the same conditions.
The PDF is kept as a job artifact for one week.

## Pre-commit

A [pre-commit](https://pre-commit.com/) configuration (`.pre-commit-config.yaml`) is provided to catch formatting and build issues locally, before they reach CI.
The hooks run on `git push` (not `git commit`) via the `pre-push` stage:

- **`typstyle-check`** — same check as the CI `format` job; fails the push if any `.typ` file is not formatted.
- **`typst-build`** — compiles `defense.typ` to a temporary file to confirm the project builds; fails the push on any compile error.

Setup (once per clone):

```bash
pip install pre-commit             # or: pipx install pre-commit
cargo install typstyle typst-cli   # if not already installed
pre-commit install
```

After this, `git push` will run both checks automatically and abort the push if either fails.
To run them manually at any time:

```bash
pre-commit run --hook-stage pre-push --all-files
```

## License

The content of this repository is licensed under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/); see [`LICENSE`](LICENSE).

Third-party material is not covered by this license and remains under its own terms, in particular:

- `vendor/touying/` — Touying, distributed under its own license (see `vendor/touying/LICENSE`).
- The IETR logo (`assets/ietr-logo.png`), a trademark of its owner.
