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
  does not reach it. `assets/diagrams/README.md` carries the conventions and the
  raster command.
- **No hand-typed version.** A version on the page carries a `data-rel` or
  `data-rel-plain` marker and is filled by `assemble.sh` from that product's
  latest release. The committed value is a real release so an assembly without a
  token still produces commands that run.
- **Relative URLs inside the site.** The page has to work from a checkout, from
  a preview, and from the apex domain without a rewrite. Product links are
  absolute, because they point at another domain.
- **A licence link points at the licensed product's own `LICENSE`.** The
  Business Source License 1.1 is a template, and a generic copy of it carries an
  empty Additional Use Grant and no Change Date. The terms live in each product
  repository's `LICENSE`, so `#licensing` links those three and states in place
  what is free and what needs a commercial licence.
  `scripts/checks/licence-links.sh` fails the build on a boilerplate link and on
  a product the page names without linking its licence.
- **Every local link resolves.** `scripts/checks/internal-links.sh` runs in CI
  over the assembled site and covers hrefs, srcs, and same-page fragments.

## The brand

`assets/brand/README.md` is the authority. Two rules reach the page:

- FerroHEALTH owns iron and steel. Each product owns its hue, and the page
  spends a product hue only where that product is named: the card rule, the
  dot, the diagram box, the hero glow.
- A product hue in `assets/brand/tokens.css` is copied verbatim from that
  product's own `tokens.css`. When a product changes its palette, copy the new
  value; never eyeball a near match.

## Scope

The page says what each product does and how the three fit together. Anything a
product's own site should say belongs there. Adding a benchmark table, a
conformance grid, or an API reference here duplicates a page that is already
generated from evidence in the product's repository, and the copy here would go
stale within a release.
