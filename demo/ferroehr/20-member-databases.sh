#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# The databases of FerroEHR members B, C and D on the demo's one FerroEHR
# PostgreSQL server, run once by that image on its empty data directory. The
# image's own 10-ferroehr-init.sh has by then made member A's role and database
# from the PG_INIT_ keys; this runs it again for each name in
# DEMO_MEMBER_DATABASES, so every member gets the same setup under its own
# role. The FerroFED quickstart sets its four nodes up this way. Demo
# credentials: each role's password is its name followed by `_demo`.
set -euo pipefail

readonly IMAGE_INIT=/docker-entrypoint-initdb.d/10-ferroehr-init.sh

read -r -a names <<<"${DEMO_MEMBER_DATABASES:-}"
for name in "${names[@]}"; do
  [[ "$name" =~ ^[a-z_][a-z0-9_]{0,62}$ ]] || {
    echo "demo init: '$name' is not a lower-case PostgreSQL identifier" >&2
    exit 1
  }
  PG_INIT_USER="$name" PG_INIT_PASSWORD="${name}_demo" PG_INIT_DB="$name" "$IMAGE_INIT"
done
