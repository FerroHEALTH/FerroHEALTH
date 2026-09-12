#!/usr/bin/env bash
# SPDX-FileCopyrightText: Ruben Talstra
# SPDX-License-Identifier: Apache-2.0
#
# render-releases.sh: fill the facts a product moves into a page, in place,
# from that product's repository through the GitHub API.
#
#   scripts/site/render-releases.sh FILE
#
# A marker names the product, and the whole text content of the element that
# carries it is replaced:
#
#   data-rel="<product>"        the latest release tag as published (v1.2.3)
#   data-rel-plain="<product>"  the same tag without its leading v, for an
#                               image reference
#   data-rel-date="<product>"   the day that release was published, ISO 8601
#   data-pushed="<product>"     the day of the last push to the repository
#
# A <time> element that carries a date marker also gets its datetime attribute
# set, when that attribute follows the marker in the tag.
#
# Running it twice over the same file changes nothing the second time, which is
# what lets the same script render the assembled copy (assemble.sh) and refresh
# the committed fallbacks (.github/workflows/refresh.yml). A repository that
# answers 404 for its latest release has none yet, and its markers keep what
# the file says. An API that is not reachable does the same: the committed
# values are real, so the page stays true and only as stale as the checkout.

set -euo pipefail

readonly FILE="${1:?usage: $0 FILE}"
readonly OWNER=rubentalstra
readonly PRODUCTS=(FerroCHART FerroEHR FerroTERM FerroBRIDGE)

[ -f "$FILE" ] || { echo "render-releases: no such file: $FILE" >&2; exit 1; }

# One API call, or nothing when the API is not reachable. A 404 is a repository
# with no release and is not an error here.
api() {
  gh api "$1" --jq "$2" 2>/dev/null || true
}

# A value reaches the page as text, so anything that is not a tag or a date is
# refused before it gets there. A tag is [A-Za-z0-9.+-] by the time it is a git
# ref; a date is the first ten characters of an RFC 3339 timestamp.
is_tag()  { [[ "$1" =~ ^v?[0-9A-Za-z.+-]+$ ]]; }
is_date() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; }

# Replace the text content of every element carrying MARKER="PRODUCT" with
# VALUE, and the datetime attribute of a <time> that carries it.
fill() {
  local marker="$1" product="$2" value="$3"
  MARKER="$marker" PRODUCT="$product" VALUE="$value" perl -0pi -e '
    my ($m, $p, $v) = ($ENV{MARKER}, quotemeta $ENV{PRODUCT}, $ENV{VALUE});
    s{(<[^<>]*\b$m="$p"[^<>]*>)[^<]*}{$1$v}g;
    s{(<time\b[^<>]*\b$m="$p"[^<>]*\bdatetime=")[^"]*}{$1$v}g;
  ' "$FILE"
}

rendered=0
expected=0

for product in "${PRODUCTS[@]}"; do
  repo="repos/$OWNER/$product"
  release="$(api "$repo/releases/latest" '[.tag_name, .published_at[0:10]] | @tsv')"
  pushed="$(api "$repo" '.pushed_at[0:10]')"

  tag=""; date=""
  if [ -n "$release" ]; then
    IFS=$'\t' read -r tag date <<< "$release"
  fi

  expected=$((expected + 3))
  if [ -n "$tag" ] && is_tag "$tag" && is_date "$date"; then
    fill data-rel "$product" "$tag"
    fill data-rel-plain "$product" "${tag#v}"
    fill data-rel-date "$product" "$date"
    rendered=$((rendered + 2))
    echo "render-releases: $product $tag, published $date"
  elif [ -n "$tag" ]; then
    echo "render-releases: refusing odd release '$tag' / '$date' for $product" >&2
    exit 1
  else
    echo "render-releases: $product has no release the API reports; its fallback stands." >&2
  fi

  if [ -n "$pushed" ] && is_date "$pushed"; then
    fill data-pushed "$product" "$pushed"
    rendered=$((rendered + 1))
    echo "render-releases: $product last pushed $pushed"
  elif [ -n "$pushed" ]; then
    echo "render-releases: refusing odd push date '$pushed' for $product" >&2
    exit 1
  else
    echo "render-releases: $product's push date is not reported; its fallback stands." >&2
  fi
done

if [ "$rendered" -eq "$expected" ]; then
  echo "render-releases: every figure rendered into $FILE."
else
  echo "render-releases: $rendered of $expected figures rendered into $FILE; the rest keep the committed fallback." >&2
fi
