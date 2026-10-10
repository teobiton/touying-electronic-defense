# PhD Defense

This repository contains the PhD defense slides the following subject: “Execution control and anomaly detection in real-time embedded systems“.
The defense slides are in English.

## Structure of the repository

- `defense.typ` contains the structure of the document, no content is present in this file.
- `vendor/touying/` contains the source files of Touying.
- `master/*` contains the master slides components.
- `assets/*` contains the logos used in the defense.
- `src/*` are the source files of the defense, with its content.

## Compile document into PDF

Compiling the slides require a [Typst](https://typst.app/) installed and/or running.
To simply compile the slides:

	typst c defense.typ

Recompile on save:

	typst w defense.typ

Display the generated PDF:

	evince defense.pdf &


## CI

### Gitlab CI

The pipeline (`.gitlab-ci.yml`) runs on every push and merge request with changes to `.typ` files, and consists of three stages:

1. **`format`** — checks that all `.typ` files are formatted according to [typstyle](https://github.com/typstyle-rs/typstyle) (`typstyle --check .`).
   The pipeline fails if any file is not correctly formatted; it does not auto-format.
2. **`build`** — compiles `defense.typ` into `defense.pdf` with the Typst CLI, to ensure the document always builds.
   The resulting PDF is kept as a job artifact for one week.

Both `typst` and `typstyle` are installed via `cargo install`.

### Github CI

The Github pipeline (`.github/workflows/defense.yml`) works the same as GitLab's one.

## Pre-commit

A [pre-commit](https://pre-commit.com/) configuration (`.pre-commit-config.yaml`) is provided to catch formatting and build issues locally, before they reach CI.
The hooks run on `git push` (not `git commit`) via the `pre-push` stage:

- **`typstyle-check`** — same check as the CI `format` stage; fails the push if any `.typ` file is not formatted.
- **`typst-build`** — compiles `defense.typ` to a temporary file to confirm the project builds; fails the push on any compile error.

Setup (once per clone):

```bash
pip install pre-commit          # or: pipx install pre-commit
cargo install typstyle typst-cli  # if not already installed
pre-commit install --hook-type pre-push
```

After this, `git push` will run both checks automatically and abort the push if either fails.
To run them manually at any time:

```bash
pre-commit run --hook-stage pre-push --all-files
```
