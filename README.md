<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# <img src="assets/brand/ferrohealth-lockup-auto.svg" alt="FerroHEALTH" width="290" height="64">

[![Pages](https://github.com/FerroHEALTH/FerroHEALTH/actions/workflows/pages.yml/badge.svg?branch=main)](https://github.com/FerroHEALTH/FerroHEALTH/actions/workflows/pages.yml)
[![Code: Apache-2.0](https://img.shields.io/badge/Code-Apache--2.0-blue.svg)](LICENSE)
[![Brand: all rights reserved](https://img.shields.io/badge/Brand-all%20rights%20reserved-lightgrey.svg)](TRADEMARKS.md)

The family site for five pure-Rust health-data servers, published at
**<https://ferrohealth.eu/>**. This repository holds the site and the shared
brand; it holds no product code.

| Product | Does | Site |
|---|---|---|
| [FerroCHART](https://github.com/FerroHEALTH/FerroCHART) | An openEHR form builder and renderer: takes the record down | <https://ferrochart.eu/> |
| [FerroEHR](https://github.com/FerroHEALTH/FerroEHR) | An openEHR Clinical Data Repository: stores and queries the record | <https://ferroehr.eu/> |
| [FerroTERM](https://github.com/FerroHEALTH/FerroTERM) | An HL7 FHIR terminology server: answers what a code means | <https://ferroterm.eu/> |
| [FerroBRIDGE](https://github.com/FerroHEALTH/FerroBRIDGE) | A bridge from openEHR to FHIR and to the OMOP CDM: carries the record onward | <https://ferrobridge.eu/> |
| [FerroFED](https://github.com/FerroHEALTH/FerroFED) | An openEHR federation gateway: queries the record where it lives | <https://ferrofed.eu/> |

Each product is released from its own repository under the Business Source
License 1.1, documents itself on its own domain, and runs without the
others. This site says how they fit together and nothing a product's own site
should say instead.

Four more are planned around them. Each has a registered domain and a
repository that opens with its licence and its brand, and the page shows them
as dashed cards whose one status line is read from GitHub: the day the code
last moved.

| Planned | Will do | Domain |
|---|---|---|
| [FerroPIX](https://github.com/FerroHEALTH/FerroPIX) | A Master Patient Index: who the patient is, and where the record is | `ferropix.eu` |
| [FerroSMART](https://github.com/FerroHEALTH/FerroSMART) | The SMART on openEHR server: who may act | `ferrosmart.eu` |
| [FerroSYS](https://github.com/FerroHEALTH/FerroSYS) | The control plane: how it all runs | `ferrosys.eu` |
| [FerroTASK](https://github.com/FerroHEALTH/FerroTASK) | Task planning and decision support: what happens next | `ferrotask.eu` |

![What calls what across the FerroHEALTH family](assets/diagrams/ferrohealth-architecture.svg)

The diagram is one file, drawn by a generator that refuses to place anything on
anything else, and reusable anywhere:
[`assets/diagrams/README.md`](assets/diagrams/README.md) says how.

## Layout

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

## Build it

```bash
scripts/site/assemble.sh _site        # assemble into _site/, the book at _site/docs/
scripts/checks/internal-links.sh _site  # every local link resolves
scripts/checks/csp.sh _site           # every page names all its inline code
python3 -m http.server -d _site 8000  # then open http://localhost:8000/
```

`assemble.sh` copies the landing directory and the brand directory into one
tree, and renders two things:

- every figure a product moves, through `render-releases.sh` and the GitHub
  API: the latest release tag (the status table, the card badges, the image tag
  in the quick start), the day it was published, and the day of the last push.
  Without a token the page keeps the values committed in `index.html`, which
  are real and exactly as stale as the checkout.
- `sitemap.xml`'s `lastmod`, from the commit being deployed, with one entry
  per book page.
- the family book, with the mdbook pinned in `scripts/site/toolchain.sh`,
  each page then given its own hashed Content-Security-Policy.

## The family book

<https://ferrohealth.eu/docs/> holds what is true for every product and for
Cadasto B.V. as their manufacturer: the manufacturer, the security policy, the
post-market procedure, the CRA's manufacturer side, the EHDS EHR system,
licensing and trademarks, and how the products fit together. Each product's
own book links it and keeps only what is about that product. Every page is
dated, and `website/book/src/revisions.md` records each revision, so a product
release can name the revision of a family page it relies on.

## How it is deployed

GitHub's Pages-with-Actions pattern, the same one the four product
repositories use. A push to `main` assembles the site and deploys it; a pull
request assembles it and stops. A six-hourly schedule redeploys, so a release
cut in any of the four products reaches the status table without a commit here.

## How it stays fresh

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

## Conventions worth keeping

- **No external request at load time.** The page's CSP is `default-src 'self'`.
  That is why each product's mark is a committed copy under
  `website/landing/assets/products/`, and why there is no web font, no
  analytics, and no CDN.
- **No hand-typed version, and no hand-typed status.** A figure that describes
  a product is rendered from that product's repository, never typed into the
  page and left to rot. The page shows a release and a date and lets the reader
  judge.
- **The parent owns no hue.** FerroCHART is rose, FerroEHR is rust, FerroTERM
  is teal, FerroBRIDGE is indigo, and FerroPIX, FerroSMART, FerroFED,
  FerroSYS and FerroTASK are plum, bronze, azure, olive and emerald, chosen by measurement; FerroHEALTH is iron and
  steel, and borrows a hue only where its product is named. See
  [`assets/brand/README.md`](assets/brand/README.md).
- **A planned product says what it is for and nothing it has not done.** Its
  card names the product and the job, links its repository, shows the domain
  as text until it serves a page, and carries one rendered badge. The mark
  stays at four strokes: FerroCHART, FerroEHR, FerroTERM and FerroBRIDGE are
  the data path, and FerroPIX, FerroSMART, FerroFED, FerroSYS and FerroTASK
  frame it.

## Contributing

Contributions carry the terms in
[CONTRIBUTING.md](CONTRIBUTING.md#licensing-of-contributions): you keep your
copyright, each file keeps its licence, and you grant the Licensor the
relicensing right that keeps the work one work under one licensor. The pull
request template records your acceptance and a check enforces it.

## Licence

The site, the scripts and the documentation in this repository are
[Apache-2.0](LICENSE). The FerroHEALTH brand assets (the artwork in
`assets/brand/` and the diagram in `assets/diagrams/`) are all rights
reserved, under the terms in [`TRADEMARKS.md`](TRADEMARKS.md): you may use
them unmodified to refer to the projects, and anything else needs permission.
`TRADEMARKS.md` also covers the use of the product names. Each product's
mark under `website/landing/assets/products/` belongs to that project and
keeps its licence. The products themselves are BUSL-1.1, with the parameters that apply
in each repository's own licence file:
[FerroCHART](https://github.com/FerroHEALTH/FerroCHART/blob/main/LICENSE),
[FerroEHR](https://github.com/FerroHEALTH/FerroEHR/blob/main/LICENSE),
[FerroTERM](https://github.com/FerroHEALTH/FerroTERM/blob/main/LICENSE),
[FerroBRIDGE](https://github.com/FerroHEALTH/FerroBRIDGE/blob/main/LICENSE),
[FerroPIX](https://github.com/FerroHEALTH/FerroPIX/blob/main/LICENSE),
[FerroSMART](https://github.com/FerroHEALTH/FerroSMART/blob/main/LICENSE),
[FerroFED](https://github.com/FerroHEALTH/FerroFED/blob/main/LICENSE),
[FerroSYS](https://github.com/FerroHEALTH/FerroSYS/blob/main/LICENSE),
[FerroTASK](https://github.com/FerroHEALTH/FerroTASK/blob/main/LICENSE).
The site states what those terms mean at
<https://ferrohealth.eu/#licensing>.

openEHR® is a registered trademark of the openEHR Foundation. HL7® and FHIR®
are registered trademarks of Health Level Seven International. SNOMED CT® is a
registered trademark of SNOMED International. None of these organisations
endorse FerroHEALTH.
