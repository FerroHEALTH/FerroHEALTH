#!/usr/bin/env bash
# SPDX-FileCopyrightText: Ruben Talstra
# SPDX-License-Identifier: Apache-2.0
#
# internal-links.sh: every local href and src in the assembled site resolves to
# a file that was actually assembled.
#
#   scripts/checks/internal-links.sh _site
#
# It checks what a static site gets wrong silently: an asset renamed in
# assets/brand without its <link> being updated, a product mark copied under a
# different name, a fragment pointing at an id that no longer exists. External
# links are deliberately out of scope — a link checker that reaches the network
# fails on somebody else's outage, and this runs on every pull request.

set -euo pipefail

readonly SITE="${1:?usage: $0 SITE}"
[ -d "$SITE" ] || { echo "internal-links: no such directory: $SITE" >&2; exit 1; }

fail=0

while IFS= read -r page; do
  rel="${page#"$SITE"/}"
  dir="$(dirname "$page")"

  # Every href/src value on the page, one per line.
  targets="$(grep -oE '(href|src)="[^"]*"' "$page" | sed -E 's/^(href|src)="//; s/"$//')"

  while IFS= read -r target; do
    [ -n "$target" ] || continue
    case "$target" in
      http://*|https://*|mailto:*|tel:*|data:*|"#"*) continue ;;
    esac

    # Drop the query and the fragment; what is left is the path to resolve.
    path="${target%%#*}"
    path="${path%%\?*}"
    [ -n "$path" ] || continue

    case "$path" in
      /*) resolved="$SITE$path" ;;
      *)  resolved="$dir/$path" ;;
    esac

    # A directory URL is served by its index.html.
    case "$resolved" in
      */) resolved="${resolved}index.html" ;;
    esac

    if [ ! -e "$resolved" ]; then
      echo "internal-links: $rel -> $target (no $resolved)" >&2
      fail=1
    fi
  done <<< "$targets"

  # A same-page fragment has to name an id that exists on that page.
  while IFS= read -r fragment; do
    [ -n "$fragment" ] || continue
    id="${fragment#\#}"
    grep -q "id=\"$id\"" "$page" || {
      echo "internal-links: $rel -> $fragment (no element with that id)" >&2
      fail=1
    }
  done <<< "$(grep -oE '(href)="#[^"]+"' "$page" | sed -E 's/^href="//; s/"$//')"

done <<< "$(find "$SITE" -name '*.html')"

if [ "$fail" -ne 0 ]; then
  echo "internal-links: FAILED" >&2
  exit 1
fi

echo "internal-links: every local link resolves."
