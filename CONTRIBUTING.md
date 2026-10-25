<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Contributing to FerroHEALTH

This repository is the family site and the shared brand. It ships no product
code: a change to a product belongs in that product's repository, and a change
here says how the products fit together and nothing a product's own site should
say instead. The working discipline is in [`CLAUDE.md`](CLAUDE.md) and the rule
files under [`.claude/rules/`](.claude/rules/); read those before writing.

## Build and check

```bash
mdbook-lint lint website/book/src
scripts/site/assemble.sh _site
scripts/checks/internal-links.sh _site
scripts/checks/csp.sh _site
scripts/checks/book-revisions.sh
scripts/checks/writing-style.sh
scripts/checks/svg-first.sh
scripts/checks/licence-links.sh
scripts/checks/no-typed-version.sh
scripts/checks/diagram-generated.sh
python3 -m http.server -d _site 8000
```

Look at the page before calling it right: light and dark, wide and narrow.

## How the site is built

### The layout

```
assets/brand/              the FerroHEALTH mark, lockups, favicons, social card, palette
assets/diagrams/           the architecture diagram, self-contained and theme-adaptive
website/landing/           the site: one page, its stylesheet, and its static files
  assets/products/         a copy of each product's own mark, for the product cards
website/book/              the family book (mdBook), published at /docs/
scripts/site/assemble.sh   builds the site and the book the way GitHub Pages serves them
scripts/site/toolchain.sh  pins mdbook, mdbook-lint and lychee for the book
scripts/site/render-releases.sh  fills every figure a product moves, from the GitHub API
scripts/diagrams/          draws the architecture diagram from declarations, with geometry checks
scripts/brand/             scores a product hue against the hues the family owns
scripts/checks/            what CI runs against the repository and the assembled site
.github/workflows/pages.yml    build on every push and pull request, deploy from main
.github/workflows/refresh.yml  re-render the committed fallbacks, one auto-merged pull request
```

### What assemble.sh renders

`assemble.sh` copies the landing directory and the brand directory into one
tree, and renders two things:

- every figure a product or a shared library moves, through
  `render-releases.sh` and the GitHub API: the latest release tag (the status
  table, the card badges, the image tag in the quick start), the day it was
  published, and the day of the last push.
  Without a token the page keeps the values committed in `index.html`, which
  are real and exactly as stale as the checkout.
- `sitemap.xml`'s `lastmod`, from the commit being deployed, with one entry
  per book page.
- the family book, with the mdbook pinned in `scripts/site/toolchain.sh`,
  each page then given its own hashed Content-Security-Policy.

The architecture diagram is one file, drawn by a generator that refuses to place anything on
anything else, and reusable anywhere:
[`assets/diagrams/README.md`](assets/diagrams/README.md) says how.

### How it is deployed

GitHub's Pages-with-Actions pattern, the same one the product repositories
use. A push to `main` assembles the site and deploys it; a pull request
assembles it and stops. A six-hourly schedule redeploys, so a release cut in
any product or shared library reaches the page without a commit here.

### How it stays fresh

Every fact on the page that a product can move is rendered, and everything
else is a design commitment or lives on the product's own site:

- **Rendered:** the latest release, its date, and the last push per product,
  by `scripts/site/render-releases.sh` at every deploy. For a planned product
  the same script renders the day its code last moved, so the first refresh
  pull request that renders a release tag is the signal to move its card into
  the released set.
- **Refreshed:** `.github/workflows/refresh.yml` runs the same script over the
  committed `index.html` every six hours. When a value moved it opens one pull
  request on `chore/refresh-release-fallbacks`, dispatches the required checks
  onto it, and enables auto-merge, so the checkout follows the products with
  nobody typing a version.
- **Guarded:** `scripts/checks/no-typed-version.sh` fails CI on a version-like
  token outside a rendered marker, in the page and the diagram. A specification
  version, a database version, a FHIR release name, a code system list or a
  crate list is not on this page at all; the product's site carries the pin.

