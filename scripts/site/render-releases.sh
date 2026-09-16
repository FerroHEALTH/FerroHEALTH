#!/usr/bin/env bash
# SPDX-FileCopyrightText: Vernum Projecten B.V.
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
#   data-repo="<product>"       whether the repository exists: "no repository
#                               yet" while the API answers 404, and "code moved
#                               <day>" once it does, from the last push
#
# A <time> element that carries a date marker also gets its datetime attribute
# set, when that attribute follows the marker in the tag.
#
# Running it twice over the same file changes nothing the second time, which is
# what lets the same script render the assembled copy (assemble.sh) and refresh
# the committed fallbacks (.github/workflows/refresh.yml). A 404 is an answer.
# A repository the API cannot see (none yet, or private) renders as none, which
# is what a planned product's card shows; a repository with no release keeps
# its release fallback, because the image tag in the quick start has to stay a
# tag that runs. An API that gives no answer at all leaves every marker as the
# file has it: the committed values are real, so the page stays true and only
# as stale as the checkout.

set -euo pipefail

readonly FILE="${1:?usage: $0 FILE}"
readonly OWNER=rubentalstra
readonly PRODUCTS=(FerroCHART FerroEHR FerroTERM FerroBRIDGE FerroPIX FerroSMART FerroFED FerroSYS)

[ -f "$FILE" ] || { echo "render-releases: no such file: $FILE" >&2; exit 1; }

# One API call. Prints the value and returns 0. Returns 44 on a 404, which is
# an answer: the repository or the release is not there. Returns 1 when the
# API gave no answer at all, which is not one.
api() {
  local out
  if out="$(gh api "$1" --jq "$2" 2>&1)"; then
    printf '%s' "$out"
    return 0
  fi
  case "$out" in
    *"HTTP 404"*) return 44 ;;
  esac
  return 1
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

answered=0
asked=0

for product in "${PRODUCTS[@]}"; do
  repo="repos/$OWNER/$product"

  asked=$((asked + 1))
  pushed="$(api "$repo" '.pushed_at[0:10]')" && rc=0 || rc=$?
  case "$rc" in
    44)
      answered=$((answered + 1))
      fill data-repo "$product" "no repository yet"
      echo "render-releases: $product has no repository the API can see; its card says so."
      continue
      ;;
    0)
      is_date "$pushed" || { echo "render-releases: refusing odd push date '$pushed' for $product" >&2; exit 1; }
      answered=$((answered + 1))
      fill data-pushed "$product" "$pushed"
      fill data-repo "$product" "code moved $pushed"
      echo "render-releases: $product last pushed $pushed"
      ;;
    *)
      echo "render-releases: $product's repository is not reported; its fallback stands." >&2
      ;;
  esac

  asked=$((asked + 1))
  release="$(api "$repo/releases/latest" '[.tag_name, .published_at[0:10]] | @tsv')" && rc=0 || rc=$?
  case "$rc" in
    0)
      IFS=$'\t' read -r tag date <<< "$release"
      if ! is_tag "$tag" || ! is_date "$date"; then
        echo "render-releases: refusing odd release '$tag' / '$date' for $product" >&2
        exit 1
      fi
      answered=$((answered + 1))
      fill data-rel "$product" "$tag"
      fill data-rel-plain "$product" "${tag#v}"
      fill data-rel-date "$product" "$date"
      echo "render-releases: $product $tag, published $date"
      ;;
    44)
      answered=$((answered + 1))
      echo "render-releases: $product has no release yet; its release fallback stands."
      ;;
    *)
      echo "render-releases: $product's release is not reported; its fallback stands." >&2
      ;;
  esac
done

if [ "$answered" -eq "$asked" ]; then
  echo "render-releases: every figure rendered into $FILE."
else
  echo "render-releases: $answered of $asked answers rendered into $FILE; the rest keep the committed fallback." >&2
fi
