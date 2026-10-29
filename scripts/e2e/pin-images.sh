#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# pin-images.sh: move every product image of the family end-to-end lane and
# the family demo to that product's latest release, by tag and by the digest
# of its image index.
#
#   scripts/e2e/pin-images.sh [--check]
#
# For each image it reads the product's latest GitHub release (gh api), asks
# GHCR's registry API anonymously for the digest of that tag, and rewrites the
# reference in e2e/family/compose.yaml and demo/compose.yaml in place. An
# image whose release tag has no published image yet keeps its pin and is
# reported, so a release still building moves on the next run. --check
# rewrites nothing and exits 1 when a pin is behind. The Refresh workflow runs
# it beside render-releases.sh. No specification governs it: our own design.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

readonly FILES=(e2e/family/compose.yaml demo/compose.yaml)
# image name, then the repository whose release it ships with.
readonly IMAGES=(
  "ferroehr FerroEHR"
  "ferroehr-postgres FerroEHR"
  "ferroterm FerroTERM"
  "ferrobridge FerroBRIDGE"
  "ferrofed FerroFED"
  "ferropix FerroPIX"
  "ferroehr-viewer FerroEHR"
  "ferroterm-console FerroTERM"
  "ferrobridge-console FerroBRIDGE"
  "ferrofed-console FerroFED"
  "ferropix-console FerroPIX"
)
readonly ACCEPT='application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json'

check=0
case "${1:-}" in
  "") ;;
  --check) check=1 ;;
  *)
    echo "usage: scripts/e2e/pin-images.sh [--check]" >&2
    exit 2
    ;;
esac

command -v gh >/dev/null || {
  echo "pin-images: gh is required" >&2
  exit 1
}

# digest NAME TAG: the digest of the image index GHCR serves for the tag, or
# nothing when the tag is not published.
digest() {
  local token
  token="$(curl -fs "https://ghcr.io/token?scope=repository:ferrohealth/$1:pull" | jq -r .token)" ||
    return 0
  curl -sS -I -H "Authorization: Bearer $token" -H "Accept: $ACCEPT" \
    "https://ghcr.io/v2/ferrohealth/$1/manifests/$2" |
    tr -d '\r' | awk 'tolower($1) == "docker-content-digest:" { print $2 }'
}

behind=0
for entry in "${IMAGES[@]}"; do
  read -r name repo <<<"$entry"
  tag="$(gh api "repos/FerroHEALTH/$repo/releases/latest" --jq .tag_name 2>/dev/null)" || {
    echo "pin-images: $repo has no release; ghcr.io/ferrohealth/$name keeps its pin"
    continue
  }
  version="${tag#v}"
  sha="$(digest "$name" "$version")"
  if [[ ! "$sha" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    echo "pin-images: ghcr.io/ferrohealth/$name:$version is not published yet; the pin stays"
    continue
  fi
  want="ghcr.io/ferrohealth/$name:$version@$sha"
  for file in "${FILES[@]}"; do
    [[ -f "$file" ]] || continue
    grep -qE "ghcr\.io/ferrohealth/$name:[^@[:space:]]+@sha256:" "$file" || continue
    grep -qF "$want" "$file" && continue
    behind=1
    echo "pin-images: $file moves ghcr.io/ferrohealth/$name to $version"
    [[ "$check" -eq 1 ]] && continue
    WANT="$want" NAME="$name" perl -pi -e '
      s{ghcr\.io/ferrohealth/\Q$ENV{NAME}\E:[^\@\s]+\@sha256:[0-9a-f]{64}}{$ENV{WANT}}g;
    ' "$file"
  done
done

if [[ "$check" -eq 1 && "$behind" -eq 1 ]]; then
  echo "pin-images: a pin is behind its product's latest release" >&2
  exit 1
fi
