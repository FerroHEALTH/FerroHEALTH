---
paths: [".github/**", "scripts/**"]
---

# CI/CD and supply-chain discipline

No spec governs this: our own design, and the same posture the three product
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
- **A pull request never deploys.** `build` runs on every event; `deploy` is
  gated on `github.event_name != 'pull_request'`.

## Lanes

`ci.yml` runs on every push and pull request:

- `workflows`: `actionlint` and `zizmor --min-severity=low` over
  `.github/workflows/`.
- `shell`: `shellcheck --severity=style` over every tracked shell script.
- `prose`: `scripts/checks/writing-style.sh`, the mechanical half of
  `writing-style.md`.

`pages.yml` assembles the site, runs `scripts/checks/internal-links.sh` over the
result, and deploys from `main`.

## The published site

- The custom domain is configured in the repository's Pages settings.
  `website/landing/CNAME` travels with the artifact so the domain survives a
  switch back to branch-based publishing.
- The daily schedule exists because the page carries each product's latest
  release. A release cut in FerroEHR, FerroTERM, or FerroBRIDGE reaches the
  status table without a commit here.
- **Never add AI or Claude attribution** to a commit, a PR, or release text.

## Never

- Never unpin a `uses:` to a tag or a branch, widen a job's permissions without
  cause, or interpolate context into `run:`.
- Never weaken a gate to go green. Fix the cause.
