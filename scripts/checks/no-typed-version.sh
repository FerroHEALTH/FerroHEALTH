#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# no-typed-version.sh: nothing on the page or in the diagram carries a version
# a product moves.
#
#   scripts/checks/no-typed-version.sh [FILE...]
#
# The page went stale once because a release tag, a specification version, a
# database version and a set of FHIR release names were typed into it and the
# products moved on. A fact that moves with a release is either rendered at
# assembly time by scripts/site/render-releases.sh, inside an element that
# carries a data-rel, data-rel-plain, data-rel-date, data-pushed or data-repo
# marker, or it lives on the product's own site. This check fails on a version-like token
# anywhere else in the page, the 404 page and the diagram. HTML comments are
# not checked, and neither is a licence's own version (BUSL-1.1, Apache 2.0).

set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root" || exit 1

files=()
if [ "$#" -gt 0 ]; then
  files=("$@")
else
  while IFS= read -r tracked; do
    files+=("$tracked")
  done < <(git ls-files 'website/landing/*.html' 'assets/diagrams/*.svg')
fi

# What a typed version looks like: a release tag or a three-part version, a
# FHIR release name, and a standard or a runtime followed by a number.
readonly TAG='\bv[0-9]+(\.[0-9]+)*\b|\b[0-9]+\.[0-9]+\.[0-9]+\b'
readonly FHIR_RELEASE='\bR4B?\b|\bR5\b|\bR6\b'
readonly STANDARD_PIN='\b(PostgreSQL|Postgres|Rust|AQL|ITS-REST|CDM|FHIRconnect|OMOCL|FHIR|openEHR|SNOMED CT|LOINC|Release)[[:space:]]+v?[0-9]+(\.[0-9]+)*\b'

fail=0
checked=0

for file in "${files[@]}"; do
  [ -f "$file" ] || continue
  case "$file" in
    website/landing/*.html | assets/diagrams/*.svg) ;;
    *) continue ;;
  esac
  checked=$((checked + 1))

  # Blank out what is allowed to carry a version, keeping the line count so a
  # finding points at the real line: comments, rendered markers, and the
  # licences' own names. In an SVG only the text a reader sees is checked,
  # because path data is full of `v11`-shaped commands.
  hits="$(SVG="$([[ "$file" == *.svg ]] && echo 1 || echo 0)" perl -0pe '
    s{<!--.*?-->}{ my $c = $&; $c =~ s/[^\n]//g; $c }gse;
    s{(<[^<>]*\bdata-(rel|rel-plain|rel-date|pushed|repo)="[^"]*"[^<>]*>)[^<]*}{$1}g;
    s{<[^<>]*>}{<>}g if $ENV{SVG};
    s{Business Source License 1\.1|BUSL-1\.1|Apache(?: License|-)? 2\.0|version 1\.1}{}g;
  ' "$file" | grep -nE -- "$TAG|$FHIR_RELEASE|$STANDARD_PIN" || true)"
  [ -n "$hits" ] || continue
  while IFS= read -r hit; do
    echo "no-typed-version: $file:$hit" >&2
    echo "  A version a product moves is rendered by scripts/site/render-releases.sh or lives on the product's own site." >&2
    fail=1
  done <<< "$hits"
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "no-typed-version: $checked files carry no typed version."
