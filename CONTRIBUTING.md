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
scripts/site/assemble.sh _site
scripts/checks/internal-links.sh _site
scripts/checks/writing-style.sh
scripts/checks/svg-first.sh
scripts/checks/licence-links.sh
scripts/checks/no-typed-version.sh
scripts/checks/diagram-generated.sh
python3 -m http.server -d _site 8000
```

Look at the page before calling it right: light and dark, wide and narrow.

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