The custom domain is configured in the repository's Pages settings, and
`website/landing/CNAME` travels with the artifact so the domain survives a
switch back to branch-based publishing.

### Conventions worth keeping

- **No external request at load time.** The page's CSP is `default-src 'self'`.
  That is why each product's mark is a committed copy under
  `website/landing/assets/products/`, and why there is no web font, no
  analytics, and no CDN.
- **No hand-typed version, and no hand-typed status.** A figure that describes
  a product is rendered from that product's repository, never typed into the
  page and left to rot. The page shows a release and a date and lets the reader
  judge.
- **The parent owns no hue.** FerroFORMS is rose, FerroEHR is rust, FerroTERM
  is teal, FerroBRIDGE is indigo, and FerroPIX, FerroFED,
  FerroSYS and FerroTASK are plum, azure, olive and emerald, chosen by measurement; FerroHEALTH is iron and
  steel, and borrows a hue only where its product is named. See
  [`assets/brand/README.md`](assets/brand/README.md).
- **A planned product says what it is for and nothing it has not done.** Its
  card names the product and the job, links its repository, shows the domain
  as text until it serves a page, and carries one rendered badge. The mark
  stays at four strokes: FerroFORMS, FerroEHR, FerroTERM and FerroBRIDGE are
  the data path, and FerroPIX, FerroFED, FerroSYS and FerroTASK
  frame it.
- **Authorisation stays with each product.** Every product is its own SMART
  App Launch 2.x resource server against the deployment's authorization
  server, through FerroAUTH's `ferrohealth-smart` in its own process. The family runs
  no central authorisation service, because one would hold the signing key
  every product's access depends on.
- **A library is never a product.** FerroAUTH, FerroAUDIT and FerroUI have
  their own section, cards in the parent's steel, a rendered release and no
  row in the status table, and the diagram draws them in a band outside the
  instance frame with no edges.

## Pull requests

- Branch from `main` with a conventional-type name (`feat/`, `fix/`, `chore/`,
  `docs/`, `refactor/`, `perf/`, `test/`, `ci/`, `build/`, `release/`).
- Every commit is signed, and the pull request body declares `Closes #<n>` for
  the tracker issue it answers, one `Closes` keyword per issue.
- Prose follows [`.claude/rules/writing-style.md`](.claude/rules/writing-style.md).
  No version or status is typed by hand: a fact a product moves is rendered by
  `scripts/site/render-releases.sh`.
- No AI or assistant attribution anywhere in the commits or the pull request.

## Licensing of contributions

The site, the scripts and the documentation are licensed under the Apache
License 2.0 ([`LICENSE`](LICENSE)). The brand assets in `assets/brand/` and
`assets/diagrams/` are all rights reserved, under the terms in
[`TRADEMARKS.md`](TRADEMARKS.md). By submitting a contribution you:

1. certify that you wrote it, or otherwise have the right to submit it under
   these terms;
2. license a change to an Apache-2.0 file under the Apache License 2.0 with
   the rest of those files, as section 5 of that licence already provides;
   and
3. grant Cadasto B.V., the copyright holder named in every file
   header, a perpetual, irrevocable, worldwide,
   royalty-free, transferable right to use, reproduce, modify, distribute,
   sublicense and relicense the contribution as part of the work under any
   terms. For a change to a brand asset, this grant is the only licence.

You keep your copyright, and each file keeps its licence for everyone, the
maintainer included. Point 3 is what keeps the work one work under one
licensor, the same terms every repository in the Ferro family carries, so a
transfer of the project can cover every line, not only the maintainer's own.
There is no separate agreement to sign: the pull request template carries a
checkbox recording your acceptance of these terms, and a pull request from a
person does not merge without it (the `contribution-licence-guard` check, backed
by `scripts/checks/contribution-licence.sh`).

## Security

Report a vulnerability privately through the address in
[`SECURITY.md`](SECURITY.md), never in a public issue.
