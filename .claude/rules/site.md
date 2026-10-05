---
paths: ["website/**", "assets/**", "scripts/site/**"]
---

# The site

One page at <https://ferrohealth.eu/>, assembled by `scripts/site/assemble.sh`
and published by `.github/workflows/pages.yml`. No framework, no build step
beyond that script, no runtime dependency.

## Hard rules

- **Nothing loads from another origin.** The page's CSP is `default-src 'self'`,
  set in a `<meta http-equiv>` because GitHub Pages sets no response headers.
  That means no web font, no analytics, no CDN, and no hotlinked image. A
  product's mark is a committed copy under
  `website/landing/assets/products/`, with its source recorded in the README
  there.
- **No inline `<style>` or `style=` attribute.** `style-src 'self'` blocks
  them in the page. A style lives in `style.css`.
- **A diagram is a file in `assets/diagrams/`, loaded with `<img>`.** It carries
  its palette as literal values and swaps them on `prefers-color-scheme` inside
  the file, which is what lets the same file serve the page, a product README,
  and a slide. That `<style>` is inside the image document, so the page's CSP
  does not reach it. The architecture diagram is drawn by
  `scripts/diagrams/ferrohealth-architecture.py` from declared boxes and
  edges, and the script refuses to draw a box on a box, a line through a box,
  two lines crossing or a label on anything. Edit the declarations, regenerate,
  and never the SVG. `assets/diagrams/README.md` carries the conventions and
  the raster command.
- **A planned product says what it is for, and its one status is rendered.**
  FerroPIX, FerroSMART, FerroSYS and FerroTASK have a name, a domain and a repository
  with their licence and brand, and no release. Each is a dashed
  card in the products section with the product's job, the standards it
  intends to speak, a GitHub link, the domain as text (linked only once it
  serves a page) and a `data-repo` badge that `scripts/site/render-releases.sh`
  fills: "code moved <day>" from the last push, "no repository yet" from a
  404. Its `LICENSE` is linked in the licensing section and checked by
  `scripts/checks/licence-links.sh`. No "planned since", no "coming soon", no
  row in the status table. When it publishes a first release, the refresh
  pull request renders the tag; that is when the card moves into the released
  grid, its site is linked, and it joins the status table.
- **No hand-typed version, and no hand-typed status.** A fact a product moves
  carries a marker (`data-rel`, `data-rel-plain`, `data-rel-date`,
  `data-pushed`) and is filled by `scripts/site/render-releases.sh` from that
  product's repository: the latest release, its date, and the last push. The
  committed value is real so an assembly without a token still produces
  commands that run, and `.github/workflows/refresh.yml` moves it through a
  pull request when a product releases. A specification version, a database
  version, a FHIR release name, a code system list or a crate list is not
  rendered and so is not typed: the page names the standard and links the
  product's site for the pin. `scripts/checks/no-typed-version.sh` fails the
  build on a version-like token outside a marker, in the page and the diagram.
- **Relative URLs inside the site.** The page has to work from a checkout, from
  a preview, and from the apex domain without a rewrite. Product links are
  absolute, because they point at another domain.
- **A licence link points at the licensed product's own `LICENSE`.** The
  Business Source License 1.1 is a template, and a generic copy of it carries an
  empty Additional Use Grant and no Change Date. The terms live in each product
  repository's `LICENSE`, so `#licensing` links every product's and states in place
  what is free and what needs a commercial licence.
  `scripts/checks/licence-links.sh` fails the build on a boilerplate link and on
  a product the page names without linking its licence.
- **Every local link resolves.** `scripts/checks/internal-links.sh` runs in CI
  over the assembled site and covers hrefs, srcs, and same-page fragments.

## The brand

`assets/brand/README.md` is the authority. Two rules reach the page:

- FerroHEALTH owns iron and steel. Each product owns its hue, and the page
  spends a product hue only where that product is named: the card rule, the
  dot, the diagram box, the hero glow. The glow and the mark carry the four
  strokes only; FerroPIX, FerroSMART, FerroFED, FerroSYS and FerroTASK have no stroke,
  released or not, because they frame the data path and are not on it.
- Every product's hue in `assets/brand/tokens.css` is copied verbatim from
  that product's own `tokens.css`. When a product changes its palette, copy
  the new value; never eyeball a near match. A new hue is chosen with
  `scripts/brand/hue-distance.py` and recorded with its numbers in
  `assets/brand/README.md` before it goes into the product's `tokens.css`.

## Scope

The page says what each product does and how the four fit together. Anything a
product's own site should say belongs there. Adding a benchmark table, a
conformance grid, or an API reference here duplicates a page that is already
generated from evidence in the product's repository, and the copy here would go
stale within a release.
