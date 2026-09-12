# CLAUDE.md

**FerroHEALTH** is the family name for four pure-Rust health-data servers, and
this repository is the family site at <https://ferrohealth.eu> plus the shared
brand. It ships no product code. The products are
[FerroCHART](https://github.com/rubentalstra/FerroCHART) (an openEHR form
builder and renderer),
[FerroEHR](https://github.com/rubentalstra/FerroEHR) (an openEHR Clinical Data
Repository), [FerroTERM](https://github.com/rubentalstra/FerroTERM) (an HL7 FHIR
terminology server), and
[FerroBRIDGE](https://github.com/rubentalstra/FerroBRIDGE) (a bridge from
openEHR to FHIR and to the OMOP Common Data Model). Ferro is *ferrum*, iron,
which Rust is an oxide of.

Write all prose (the page, the READMEs, comments, commits, PRs, issues) to
`.claude/rules/writing-style.md`. It is copied from FerroTERM and the two stay
in step.

## Repo map

- `website/landing/`: the page. `index.html`, `style.css`, `404.html`,
  `robots.txt`, `sitemap.xml`, `.well-known/security.txt`, `CNAME`, and
  `assets/products/` (a copy of each product's own mark, with provenance in the
  README there).
- `assets/brand/`: the FerroHEALTH mark, the icon and lockup variants, the
  favicon set, the social card, and `tokens.css`. `assets/brand/README.md` is
  the brand authority.
- `assets/diagrams/`: the architecture diagram as one self-contained,
  theme-adaptive SVG plus its raster. The page loads it with `<img>`, so there
  is one copy of the artwork and it can be used outside this site.
- `scripts/site/assemble.sh`: builds the site the way GitHub Pages serves it.
  `scripts/site/render-releases.sh` fills every figure a product moves, from the
  GitHub API, and is shared with the refresh workflow.
- `scripts/checks/`: `internal-links.sh` (every local link in the assembled site
  resolves), `writing-style.sh` (the mechanical tells), `svg-first.sh` (a raster
  where the vector exists), `licence-links.sh` (a licence link points at a
  product's own `LICENSE`), and `no-typed-version.sh` (no version outside a
  rendered marker).
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
  release, the release date, the last push) carries a `data-rel`,
  `data-rel-plain`, `data-rel-date` or `data-pushed` marker and is filled by
  `scripts/site/render-releases.sh` from that product's repository. The
  committed value is real, and `.github/workflows/refresh.yml` moves it through
  an auto-merged pull request when a product releases.
  `scripts/checks/no-typed-version.sh` fails the build on a version outside a
  marker, in the page and the diagram.
- **Say what is true about a product, and let its own site carry the detail.**
  A specification version, a database version, a FHIR release name, a code
  system list or a crate list moves with a product release and belongs on that
  product's site. The page names the standard and links the pin.
- **The parent owns no hue.** FerroCHART is rose, FerroEHR is rust, FerroTERM
  is teal, FerroBRIDGE is indigo. FerroHEALTH is iron and steel, and spends a
  product hue only where that product is named. The product values in
  `assets/brand/tokens.css` are copied verbatim from each product's own
  `tokens.css`.
- **A licence link points at the product's own `LICENSE`.** The BUSL-1.1
  boilerplate fills none of its parameters in, so a reader who follows it sees
  a blank Additional Use Grant. The page links each repository's `LICENSE` and
  states the terms beside the link. `scripts/checks/licence-links.sh` holds it.
- **A diagram is a file, never inline artwork.** It lives in
  `assets/diagrams/` with its palette written in as literal values and a
  `prefers-color-scheme` query inside the file, so one copy serves the page,
  a README, and a slide. Edit the file and regenerate its raster.
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
label, and an area label (`site`, `brand`, `build`). A PR declares `Closes #N`.
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
- The four product sites carry the detail this page links to:
  <https://ferrochart.eu>, <https://ferroehr.eu>, <https://ferroterm.eu>,
  <https://ferrobridge.eu>.
