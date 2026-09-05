#!/usr/bin/env bash
# SPDX-FileCopyrightText: Ruben Talstra
# SPDX-License-Identifier: Apache-2.0
#
# writing-style.sh: the mechanical half of .claude/rules/writing-style.md.
#
#   scripts/checks/writing-style.sh [FILE...]
#
# With no argument it checks every tracked text file. With arguments it checks
# those files, which is what the PostToolUse hook passes after an edit.
#
# It catches what a regular expression can catch: em dashes, the buzzword list,
# and AI attribution. The tells that need judgement (the "not X but Y" setup,
# decorative triads, TED-talk tone) are review-enforced, so a clean run here is
# not a pass on the rule.

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root" || exit 1

# The rule file names every banned word, and this script quotes them too, so
# both match themselves.
is_exempt() {
  case "$1" in
    .claude/rules/writing-style.md | scripts/checks/writing-style.sh) return 0 ;;
    *) return 1 ;;
  esac
}

# The rules and the guard hook quote the attribution they forbid. They are
# still checked for em dashes and buzzwords, only not for this one pattern.
states_the_attribution_rule() {
  case "$1" in
    CLAUDE.md | .claude/*) return 0 ;;
    *) return 1 ;;
  esac
}

readonly BUZZWORDS='delve|robust|elevate|testament|landscape|leverage|tapestry|underscore|foster|realm|seamless|seamlessly|empower|unlock|cutting-edge|state-of-the-art|game-changing|holistic|synergy|streamline|harness|pivotal'
readonly ATTRIBUTION='co-authored-by:[[:space:]]*.*(claude|anthropic|\[bot\])|generated[[:space:]]+with[[:space:]]+.*claude|generated[[:space:]]+by[[:space:]]+.*claude|assisted-by:[[:space:]]*.*claude'

files=()
if [ "$#" -gt 0 ]; then
  files=("$@")
else
  while IFS= read -r tracked; do
    files+=("$tracked")
  done < <(git ls-files '*.md' '*.html' '*.css' '*.svg' '*.txt' '*.sh' '*.yml' '*.json')
fi

fail=0
checked=0

# One rule over one file. Prints every hit and returns non-zero on a hit, with
# no pipeline in between, because a `while` after a pipe runs in a subshell and
# would lose the result.
check() {
  local file="$1" pattern="$2" advice="$3" hits
  hits="$(grep -nEi -- "$pattern" "$file" || true)"
  [ -n "$hits" ] || return 0
  while IFS= read -r hit; do
    echo "writing-style: $file:$hit" >&2
    echo "  $advice" >&2
  done <<< "$hits"
  return 1
}

for file in "${files[@]}"; do
  [ -f "$file" ] || continue
  is_exempt "$file" && continue
  checked=$((checked + 1))

  check "$file" '—' 'em dash: use a comma, a period, parentheses, or a colon.' || fail=1
  check "$file" "(^|[^[:alnum:]-])($BUZZWORDS)([^[:alnum:]-]|$)" 'buzzword: use the plain word.' || fail=1
  states_the_attribution_rule "$file" && continue
  check "$file" "$ATTRIBUTION" 'AI attribution: text describes only the change.' || fail=1
done

if [ "$fail" -ne 0 ]; then
  echo "writing-style: FAILED (.claude/rules/writing-style.md)" >&2
  exit 1
fi

echo "writing-style: no mechanical tells in $checked files."
