<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Security policy

This repository is the FerroHEALTH family site: static HTML, CSS and SVG,
published to <https://ferrohealth.eu/> by GitHub Actions. It carries no server,
no database, no user data and no dependency at runtime.

## Report a vulnerability in a product

A vulnerability in FerroEHR, FerroTERM or FerroBRIDGE belongs in that product's
own advisory queue, which is where its maintainers and its release process are:

- FerroEHR: <https://github.com/FerroHEALTH/FerroEHR/security/advisories/new>
- FerroTERM: <https://github.com/FerroHEALTH/FerroTERM/security/advisories/new>
- FerroBRIDGE: <https://github.com/FerroHEALTH/FerroBRIDGE/security/advisories/new>

Please do not open a public issue for one.

## Report a vulnerability in the site

Open a private advisory:
<https://github.com/FerroHEALTH/FerroHEALTH/security/advisories/new>.

In scope, and worth reporting:

- content injection into the published page, including through the release
  figures `scripts/site/assemble.sh` renders from the GitHub API
- a supply-chain problem in the workflow: an unpinned action, an over-broad
  permission, an artifact that can be written by something other than the build
- a weakness in the page's Content Security Policy, or an asset that escapes it

Out of scope: the absence of a security header GitHub Pages cannot set, and
reports produced by a scanner without a reproduction.

## What to expect

An acknowledgement within three working days, and a fix or an explanation
before the advisory is published. The machine-readable contact is
[`website/landing/.well-known/security.txt`](website/landing/.well-known/security.txt),
served at <https://ferrohealth.eu/.well-known/security.txt>; its `Expires` date
must be refreshed before it passes, because RFC 9116 says a stale file is
invalid.
