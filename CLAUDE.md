# CLAUDE.md

**FerroHEALTH** is the family name for five pure-Rust health-data servers, and
this repository is the family site at <https://ferrohealth.eu> plus the shared
brand. It ships no product code. The products are
[FerroCHART](https://github.com/FerroHEALTH/FerroCHART) (an openEHR form
builder and renderer),
[FerroEHR](https://github.com/FerroHEALTH/FerroEHR) (an openEHR Clinical Data
Repository), [FerroTERM](https://github.com/FerroHEALTH/FerroTERM) (an HL7 FHIR
terminology server),
[FerroBRIDGE](https://github.com/FerroHEALTH/FerroBRIDGE) (a bridge from
openEHR to FHIR and to the OMOP Common Data Model), and
[FerroFED](https://github.com/FerroHEALTH/FerroFED) (an openEHR federation
gateway). Three more are planned, each with a domain and a repository that
holds its licence and its brand and no release yet:
[FerroPIX](https://github.com/FerroHEALTH/FerroPIX) (patient identity,
`ferropix.eu`), [FerroSMART](https://github.com/FerroHEALTH/FerroSMART) (the
SMART on openEHR server, `ferrosmart.eu`) and
[FerroSYS](https://github.com/FerroHEALTH/FerroSYS) (the control plane,
`ferrosys.eu`). Ferro is *ferrum*, iron, which Rust is an oxide
of.

Write all prose (the page, the READMEs, comments, commits, PRs, issues) to
`.claude/rules/writing-style.md`. It is copied from FerroTERM and the two stay
in step.

## Repo map

- `website/landing/`: the page. `index.html`, `style.css`, `404.html`,
  `robots.txt`, `sitemap.xml`, `.well-known/security.txt`, `CNAME`, and
  `assets/products/` (a copy of each product's own mark, with provenance in the
  README there).
- `assets/brand/`: the FerroHEALTH mark, the icon and lockup variants, the
  favicon set, the social cards, the GitHub avatar, and `tokens.css`.
  `assets/brand/README.md` is the brand authority.
- `assets/diagrams/`: the architecture diagram as one self-contained,
  theme-adaptive SVG plus its raster. The page loads it with `<img>`, so there
  is one copy of the artwork and it can be used outside this site. The SVG is
  drawn by `scripts/diagrams/ferrohealth-architecture.py`.
- `scripts/site/assemble.sh`: builds the site the way GitHub Pages serves it.
  `scripts/site/render-releases.sh` fills every figure a product moves, from the
  GitHub API, and is shared with the refresh workflow.
- `scripts/diagrams/`: the diagram generator. Boxes and edges are declared;
  the script asserts no overlap, no crossing and no label on anything before it
  writes. `scripts/brand/hue-distance.py` scores a product hue against the
  palette, which is how a new hue is chosen.
- `scripts/checks/`: `internal-links.sh` (every local link in the assembled site
  resolves), `writing-style.sh` (the mechanical tells), `svg-first.sh` (a raster
  where the vector exists), `licence-links.sh` (a licence link points at a
  product's own `LICENSE`), `no-typed-version.sh` (no version outside a
  rendered marker), and `diagram-generated.sh` (the committed SVG is what the
  generator draws).
- `TRADEMARKS.md`: the brand terms (the artwork and the product names).
- `.github/workflows/`: `ci.yml` (workflows, shell, prose, versions),
  `pages.yml` (assemble, check, deploy from main every six hours and on push),
  and `refresh.yml` (re-render the committed fallbacks, open one pull request,
  auto-merge).

## Build and check

```bash
scripts/site/assemble.sh _site
scripts/checks/internal-links.sh _site
scripts/checks/writing-style.sh
scripts/checks/svg-first.sh
scripts/checks/licence-links.sh
scripts/checks/no-typed-version.sh
scripts/checks/diagram-generated.sh
shellcheck --severity=style .claude/hooks/*.sh scripts/**/*.sh
python3 -m http.server -d _site 8000
```

Look at the page before calling it right: light and dark, wide and narrow.

## IMPORTANT hard rules

- **Nothing loads from another origin.** The page's CSP is `default-src 'self'`,
  carried in a `<meta http-equiv>` because GitHub Pages sets no response
  headers. No web font, no analytics, no CDN, no hotlinked image, no inline
  `<style>` and no `style=` attribute.
- **Never type a version or a status.** A fact a product moves (its latest
  release, the release date, the last push, whether it has a repository at all)
  carries a `data-rel`, `data-rel-plain`, `data-rel-date`, `data-pushed` or
  `data-repo` marker and is filled by `scripts/site/render-releases.sh` from
  that product's repository. The committed value is real, and
  `.github/workflows/refresh.yml` moves it through an auto-merged pull request
  when a product releases. `scripts/checks/no-typed-version.sh` fails the build
  on a version outside a marker, in the page and the diagram.
