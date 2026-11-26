#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# render-releases.sh: fill the facts a product moves into a page, in place,
# from that product's or shared library's repository through the GitHub API.
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
#   data-badge="<url>"          the message of a product's CI-written
#                               shields.io endpoint badge (13 / 13)
#   data-badge-label="<url>"    the label of the same badge, which names what
#                               was measured against which pin
#
# A badge URL is a product's own: a file on the main branch of a FerroHEALTH
# repository, or a file its site serves. It is fetched without a token.
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
readonly OWNER=FerroHEALTH
readonly PRODUCTS=(FerroFORMS FerroEHR FerroTERM FerroBRIDGE FerroPIX FerroFED FerroTASK FerroSMART)
# The shared libraries are no products, and their cards carry a release the
# same way, so the same markers fill them.
readonly LIBRARIES=(FerroAUDIT FerroUI FerroSYS)

# A repository that also releases crates by their own tags names the prefix of
# its server's tags, since its latest release may be a crate's. The server's
# release is what the page shows, without the prefix.
server_tag_prefix() {
  case "$1" in
    FerroSMART) echo ferrosmart- ;;
    *) echo "" ;;
  esac
}

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

for product in "${PRODUCTS[@]}" "${LIBRARIES[@]}"; do
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
  prefix="$(server_tag_prefix "$product")"
  if [ -n "$prefix" ]; then
    release="$(api "$repo/releases?per_page=100" "first(.[] | select((.draft or .prerelease) | not) | select(.tag_name | startswith(\"${prefix}v\"))) | [.tag_name, .published_at[0:10]] | @tsv")" && rc=0 || rc=$?
    [ "$rc" -ne 0 ] || [ -n "$release" ] || rc=44
  else
    release="$(api "$repo/releases/latest" '[.tag_name, .published_at[0:10]] | @tsv')" && rc=0 || rc=$?
  fi
  case "$rc" in
    0)
      IFS=$'\t' read -r tag date <<< "$release"
      tag="${tag#"$prefix"}"
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

# A badge's text reaches the page too, so it is held to the characters badges
# use, which leaves no markup and no entity.
is_badge_url()  { [[ "$1" =~ ^https://(raw\.githubusercontent\.com/FerroHEALTH/[A-Za-z]+/main|ferro[a-z]+\.eu)/[A-Za-z0-9._/-]+\.json$ ]]; }
is_badge_text() { [[ "$1" =~ ^[[:alnum:][:space:].,:/()@+_·-]{1,160}$ ]]; }

while IFS= read -r url; do
  is_badge_url "$url" || { echo "render-releases: refusing badge URL '$url'" >&2; exit 1; }
  asked=$((asked + 1))
  if ! badge="$(curl -fsSL --max-time 20 "$url" 2>/dev/null | jq -r '[.label, .message] | @tsv' 2>/dev/null)" || [ -z "$badge" ]; then
    echo "render-releases: badge $url is not reported; its fallback stands." >&2
    continue
  fi
  IFS=$'\t' read -r label message <<< "$badge"
  if ! is_badge_text "$label" || ! is_badge_text "$message"; then
    echo "render-releases: refusing odd badge '$label' / '$message' from $url" >&2
    exit 1
  fi
  answered=$((answered + 1))
  fill data-badge "$url" "$message"
  fill data-badge-label "$url" "$label"
  echo "render-releases: badge $label: $message"
done < <(grep -oE 'data-badge(-label)?="[^"]*"' "$FILE" | sed -E 's/^[^"]*"//; s/"$//' | sort -u)

if [ "$answered" -eq "$asked" ]; then
  echo "render-releases: every figure rendered into $FILE."
else
  echo "render-releases: $answered of $asked answers rendered into $FILE; the rest keep the committed fallback." >&2
fi
