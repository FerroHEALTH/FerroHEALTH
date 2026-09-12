<!-- SPDX-FileCopyrightText: Ruben Talstra -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# <img src="assets/brand/ferrohealth-lockup-auto.svg" alt="FerroHEALTH" width="290" height="64">

[![Pages](https://github.com/rubentalstra/FerroHEALTH/actions/workflows/pages.yml/badge.svg?branch=main)](https://github.com/rubentalstra/FerroHEALTH/actions/workflows/pages.yml)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)

The family site for four pure-Rust health-data servers, published at
**<https://ferrohealth.eu/>**. This repository holds the site and the shared
brand; it holds no product code.

| Product | Does | Site |
|---|---|---|
| [FerroCHART](https://github.com/rubentalstra/FerroCHART) | An openEHR form builder and renderer: takes the record down | <https://ferrochart.eu/> |
| [FerroEHR](https://github.com/rubentalstra/FerroEHR) | An openEHR Clinical Data Repository: stores and queries the record | <https://ferroehr.eu/> |
| [FerroTERM](https://github.com/rubentalstra/FerroTERM) | An HL7 FHIR terminology server: answers what a code means | <https://ferroterm.eu/> |
| [FerroBRIDGE](https://github.com/rubentalstra/FerroBRIDGE) | A bridge from openEHR to FHIR and to the OMOP CDM: carries the record onward | <https://ferrobridge.eu/> |

Each product is released from its own repository under the Business Source
License 1.1, documents itself on its own domain, and runs without the other
three. This site says how they fit together and nothing a product's own site
should say instead.

![What calls what across FerroCHART, FerroEHR, FerroTERM and FerroBRIDGE](assets/diagrams/ferrohealth-architecture.svg)

The diagram is one file, reusable anywhere:
[`assets/diagrams/README.md`](assets/diagrams/README.md) says how.

## Layout

```
assets/brand/              the FerroHEALTH mark, lockups, favicons, social card, palette
assets/diagrams/           the architecture diagram, self-contained and theme-adaptive
website/landing/           the site: one page, its stylesheet, and its static files
  assets/products/         a copy of each product's own mark, for the product cards
scripts/site/assemble.sh   builds the site the way GitHub Pages serves it
scripts/site/render-releases.sh  fills every figure a product moves, from the GitHub API
scripts/checks/            what CI runs against the repository and the assembled site
.github/workflows/pages.yml    build on every push and pull request, deploy from main
.github/workflows/refresh.yml  re-render the committed fallbacks, one auto-merged pull request
```

## Build it

```bash
scripts/site/assemble.sh _site        # assemble into _site/
scripts/checks/internal-links.sh _site  # every local link resolves
python3 -m http.server -d _site 8000  # then open http://localhost:8000/
```

`assemble.sh` copies the landing directory and the brand directory into one
tree, and renders two things:

- every figure a product moves, through `render-releases.sh` and the GitHub
  API: the latest release tag (the status table, the card badges, the image tag
  in the quick start), the day it was published, and the day of the last push.
  Without a token the page keeps the values committed in `index.html`, which
  are real and exactly as stale as the checkout.
- `sitemap.xml`'s `lastmod`, from the commit being deployed.

## How it is deployed

GitHub's Pages-with-Actions pattern, the same one the four product
repositories use. A push to `main` assembles the site and deploys it; a pull
request assembles it and stops. A six-hourly schedule redeploys, so a release
cut in any of the four products reaches the status table without a commit here.

## How it stays fresh

Every fact on the page that a product can move is rendered, and everything
else is a design commitment or lives on the product's own site:

- **Rendered:** the latest release, its date, and the last push per product,
  by `scripts/site/render-releases.sh` at every deploy.
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
  is teal, FerroBRIDGE is indigo; FerroHEALTH is iron and steel, and borrows
  the four only where a
  product is named. See [`assets/brand/README.md`](assets/brand/README.md).

## Licence

The site, the scripts and the FerroHEALTH brand assets in this repository are
[Apache-2.0](LICENSE). Each product's mark under
`website/landing/assets/products/` belongs to that project and keeps its
licence. The products themselves are BUSL-1.1, with the parameters that apply
in each repository's own licence file:
[FerroCHART](https://github.com/rubentalstra/FerroCHART/blob/main/LICENSE),
[FerroEHR](https://github.com/rubentalstra/FerroEHR/blob/main/LICENSE),
[FerroTERM](https://github.com/rubentalstra/FerroTERM/blob/main/LICENSE),
[FerroBRIDGE](https://github.com/rubentalstra/FerroBRIDGE/blob/main/LICENSE).
The site states what those terms mean at
<https://ferrohealth.eu/#licensing>.

openEHR® is a registered trademark of the openEHR Foundation. HL7® and FHIR®
are registered trademarks of Health Level Seven International. SNOMED CT® is a
registered trademark of SNOMED International. None of these organisations
endorse FerroHEALTH.