- **A planned product is a dashed card, and says only what it is for.** It
  names the product, the job and the intended standards, links its repository
  and its `LICENSE`, shows the domain as text until it serves a page, and
  carries one `data-repo` badge that renders "code moved <day>" from the
  repository's last push ("no repository yet" from a 404). Its mark and hue are
  copied from its repository like any other product's. It has no row in the
  status table. When it publishes a first release, the refresh pull request
  renders the tag; that is the signal to move the card into the released grid,
  link its site, and add it to the status table.
- **Say what is true about a product, and let its own site carry the detail.**
  A specification version, a database version, a FHIR release name, a code
  system list or a crate list moves with a product release and belongs on that
  product's site. The page names the standard and links the pin.
- **The parent owns no hue.** FerroCHART is rose, FerroEHR is rust, FerroTERM
  is teal, FerroBRIDGE is indigo; FerroPIX, FerroSMART, FerroFED and FerroSYS
  are plum, bronze, azure and olive. FerroHEALTH is iron and steel, and spends a product
  hue only where that product is named. Every product's values in
  `assets/brand/tokens.css` are copied verbatim from its own `tokens.css`; a
  new hue is chosen with `scripts/brand/hue-distance.py` before it goes there.
  The mark stays at four strokes: they are the data path (FerroCHART, FerroEHR,
  FerroTERM, FerroBRIDGE), and FerroPIX, FerroSMART, FerroFED and FerroSYS
  frame it, released or not.
- **The brand artwork is all rights reserved.** The SVG, PNG and ICO files in
  `assets/brand/` and `assets/diagrams/` are under `TRADEMARKS.md`, and every
  SVG there carries `LicenseRef-FerroHEALTH-Brand`, a new one included. The
  site, the scripts, the docs and `tokens.css` stay Apache-2.0.
- **A licence link points at the product's own `LICENSE`.** The BUSL-1.1
  boilerplate fills none of its parameters in, so a reader who follows it sees
  a blank Additional Use Grant. The page links each repository's `LICENSE` and
  states the terms beside the link. `scripts/checks/licence-links.sh` holds it.
- **A diagram is a file, never inline artwork.** It lives in
  `assets/diagrams/` with its palette written in as literal values and a
  `prefers-color-scheme` query inside the file, so one copy serves the page,
  a README, and a slide. The architecture diagram is drawn by
  `scripts/diagrams/ferrohealth-architecture.py`: edit the declarations there,
  regenerate the SVG and its raster, and never edit the SVG by hand.
  `scripts/checks/diagram-generated.sh` fails the build when they differ.
- **A product's mark is copied, and never edited here.** When a product changes
  its mark, refresh the copy from its source. When the copy would have to differ
  from upstream, fix it upstream instead and file the issue there.
- **Every `uses:` in a workflow is pinned to a full commit SHA** with a trailing
  version comment, `permissions: {}` at workflow level, and no `${{ }}` inside
  `run:`.
- **Comments follow `.claude/rules/comments.md`:** a comment says why, the
  budgets are 8 lines, and pending work is `TODO(#N)` with its issue.
- **Prose follows `writing-style.md`:** no em dashes, no "not X but Y", no
  decorative triads, no filler buzzwords.
- **Branches use conventional types** (`feat/`, `fix/`, `chore/`, `docs/`,
  `refactor/`, `perf/`, `test/`, `ci/`).
- **NEVER add AI or Claude attribution** to commits, PRs, issues, or code: no
  `Co-Authored-By`, no "Generated with", ever. The `no_attribution_guard.sh`
  PreToolUse hook blocks the command before it runs.
- **Never weaken a check to go green.** Fix the cause.

## Issue workflow (the loop)

The tracker is GitHub Issues and the open list is the worklist
(`.claude/rules/issue-workflow.md`). One type label per issue, one priority
label, and an area label (`site`, `brand`, `build`). A PR declares `Closes #N` and keeps the
template's ticked licensing checkbox (`contribution-licence-guard`).
Work that belongs in a product repository is filed there, with the evidence from
here. The SessionStart hook prints the open list.

## Working discipline (`.claude/`)

Path-scoped rules load when files in their scope are read; the rest apply
always.

- `.claude/rules/writing-style.md`: no AI tells in any prose. The top priority.
- `.claude/rules/site.md`: the page's hard rules, the brand rules that reach it,
  and what belongs on a product's own site instead.
- `.claude/rules/comments.md`: comment budgets for HTML, CSS, SVG, and shell.
- `.claude/rules/ci-cd.md`: workflow security, the CI lanes, and how the site
  publishes.
- `.claude/rules/issue-workflow.md`: the tracker loop, labels, and branches.

## References

- @assets/brand/README.md: the brand authority (the mark, the palette, the
  usage rules, the raster pipeline).
- @README.md: what the repository is, how to build it, and how it deploys.
- `website/landing/assets/products/README.md`: where each product mark came
  from.
- The five product sites carry the detail this page links to:
  <https://ferrochart.eu>, <https://ferroehr.eu>, <https://ferroterm.eu>,
  <https://ferrobridge.eu>, <https://ferrofed.eu>.
