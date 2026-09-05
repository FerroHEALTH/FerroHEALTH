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
  them. A style lives in `style.css`, and an inline SVG is coloured through CSS
  classes so one copy works in light and dark.
- **No hand-typed version.** A version on the page carries a `data-rel` or
  `data-rel-plain` marker and is filled by `assemble.sh` from that product's
  latest release. The committed value is a real release so an assembly without a
  token still produces commands that run.
- **Relative URLs inside the site.** The page has to work from a checkout, from
  a preview, and from the apex domain without a rewrite. Product links are
  absolute, because they point at another domain.
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
