#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
# .claude/hooks/site_checks.sh
#
# Claude Code PostToolUse hook (matcher: Write|Edit).
#
# For an edited shell script: run shellcheck when it is available (never
# installs it, skips silently when absent).
#
# For the page or the diagram: run the typed-version check
# (scripts/checks/no-typed-version.sh).
#
# For any edited text file: run the mechanical half of the writing-style rule
# (scripts/checks/writing-style.sh). All three CAN block (exit 2) so the finding
# comes back as a correction while the file is still in hand.
#
# The site itself is not assembled here. Assembly copies a tree and calls the
# GitHub API, which is a per-phase step the agent runs explicitly.

set -uo pipefail

payload="$(cat)" || true

if command -v jq >/dev/null 2>&1; then
  file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)" || true
else
  file_path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

[ -n "${file_path:-}" ] || exit 0
[ -f "$file_path" ] || exit 0

repo_root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# The rules govern this repository's files. An edit somewhere else on the disk
# (a memory file, a sibling checkout) is out of scope.
case "$(cd "$(dirname "$file_path")" && pwd)/" in
"$repo_root"/*) ;;
*) exit 0 ;;
esac

case "$file_path" in
*.sh)
  if command -v shellcheck >/dev/null 2>&1; then
    findings="$(shellcheck --severity=style "$file_path" 2>&1)" || {
      printf '%s\n' "$findings" >&2
      exit 2
    }
  fi
  ;;
esac

case "$file_path" in
*/website/landing/*.html | */assets/diagrams/*.svg)
  guard="$repo_root/scripts/checks/no-typed-version.sh"
  if [ -x "$guard" ]; then
    findings="$("$guard" "${file_path#"$repo_root"/}" 2>&1)" || {
      printf '%s\n' "$findings" >&2
      exit 2
    }
  fi
  ;;
esac

case "$file_path" in
*.md | *.html | *.css | *.svg | *.txt | *.sh | *.yml | *.json)
  guard="$repo_root/scripts/checks/writing-style.sh"
  [ -x "$guard" ] || exit 0
  findings="$("$guard" "$file_path" 2>&1)" || {
    printf '%s\n' "$findings" >&2
    exit 2
  }
  ;;
esac

exit 0
