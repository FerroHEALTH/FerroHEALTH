#!/usr/bin/env bash
# SPDX-FileCopyrightText: Ruben Talstra
# SPDX-License-Identifier: Apache-2.0
#
# svg-first.sh: a page or a document does not reach for a raster when the same
# artwork exists as SVG.
#
#   scripts/checks/svg-first.sh
#
# Vector artwork stays sharp at any size and in any theme, so SVG is the default
# everywhere in this repository. A raster is kept only where the consumer cannot
# take SVG at all, and every one of those is listed below with the consumer that
# forces it. Anything else referencing `name.png` while `name.svg` exists is a
# finding.

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root" || exit 1

# A raster reference that is correct, and the consumer that makes it correct.
# The favicon set and the touch icon: browsers that predate SVG favicons, and
# iOS, which has never supported one for the home screen.
# The social card: OpenGraph and Twitter cards are fetched by servers that
# render no SVG, so a card has to be raster.
is_mandated() {
  case "$1" in
    *favicon-16.png | *favicon-32.png | *favicon.ico | *apple-touch-icon.png) return 0 ;;
    *ferrohealth-social.png) return 0 ;;
    *) return 1 ;;
  esac
}

# A document that explains why a raster exists has to name it.
is_documentation() {
  case "$1" in
    assets/diagrams/README.md | assets/brand/README.md) return 0 ;;
    *) return 1 ;;
  esac
}

fail=0

while IFS= read -r file; do
  is_documentation "$file" && continue
  refs="$(grep -oE '[A-Za-z0-9_./-]+\.(png|jpg|jpeg)' "$file" | sort -u || true)"
  [ -n "$refs" ] || continue
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    is_mandated "$ref" && continue
    vector="${ref%.*}.svg"
    base="$(basename "$vector")"
    if git ls-files --error-unmatch "*$base" >/dev/null 2>&1; then
      echo "svg-first: $file references $ref while $base is tracked." >&2
      echo "  Use the SVG. A raster belongs only where the consumer cannot render one." >&2
      fail=1
    fi
  done <<< "$refs"
done <<< "$(git ls-files '*.html' '*.md')"

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "svg-first: every reference with a vector available uses it."
