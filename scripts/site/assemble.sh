#!/usr/bin/env bash
# SPDX-FileCopyrightText: Ruben Talstra
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
#   * the release column of the status table, and the image tag in the quick
#     start, from each product's latest release through the GitHub API. The
#     committed HTML carries a real release as its fallback, so an assembly on a
#     laptop without a token still produces a page whose commands run; it is
#     just as stale as the checkout.
#   * sitemap.xml's lastmod, from the commit being deployed.
#
# The brand directory lives outside the landing directory and is copied in
# here, because the favicons, the lockups and the social card are all addressed
# from the site root.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

readonly OUT="${1:?usage: $0 OUT}"
readonly LANDING=website/landing
readonly PRODUCTS=(FerroEHR FerroTERM FerroBRIDGE)

rm -rf "${OUT:?}"
mkdir -p "$OUT"
cp -R "$LANDING"/. "$OUT/"

mkdir -p "$OUT/assets"
cp -R assets/brand "$OUT/assets/"

# The latest release tag of one product, or nothing when the API is not
# reachable. A repository with no release answers 404, which is not an error
# here: the page keeps its committed fallback.
latest_tag() {
  gh api "repos/rubentalstra/$1/releases/latest" --jq '.tag_name' 2>/dev/null || true
}

# Fill one product's release into the page:
#
#   data-rel="<product>"        the status table cell, the tag as published (v1.2.3)
#   data-rel-plain="<product>"  the container tag in the quick start, no leading v
#
# Each marker's whole text content is replaced, so running this twice over the
# same file is idempotent. A tag is [A-Za-z0-9.+-] by the time it is a git ref,
# and the pattern below rejects anything else, which keeps an API response out
# of the page as markup.
fill_release() {
  local product="$1" tag="$2" file="$3"
  [[ "$tag" =~ ^v?[0-9A-Za-z.+-]+$ ]] || { echo "assemble: refusing odd tag '$tag' for $product" >&2; return 1; }
  local plain="${tag#v}"
  PRODUCT="$product" TAG="$tag" PLAIN="$plain" perl -0pi -e '
    my ($p, $t, $b) = (quotemeta $ENV{PRODUCT}, $ENV{TAG}, $ENV{PLAIN});
    s{(<[^<>]*\bdata-rel="$p"[^<>]*>)[^<]*}{$1$t}g;
    s{(<[^<>]*\bdata-rel-plain="$p"[^<>]*>)[^<]*}{$1$b}g;
  ' "$file"
}

filled=0
for product in "${PRODUCTS[@]}"; do
  tag="$(latest_tag "$product")"
  if [ -n "$tag" ] && fill_release "$product" "$tag" "$OUT/index.html"; then
    filled=$((filled + 1))
  fi
done

if [ "$filled" -eq "${#PRODUCTS[@]}" ]; then
  echo "assemble: release figures rendered for all ${#PRODUCTS[@]} products."
else
  echo "assemble: $filled of ${#PRODUCTS[@]} release figures rendered; the rest keep the committed fallback." >&2
fi

# The sitemap's lastmod is the date of the commit being deployed, which is the
# only date on the page a crawler acts on.
lastmod="$(git log -1 --format=%cs 2>/dev/null || date -u +%F)"
LASTMOD="$lastmod" perl -0pi -e 's{<lastmod>[^<]*</lastmod>}{<lastmod>$ENV{LASTMOD}</lastmod>}g' "$OUT/sitemap.xml"

echo "assemble: site at $OUT"
