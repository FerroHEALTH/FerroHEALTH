#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# down.sh: stop the FerroHEALTH family demo and delete its data.
#
#   demo/down.sh [--purge]
#
# Every service and volume of compose.yaml goes, so the next demo/up.sh seeds
# a fresh stack. The development CA, the keys and the downloads under .work/
# stay, so the browser keeps trusting the CA it was shown; --purge deletes
# them too. FERROHEALTH_DEMO_COMPOSE names the compose command, as for up.sh.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"

purge=0
case "${1:-}" in
  "") ;;
  --purge) purge=1 ;;
  *)
    echo "usage: demo/down.sh [--purge]" >&2
    exit 2
    ;;
esac

if [[ -n "${FERROHEALTH_DEMO_COMPOSE:-}" ]]; then
  read -r -a compose_cmd <<<"$FERROHEALTH_DEMO_COMPOSE"
elif command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then
  compose_cmd=(docker compose)
elif command -v docker-compose >/dev/null; then
  compose_cmd=(docker-compose)
else
  compose_cmd=(podman compose)
fi

"${compose_cmd[@]}" --profile build down -v --remove-orphans
if [[ "$purge" -eq 1 ]]; then
  rm -rf "$here/.work"
fi
echo "demo: stopped"
