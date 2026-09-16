#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
#
# assemble.sh: build the site the way GitHub Pages serves it, into one
# directory.
#
#   scripts/site/assemble.sh OUT
#
# The family site is one page, so this is mostly a copy. Two things are
# rendered:
#
#   * every figure a product moves, by scripts/site/render-releases.sh: the
#     latest release tag (the status table, the card badges, the image tag in
#     the quick start), the day it was published, and the day of the last push,
#     each read from that product's repository through the GitHub API. The
#     committed HTML carries real values as its fallback, so an assembly on a
#     laptop without a token still produces a page whose commands run; it is
#     just as stale as the checkout, and refresh.yml keeps the checkout fresh.
#   * sitemap.xml's lastmod, from the commit being deployed.
#
# The brand and diagram directories live outside the landing directory and are
# copied in here, because the favicons, the lockups, the social card and the
# architecture diagram are all addressed from the site root.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

readonly OUT="${1:?usage: $0 OUT}"
readonly LANDING=website/landing

rm -rf "${OUT:?}"
mkdir -p "$OUT"
cp -R "$LANDING"/. "$OUT/"

mkdir -p "$OUT/assets"
cp -R assets/brand "$OUT/assets/"
cp -R assets/diagrams "$OUT/assets/"

scripts/site/render-releases.sh "$OUT/index.html"

# The sitemap's lastmod is the date of the commit being deployed, which is the
# only date on the page a crawler acts on.
lastmod="$(git log -1 --format=%cs 2>/dev/null || date -u +%F)"
LASTMOD="$lastmod" perl -0pi -e 's{<lastmod>[^<]*</lastmod>}{<lastmod>$ENV{LASTMOD}</lastmod>}g' "$OUT/sitemap.xml"

echo "assemble: site at $OUT"
