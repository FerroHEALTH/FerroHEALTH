---
paths: [".github/**", "scripts/**"]
---

# CI/CD and supply-chain discipline

No spec governs this: our own design, and the same posture the four product
repositories hold, scaled to a static site. Grounded in the OWASP GitHub Actions
Security Cheat Sheet, SLSA v1.0, and OpenSSF Scorecard.

## Workflow security (every workflow, no exceptions)

- **Every `uses:` is pinned to a full commit SHA** with a trailing `# vX.Y.Z`
  comment. A tag or branch ref is a finding.
- **`permissions: {}` at workflow level**, with the minimum granted per job.
  The deploy job is the only one that holds `pages: write` and `id-token: write`.
- **`persist-credentials: false`** on every `actions/checkout`.
- **No `${{ }}` interpolation inside `run:`.** Pass context through `env:`, which
  is what keeps a template injection out of the shell.
- **Only main deploys.** `build` runs on every event; `deploy` is gated on
  `github.event_name != 'pull_request' && github.ref == 'refs/heads/main'`, so
  neither a pull request nor a dispatched build on a branch publishes.

## Lanes

`ci.yml` runs on every push and pull request:

- `workflows`: `actionlint` and `zizmor --min-severity=low` over
  `.github/workflows/`.
- `shell`: `shellcheck --severity=style` over every tracked shell script.
- `prose`: `scripts/checks/writing-style.sh`, the mechanical half of
  `writing-style.md`.
- `versions`: `scripts/checks/no-typed-version.sh`, no version a product moves
  outside a rendered marker.
- `diagram`: `scripts/checks/diagram-generated.sh`, the committed architecture
  SVG is what `scripts/diagrams/ferrohealth-architecture.py` draws.
- `book revisions`: `scripts/checks/book-revisions.sh`, every page of the
  family book is dated and `revisions.md` agrees.

`pages.yml` installs the documentation toolchain pinned in
`scripts/site/toolchain.sh` (through the SHA-pinned `taiki-e/install-action`),
lints the book with `mdbook-lint`, assembles the site with the book, runs
`scripts/checks/internal-links.sh`, `scripts/checks/csp.sh` and
`lychee --offline --include-fragments` over the result, and deploys from
`main`. External links are not fetched in CI: a remote outage says nothing
about the change.

`refresh.yml` runs every six hours. It renders the committed fallbacks in
`index.html` in place with `scripts/site/render-releases.sh` and, when the file
changed, commits on `chore/refresh-release-fallbacks`, opens or updates one pull
request, dispatches `ci.yml` and `pages.yml` onto that branch (a pull request
the workflow token opens starts no run of its own), and enables auto-merge. The
squash merge is signed by GitHub, which satisfies the ruleset. Nothing in it
needs a secret beyond the workflow token.

## The published site

- The custom domain is configured in the repository's Pages settings.
  `website/landing/CNAME` travels with the artifact so the domain survives a
  switch back to branch-based publishing.
- The six-hourly schedule exists because the page carries each product's
  latest release and last push. A release cut in any of the four products
  reaches the status table without a commit here, and `refresh.yml` then moves
  the committed fallbacks to match.
- **Never add AI or Claude attribution** to a commit, a PR, or release text.

## Never

- Never unpin a `uses:` to a tag or a branch, widen a job's permissions without
  cause, or interpolate context into `run:`.
- Never weaken a gate to go green. Fix the cause.
