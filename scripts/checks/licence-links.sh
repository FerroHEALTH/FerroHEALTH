#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# licence-links.sh: a licence link points at the licensed product's own
# LICENSE.
#
#   scripts/checks/licence-links.sh
#
# The Business Source License 1.1 is a template. A generic copy of it carries an
# empty Additional Use Grant and no Change Date, so a reader who follows one
# cannot tell what is free and what needs a commercial licence. The terms that
# apply live in each product repository's LICENSE, which fills those parameters
# in, and that is the only licence link this repository publishes.

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root" || exit 1

readonly PRODUCTS=(FerroCHART FerroEHR FerroTERM FerroBRIDGE FerroPIX FerroSMART FerroFED FerroSYS FerroTASK)
# The landing page and the family book's licensing page each name every
# product, so each links every product's own LICENSE.
readonly PAGES=(website/landing/index.html website/book/src/licensing.md)

# A generic BUSL-1.1 copy, wherever it is hosted. This script and the rules that
# state the rule quote the pattern, so they check themselves against everything
# else and not against this one.
readonly BOILERPLATE='mariadb\.com/bsl11|spdx\.org/licenses/BUSL|opensource\.org/licenses/BUSL|choosealicense\.com/licenses/busl'

quotes_the_rule() {
  case "$1" in
    scripts/checks/licence-links.sh | CLAUDE.md | .claude/*) return 0 ;;
    *) return 1 ;;
  esac
}

fail=0

while IFS= read -r file; do
  [ -f "$file" ] || continue
  quotes_the_rule "$file" && continue
  hits="$(grep -nEi -- "$BOILERPLATE" "$file" || true)"
  [ -n "$hits" ] || continue
  while IFS= read -r hit; do
    echo "licence-links: $file:$hit" >&2
    echo "  Link that product's own LICENSE; the boilerplate states no terms." >&2
    fail=1
  done <<< "$hits"
done <<< "$(git ls-files '*.md' '*.html' '*.css' '*.svg' '*.txt' '*.yml' '*.json')"

for page in "${PAGES[@]}"; do
  for product in "${PRODUCTS[@]}"; do
    url="https://github.com/FerroHEALTH/$product/blob/main/LICENSE"
    if ! grep -qF -- "$url" "$page"; then
      echo "licence-links: $page does not link $url." >&2
      echo "  Every product named on the page carries a link to its own LICENSE." >&2
      fail=1
    fi
  done
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "licence-links: every licence link points at a product's own LICENSE."
