#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# FerroPIX's database role in the family lane, run once by the official
# PostgreSQL image on its empty data directory (compose.yaml mounts this file
# under /docker-entrypoint-initdb.d/). FerroPIX refuses a superuser at boot,
# so it connects as `ferropix`, a login role that may create its schema in
# the `ferropix` database and owns nothing else, as FerroPIX's quickstart
# sets it up. psql reads the password from the file secret itself. No
# specification governs this: our own design.
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'SQL'
\set password `cat /run/secrets/ferropix-db-password`
CREATE ROLE ferropix LOGIN PASSWORD :'password';
GRANT CREATE ON DATABASE ferropix TO ferropix;
SQL
