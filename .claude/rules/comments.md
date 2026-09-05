---
paths: ["website/**", "assets/**", "scripts/**", ".github/**"]
---

# Comments in HTML, CSS, SVG, and shell

This repository has no Rust, so FerroTERM's RFC 505 rules do not transfer
literally. The prime rule does.

## The prime rule: a comment earns its lines

The markup says what. A comment exists for what the markup cannot show: the
reason a value is what it is, the constraint that forces a shape, the source a
copied asset came from. Everything else has a durable home:

| Content | Home |
|---|---|
| What changed and why it is correct | the PR, never the file |
| A decision about the site or the brand | `CLAUDE.md`, `assets/brand/README.md` |
| The provenance of a copied asset | `website/landing/assets/products/README.md` |
| Pending work | a tracker issue, referenced as `TODO(#N)` |

No change-narration. "Previously", "now correctly", "the old grid is retired" is
PR text, and git history carries it. A comment describes the file as it is.

## Budgets

- An HTML or CSS comment run is at most 8 physical lines. The CSP note at the
  top of `index.html` is the one deliberate exception, because a reader editing
  the page has to understand what the policy forbids before they add a script
  tag.
- A shell comment run is at most 8 lines outside the file header. A script's
  header block explains what the script builds and what it refuses to do, which
  is worth its lines.
- Pending work is `TODO(#N)` with its issue number, in the comment syntax of the
  file. `FIXME`, `HACK`, `XXX`, and `WIP` are not used.

## SVG

- Every mark carries a `<title>` for assistive technology, and an
  `aria-label` on the root element.
- A file copied from another project keeps its own header comment and its SPDX
  line. Record why the copy exists in the directory README, not in the file.
- The brand SVGs carry a one-line comment saying which variant they are, because
  the file name alone does not say when to reach for it.
