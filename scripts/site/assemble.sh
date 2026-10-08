#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# assemble.sh: build the site the way GitHub Pages serves it, into one
# directory.
#
#   scripts/site/assemble.sh OUT
#
# The site is the landing page and the family book. The landing page is
# mostly a copy, and three things are rendered:
#
#   * every figure a product moves, by scripts/site/render-releases.sh: the
#     latest release tag (the status table, the card badges, the image tag in
#     the quick start), the day it was published, and the day of the last push,
#     each read from that product's repository through the GitHub API. The
#     committed HTML carries real values as its fallback, so an assembly on a
#     laptop without a token still produces a page whose commands run; it is
#     just as stale as the checkout, and refresh.yml keeps the checkout fresh.
#   * sitemap.xml's lastmod, from the commit being deployed, and one entry
#     per page of the book.
#   * the family book (website/book), built by the pinned mdbook into docs/,
#     each page then given its own hashed Content-Security-Policy by
#     scripts/site/book-csp.sh. mdBook reads its favicon from the book's theme
#     directory, so the book is built from a staged copy that adds the one in
#     assets/brand/, and the repository keeps one copy of the artwork.
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

# The family book, at /docs/. Another mdbook version renders other markup, and
# the hashed policy and the checks are only known to hold for the pinned one.
# shellcheck source=scripts/site/toolchain.sh
. scripts/site/toolchain.sh
if ! command -v mdbook >/dev/null 2>&1; then
  echo "assemble: mdbook not found; install mdbook $MDBOOK_VERSION (scripts/site/toolchain.sh)" >&2
  exit 1
fi
mdbook_seen="$(mdbook --version)"
if [ "$mdbook_seen" != "mdbook v$MDBOOK_VERSION" ]; then
  echo "assemble: found $mdbook_seen, but the book is pinned to mdbook v$MDBOOK_VERSION (scripts/site/toolchain.sh)" >&2
  exit 1
fi
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
cp -R website/book/. "$stage/"
cp assets/brand/favicon.svg "$stage/theme/favicon.svg"
cp assets/brand/favicon-32.png "$stage/theme/favicon.png"
out_abs="$(cd "$OUT" && pwd)"
if ! book_log="$(mdbook build "$stage" -d "$out_abs/docs" 2>&1)"; then
  printf '%s\n' "$book_log" >&2
  echo "assemble: mdbook failed to build website/book" >&2
  exit 1
fi
scripts/site/book-csp.sh "$OUT/docs"

# The sitemap's lastmod is the date of the commit being deployed, which is the
# only date on the page a crawler acts on.
lastmod="$(git log -1 --format=%cs 2>/dev/null || date -u +%F)"
LASTMOD="$lastmod" perl -0pi -e 's{<lastmod>[^<]*</lastmod>}{<lastmod>$ENV{LASTMOD}</lastmod>}g' "$OUT/sitemap.xml"

# One sitemap entry per book page. print.html repeats every page, toc.html is
# the sidebar's frame and 404.html is no page, so none of them is listed.
book_urls="$(cd "$OUT" && find docs -name '*.html' ! -name print.html ! -name toc.html ! -name 404.html | sort |
  while IFS= read -r page; do
    printf '  <url>\n    <loc>https://ferrohealth.eu/%s</loc>\n    <lastmod>%s</lastmod>\n  </url>\n' "$page" "$lastmod"
  done)"
BOOK_URLS="$book_urls" perl -0pi -e 's{</urlset>}{$ENV{BOOK_URLS}\n</urlset>}' "$OUT/sitemap.xml"

echo "assemble: site at $OUT"
