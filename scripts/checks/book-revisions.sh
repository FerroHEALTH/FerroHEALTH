#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# book-revisions.sh: every page of the family book is dated, and the
# revisions page agrees with every date.
#
#   scripts/checks/book-revisions.sh
#
# A product release names the revision of a family page it relies on by the
# page and its date, so the date has to be on the page and in the record. For
# each page of website/book/src (SUMMARY.md aside) this checks:
#
#   * line 3 is "Revised YYYY-MM-DD.", a real date and not in the future;
#   * revisions.md has a row for the page, and its newest row carries that
#     same date;
#   * every row of revisions.md names a page that exists, with a real date,
#     and the rows run newest first.
#
# It cannot tell whether a change to a page deserved a new revision; review
# does that, and the revisions page says when one is due.

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root" || exit 1

readonly SRC=website/book/src
readonly RECORD="$SRC/revisions.md"
today="$(date -u +%F)"

[ -f "$RECORD" ] || { echo "book-revisions: $RECORD is missing" >&2; exit 1; }

valid_date() {
  [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || return 1
  # BSD date on macOS, GNU date on the runner.
  date -u -j -f %F "$1" +%F >/dev/null 2>&1 || date -u -d "$1" +%F >/dev/null 2>&1
}

# The record's rows as "date<TAB>page", newest first as written.
rows="$(perl -ne 'print "$1\t$2\n" if /^\|\s*(\d{4}-\d{2}-\d{2})\s*\|\s*\[[^\]]*\]\(([^)#]+)\)/' "$RECORD")"

fail=0
pages=0

while IFS= read -r file; do
  rel="${file#"$SRC"/}"
  [ "$rel" = SUMMARY.md ] && continue
  pages=$((pages + 1))

  line="$(sed -n 3p "$file")"
  if [[ ! "$line" =~ ^Revised\ ([0-9]{4}-[0-9]{2}-[0-9]{2})\.$ ]]; then
    echo "book-revisions: $rel: line 3 is not \"Revised YYYY-MM-DD.\"" >&2
    fail=1
    continue
  fi
  dated="${BASH_REMATCH[1]}"
  if ! valid_date "$dated"; then
    echo "book-revisions: $rel: $dated is not a date" >&2
    fail=1
  elif [[ "$dated" > "$today" ]]; then
    echo "book-revisions: $rel: revised $dated, which is after today ($today)" >&2
    fail=1
  fi

  newest="$(printf '%s\n' "$rows" | awk -F '\t' -v p="$rel" '$2 == p { print $1; exit }')"
  if [ -z "$newest" ]; then
    echo "book-revisions: $rel has no row in revisions.md" >&2
    fail=1
  elif [ "$newest" != "$dated" ]; then
    echo "book-revisions: $rel says revised $dated, but its newest row in revisions.md is $newest" >&2
    fail=1
  fi
done < <(find "$SRC" -name '*.md' | sort)

previous=9999-99-99
while IFS=$'\t' read -r dated rel; do
  [ -n "$rel" ] || continue
  if [[ "$dated" > "$previous" ]]; then
    echo "book-revisions: revisions.md lists $dated below $previous; newest goes first" >&2
    fail=1
  fi
  previous="$dated"
  [ -f "$SRC/$rel" ] || { echo "book-revisions: revisions.md names $rel, which is not a page" >&2; fail=1; }
  valid_date "$dated" || { echo "book-revisions: revisions.md row for $rel: $dated is not a date" >&2; fail=1; }
done <<< "$rows"

if [ "$fail" -ne 0 ]; then
  echo "book-revisions: FAILED" >&2
  exit 1
fi

echo "book-revisions: $pages pages are dated, and revisions.md agrees with every date."
