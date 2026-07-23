# Docs

The guide is a [Bikeshed](https://speced.github.io/bikeshed/) source
(`spec.bs`) with [PlantUML](https://plantuml.com) diagrams rendered to SVG.
It is built and published to GitHub Pages by `.github/workflows/docs.yaml` on
every push to `main` that touches `docs/`.

## Build locally

```bash
# one-time
pipx install bikeshed && bikeshed update
brew install plantuml graphviz     # or: apt-get install plantuml graphviz

# from the repo root
plantuml -tsvg docs/diagrams/*.puml
bikeshed spec docs/spec.bs docs/index.html
open docs/index.html
```

`task docs:build` from the repo root runs both steps.

The generated `docs/index.html` and `docs/diagrams/*.svg` are git-ignored; they
are produced in CI and deployed as the Pages artifact.

## Enable GitHub Pages

In the repository settings, set Pages source to "GitHub Actions". The `docs`
workflow then publishes to `https://computeflux-xyz.github.io/shared-infrastructure/`.
