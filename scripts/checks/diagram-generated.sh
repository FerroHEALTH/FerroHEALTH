#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# diagram-generated.sh: the committed architecture diagram is what its
# generator draws.
#
#   scripts/checks/diagram-generated.sh
#
# assets/diagrams/ferrohealth-architecture.svg is drawn by
# scripts/diagrams/ferrohealth-architecture.py, which refuses to draw a box on
# a box, a line through a box, two lines crossing or a label on anything. That
# only holds if the SVG in the tree is the one the script drew, so this check
# redraws it and fails on any difference. A hand edit to the SVG is undone by
# the next regeneration; the fix is to edit the generator.

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root" || exit 1

readonly GENERATOR=scripts/diagrams/ferrohealth-architecture.py
readonly SVG=assets/diagrams/ferrohealth-architecture.svg

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if ! python3 "$GENERATOR" "$tmp/drawn.svg"; then
  echo "diagram-generated: the generator refused to draw." >&2
  exit 1
fi

if ! diff -u "$SVG" "$tmp/drawn.svg" >"$tmp/diff"; then
  cat "$tmp/diff" >&2
  echo "diagram-generated: $SVG is not what $GENERATOR draws." >&2
  echo "  Edit the generator and run: python3 $GENERATOR $SVG" >&2
  exit 1
fi

echo "diagram-generated: $SVG is what its generator draws."
