#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# up.sh: start the FerroHEALTH family demo of compose.yaml, seed it, and print
# every URL and the login. README.md is the walkthrough; demo/down.sh stops it.
#
#   demo/up.sh
#
# It makes a development CA and the TLS keys under .work/tls, the services'
# secrets under .work/secrets, fetches the public-domain ICD-10-CM release,
# the FerroEHR sandbox dataset and FerroBRIDGE's synthetic fixtures (each
# pinned by SHA-256 or commit), starts the stack, and seeds it: the patients
# of seed/ across the hospitals in FerroPIX, their EHRs at the four FerroEHR
# members, the sandbox dataset at member A, a Condition through FerroBRIDGE,
# and one federated query, which gives FerroFED's endpoint health its first
# state. FERROHEALTH_DEMO_COMPOSE names the compose command; unset, it is
# `docker compose`, `docker-compose` or `podman compose`, the first found.
# Needs curl, jq, openssl, git and nc. Nothing is built. DEMO CREDENTIALS ONLY.

set -euo pipefail
# A command that fails outside a check still names its line.
trap 'echo "demo: FAIL at up.sh line $LINENO" >&2' ERR

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"

readonly WORK="$here/.work"
readonly TLS="$WORK/tls"
readonly KC=https://keycloak.localhost:8443/realms/ferrohealth-demo
readonly KC_SERVICES=https://keycloak.localhost:8443/realms/ferrohealth-demo-services
readonly PIX=https://localhost:8070/fhir
readonly FED=http://127.0.0.1:8080
readonly BRIDGE=http://127.0.0.1:8090/fhir
readonly CDR_USER=ferroehr:ferroehr

readonly PATIENT_SYSTEM=urn:oid:2.999.1.1
readonly BSN_SYSTEM=urn:oid:2.16.840.1.113883.2.4.6.3

# The CMS fiscal year 2026 ICD-10-CM release (public domain), FerroTERM's index.
readonly ICD10CM=(
  "https://www.cms.gov/files/zip/2026-code-descriptions-tabular-order.zip 55a9124a27ca78a4a5c41e1101eda064ec2e08d105ff9e78d1fbd1a83298ef11"
  "https://www.cms.gov/files/zip/2026-code-tables-tabular-and-index.zip abfc45a54e4edc215cbaa2f0d18b30112db2bf9141857c9f8902390a495e6696"
)
# FHIR packages FerroTERM serves beside the index: HL7 Terminology (CC0) and
# the HL7 v2-to-FHIR guide's ConceptMaps.
readonly FHIR_PACKAGES=(
  "https://packages2.fhir.org/web/hl7.terminology.r4-7.5.0.tgz 1da3004587602c3f5120061abc2309fef1f96668a477a9964354fa9af6fa6e60"
  "https://packages2.fhir.org/web/hl7.fhir.uv.v2mappings-1.0.0.tgz 49004948e7589ccc663b3df89f831b3cbf4c2dd1ef67c859633dd50cc81581a0"
)
# FerroBRIDGE's HL7 v2 value maps, the package FerroPIX's HL7 v2 face
# translates through beside the guide's, from FerroBRIDGE v0.0.27.
readonly HL7V2_VALUES_BASE=https://raw.githubusercontent.com/FerroHEALTH/FerroBRIDGE/3b1354628f0c1fcba8a66404a31d48427b71100f/terminology/hl7v2-values
readonly HL7V2_VALUES=(
  "ConceptMap-table-address-type-to-hl70190.json d28b3ff53aa63821b301b5683d946480673b1ac1e0421615e7c979c2ad5bda68"
  "ConceptMap-table-address-use-to-hl70190.json 46a80f233cccb42f4bf671c612f70049e234ab46414eb31d56d3e32b08cf7aff"
  "ConceptMap-table-administrative-gender-to-hl70001.json ba0afd6497dffc23e2a2819654ccb6451efb480e970a2e713f23315f67c78d63"
  "ConceptMap-table-contact-point-system-to-hl70202.json 97035f7e5ba61a15ee47e568b4b74b7650d111cf18d8b9d33f1563c77ba4912c"
  "ConceptMap-table-hl70202-equipment-to-contact-point-system.json 66f97c511a5006e633a872b75c095ab783405b3990d107d6e1835c27e323abf2"
  "ConceptMap-table-hl70202-to-contact-point-use.json 6a033e040b94475c8984109c3e79d030f46e4376e0ef34dd6e868fba9e34db67"
  "ConceptMap-table-name-use-to-hl70200.json 85ce27a015366a0c42973c68c0cccf567f1822df54d030ac25fdbb5ab5e92177"
  "fhir-package.json 7aa6a9cab30cb23903f1eacd43dc1da8b7df0a50d965c28c6c39cf20f132679a"
)
# FerroEHR v5.7.0, the release the members run: its sandbox seed and the
# corpus files the seed reads.
readonly FERROEHR_REPO=https://github.com/FerroHEALTH/FerroEHR.git
readonly FERROEHR_COMMIT=7d85f0a1d2b86ca5bf2d43025090e6a102d99f74
readonly FERROEHR_PATHS=(
  /scripts/sandbox/ /corpus/archetypes/adl2/ /corpus/fixtures/adl2/ /corpus/fixtures/composition/
  /corpus/templates/ckm/ /corpus/templates/dt_coded_text_binding_sct.opt
  /deploy/definitions/professional/
)
# The professional PERSON and ROLE every member's party mapping writes with.
readonly FERROEHR_DEFINITIONS=(
  openEHR-DEMOGRAPHIC-PERSON.healthcare_professional.v1.0.0.adls
  openEHR-DEMOGRAPHIC-ROLE.healthcare_professional.v1.0.0.adls
)
# The family lane's synthetic templates and composition, from FerroBRIDGE's
# testkit, pinned as e2e/family/run.sh pins them.
readonly FIXTURE_BASE=https://raw.githubusercontent.com/FerroHEALTH/FerroBRIDGE/191b51b05714d4e658b1d3674aea54963aaa2ca8/tools/ferrobridge-testkit/fixtures
readonly FIXTURES=(
  "opt/diagnose.opt d088aece7904c888e4d70620ca7e30d8b1ffa9bf0371cb7680544a990d45c86c"
  "opt/minimal_evaluation.opt d04d6b4a2e75726edd096a2ed545486b4d818f71ff4630ce4695c8165dd927e0"
  "composition/minimal_evaluation.json e644c18f2ef65f2f3f811015bf80112492a7cbac83c3650f34e7e2c55db85ad1"
)

if [[ -n "${FERROHEALTH_DEMO_COMPOSE:-}" ]]; then
  read -r -a compose_cmd <<<"$FERROHEALTH_DEMO_COMPOSE"
elif command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then
  compose_cmd=(docker compose)
elif command -v docker-compose >/dev/null; then
  compose_cmd=(docker-compose)
elif command -v podman >/dev/null; then
  compose_cmd=(podman compose)
else
  echo "demo: no compose command found; set FERROHEALTH_DEMO_COMPOSE" >&2
  exit 1
fi

compose() {
  "${compose_cmd[@]}" "$@"
}

step() {
  echo "demo: $*"
}

fail() {
  echo "demo: FAIL $*" >&2
  if [[ -s "$WORK/answer" ]]; then
    echo "demo: the answer was: $(head -c 2000 "$WORK/answer")" >&2
  fi
  echo "demo: the logs: ${compose_cmd[*]} -f demo/compose.yaml logs <service>" >&2
  exit 1
}

# call METHOD URL [CURL_ARGS...]: one request; prints the status and keeps the
# answer in $WORK/answer. The demo CA is trusted, and keycloak.localhost is
# loopback here too.
call() {
  local method="$1" url="$2" status
  shift 2
  : >"$WORK/answer"
  status="$(curl -sS -X "$method" "$url" -o "$WORK/answer" -w '%{http_code}' \
    --cacert "$TLS/ca.crt" --resolve keycloak.localhost:8443:127.0.0.1 "$@" 2>/dev/null)" ||
    status=000
  printf '%s' "${status:-000}"
}

# token CLIENT: a client credentials token from the demo's Keycloak; every demo
# client's secret is `demo-` and its id, and a `demo-` client's is its id.
token() {
  local status secret="demo-$1"
  [[ "$1" == demo-* ]] && secret="$1"
  status="$(call POST "$KC/protocol/openid-connect/token" -d grant_type=client_credentials \
    -d "client_id=$1" -d "client_secret=$secret")"
  [[ "$status" == 200 ]] || fail "Keycloak token for $1 answered $status"
  jq -er .access_token "$WORK/answer"
}

sha256() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | cut -c1-64
  else
    shasum -a 256 "$1" | cut -c1-64
  fi
}

# fetch URL FILE SHA256: download once, then hold the file to its digest.
fetch() {
  [[ -s "$2" && "$(sha256 "$2")" == "$3" ]] && return 0
  curl --proto '=https' --proto-redir '=https' -fsSL "$1" -o "$2" || fail "could not fetch $1"
  [[ "$(sha256 "$2")" == "$3" ]] || fail "$1 does not have its pinned SHA-256"
}

# index MEMBER: the member's number, a is 1, which numbers its domains and port.
index() {
  case "$1" in
    a) echo 1 ;;
    b) echo 2 ;;
    c) echo 3 ;;
    d) echo 4 ;;
    *) fail "no member $1" ;;
  esac
}

# leaf NAME SAN: a server certificate of the demo CA.
leaf() {
  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -pkeyopt ec_param_enc:named_curve -out "$TLS/$1.key" 2>/dev/null
  openssl req -new -key "$TLS/$1.key" -subj "/CN=$1" -out "$TLS/$1.csr" 2>/dev/null
  printf 'basicConstraints=critical,CA:FALSE\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=serverAuth\nsubjectAltName=%s\n' \
    "$2" >"$TLS/$1.ext"
  openssl x509 -req -in "$TLS/$1.csr" -CA "$TLS/ca.crt" -CAkey "$TLS/ca.key" \
    -set_serial "0x$(openssl rand -hex 16)" -days 397 -sha256 -extfile "$TLS/$1.ext" -out "$TLS/$1.crt" 2>/dev/null
  rm -f "$TLS/$1.csr" "$TLS/$1.ext"
}

for tool in curl jq openssl git nc; do
  command -v "$tool" >/dev/null || fail "$tool is not installed"
done

if [[ -n "$(compose ps -q 2>/dev/null)" ]]; then
  echo "demo: the demo is already running; demo/down.sh stops it" >&2
  exit 1
fi

mkdir -p "$TLS" "$WORK/secrets" "$WORK/ferroterm-releases" "$WORK/ferroterm-packages/ferrobridge-hl7v2-values" \
  "$WORK/fixtures/opt" "$WORK/fixtures/composition" "$WORK/definitions"
: >"$WORK/answer"

if [[ ! -s "$TLS/ca.crt" ]]; then
  step "making the development CA under .work/tls (demo only; its key never leaves .work)"
  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -pkeyopt ec_param_enc:named_curve -out "$TLS/ca.key" 2>/dev/null
  printf '[req]\ndistinguished_name=dn\n[dn]\n[ca]\nbasicConstraints=critical,CA:TRUE,pathlen:0\nkeyUsage=critical,keyCertSign,cRLSign\nsubjectKeyIdentifier=hash\n' \
    >"$TLS/ca.cnf"
  openssl req -x509 -new -key "$TLS/ca.key" -sha256 -days 825 -config "$TLS/ca.cnf" -extensions ca \
    -subj "/CN=FerroHEALTH demo CA (not for production)" -out "$TLS/ca.crt" 2>/dev/null
fi
# The servers that speak TLS inside the network: Keycloak (the issuer),
# FerroPIX and FerroTERM.
[[ -s "$TLS/keycloak.crt" ]] || leaf keycloak "DNS:keycloak.localhost,DNS:localhost,IP:127.0.0.1"
[[ -s "$TLS/ferropix.crt" ]] || leaf ferropix "DNS:ferropix,DNS:localhost,IP:127.0.0.1"
[[ -s "$TLS/ferroterm.crt" ]] || leaf ferroterm "DNS:ferroterm,DNS:localhost,IP:127.0.0.1"

step "writing the development secrets under .work/secrets"
# The containers run as users other than yours and must read these files, so
# they are world-readable, inside a directory git ignores. Demo values only.
[[ -s "$WORK/secrets/ferrofed-signing-key.pem" ]] ||
  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-384 -pkeyopt ec_param_enc:named_curve \
    -out "$WORK/secrets/ferrofed-signing-key.pem" 2>/dev/null
printf 'demo-ferrofed-gateway' >"$WORK/secrets/ferrofed-gateway-secret"
printf 'demo-ferrofed-pix' >"$WORK/secrets/ferrofed-pix-secret"
openssl rand -base64 32 >"$WORK/secrets/ferropix-data-key"
openssl rand -hex 16 | tr -d '\n' >"$WORK/secrets/ferropix-postgres-password"
pix_password="$(openssl rand -hex 16)"
printf '%s' "$pix_password" >"$WORK/secrets/ferropix-db-password"
printf 'postgresql://ferropix:%s@ferropix-postgres:5432/ferropix' "$pix_password" \
  >"$WORK/secrets/ferropix-db-url"
chmod 644 "$WORK"/secrets/* "$TLS"/*

step "fetching ICD-10-CM, three FHIR packages, the FerroEHR sandbox dataset and the FerroBRIDGE fixtures"
releases=()
for entry in "${ICD10CM[@]}"; do
  url="${entry%% *}"
  fetch "$url" "$WORK/ferroterm-releases/${url##*/}" "${entry##* }"
  releases+=(--icd10cm "/releases/${url##*/}")
done
# FerroTERM reads a package's package/ directory, so each tarball is unpacked
# into a directory of its own.
for entry in "${FHIR_PACKAGES[@]}"; do
  url="${entry%% *}"
  name="${url##*/}"
  name="${name%-*}"
  fetch "$url" "$WORK/ferroterm-releases/${url##*/}" "${entry##* }"
  if [[ ! -d "$WORK/ferroterm-packages/$name/package" ]]; then
    mkdir -p "$WORK/ferroterm-packages/$name"
    tar -xzf "$WORK/ferroterm-releases/${url##*/}" -C "$WORK/ferroterm-packages/$name" package
  fi
done
for entry in "${HL7V2_VALUES[@]}"; do
  path="${entry%% *}"
  fetch "$HL7V2_VALUES_BASE/$path" "$WORK/ferroterm-packages/ferrobridge-hl7v2-values/$path" "${entry##* }"
done
for entry in "${FIXTURES[@]}"; do
  path="${entry%% *}"
  fetch "$FIXTURE_BASE/$path" "$WORK/fixtures/$path" "${entry##* }"
done
ferroehr_src="$WORK/ferroehr-$FERROEHR_COMMIT"
if [[ "$(git -C "$ferroehr_src" rev-parse HEAD 2>/dev/null)" != "$FERROEHR_COMMIT" ||
  ! -d "$ferroehr_src/deploy/definitions/professional" ]]; then
  rm -rf "$ferroehr_src"
  git init -q "$ferroehr_src"
  git -C "$ferroehr_src" remote add origin "$FERROEHR_REPO"
  git -C "$ferroehr_src" sparse-checkout set --no-cone "${FERROEHR_PATHS[@]}"
  git -C "$ferroehr_src" fetch -q --depth 1 --filter=blob:none origin "$FERROEHR_COMMIT" ||
    fail "could not fetch FerroEHR $FERROEHR_COMMIT"
  git -C "$ferroehr_src" checkout -q FETCH_HEAD
fi
# What each member's definitions one-shot stores before the member serves.
for definition in "${FERROEHR_DEFINITIONS[@]}"; do
  cp "$ferroehr_src/deploy/definitions/professional/$definition" "$WORK/definitions/"
done
cp "$WORK/fixtures/opt/diagnose.opt" "$WORK/definitions/"
rm -f "$WORK/definitions/minimal_evaluation.opt"

step "pulling the images"
compose --profile build pull --quiet

step "building FerroTERM's ICD-10-CM index"
compose --profile build run --rm ferroterm-build "${releases[@]}" >/dev/null ||
  fail "ferroterm-build did not build the index"

step "starting Keycloak, FerroTERM, FerroPIX, the four FerroEHR members and FerroFED"
compose up -d --wait --wait-timeout 900 keycloak ferroterm ferropix \
  ferroehr-a ferroehr-b ferroehr-c ferroehr-d ferrofed ||
  fail "a service did not turn healthy"

# Every member binds each person to a demographic PERSON, so the two SCIM
# clients of ferrohealth-demo-services provision the Basic user and the three
# Keycloak users at every member: each User carries its login, the Basic user
# name or the Keycloak user id the import fixes, as its binding key.
scim_token() {
  local status
  status="$(call POST "$KC_SERVICES/protocol/openid-connect/token" -d grant_type=client_credentials \
    -d "client_id=$1" -d "client_secret=demo-$1" -d scope=ferroehr/scim)"
  [[ "$status" == 200 ]] || fail "Keycloak token for $1 answered $status"
  jq -er .access_token "$WORK/answer"
}

# provision MEMBER TOKEN USERNAME LOGIN FORMATTED_NAME: one SCIM User; an
# existing one (409) is kept.
provision() {
  local status
  status="$(call POST "http://127.0.0.1:808$(index "$1")/scim/v2/Users" -H "Authorization: Bearer $2" \
    -H 'Content-Type: application/scim+json' --data-binary "$(jq -n --arg u "$3" --arg l "$4" --arg n "$5" '{
      schemas: ["urn:ietf:params:scim:schemas:core:2.0:User",
        "urn:ietf:params:scim:schemas:extension:ferrohealth:2.0:User"],
      userName: $u, name: {formatted: $n},
      "urn:ietf:params:scim:schemas:extension:ferrohealth:2.0:User": {loginIdentifier: $l}}')")"
  [[ "$status" =~ ^(201|409)$ ]] || fail "member $1 SCIM POST /Users for $3 answered $status"
}

step "provisioning the Basic user and the demo users as persons at every member (SCIM)"
basic_scim="$(scim_token ferroehr-scim)"
keycloak_scim="$(scim_token ferroehr-scim-keycloak)"
for n in a b c d; do
  provision "$n" "$basic_scim" ferroehr ferroehr "FerroEHR seed"
  provision "$n" "$keycloak_scim" keycloak-demo de000000-0000-4000-8000-000000000101 "Dana Demo"
  provision "$n" "$keycloak_scim" keycloak-steward de000000-0000-4000-8000-000000000102 "Sam Demo"
  provision "$n" "$keycloak_scim" keycloak-auditor de000000-0000-4000-8000-000000000103 "Alex Demo"
done

# FerroPIX: each hospital feeds its patients (ITI-104), FerroPIX mints each
# member's pseudonym on that member's first ask (ITI-83), the member stores the
# EHR under it, and the hospital feeds the ehr_id FerroFED resolves to.
# Indexed by member number (a is 1), as macOS still ships bash 3.2.
hospital_token=() member_token=()
for n in a b c d; do
  hospital_token[$(index "$n")]="$(token "hospital-$n")"
  member_token[$(index "$n")]="$(token "ferroehr-$n")"
done

# feed HOSPITAL SYSTEM VALUE PATIENT_JSON: one conditional update as the
# hospital, the source of SYSTEM.
feed() {
  local identifier status
  identifier="$(jq -rn --arg v "$2|$3" '$v | @uri')"
  status="$(call PUT "$PIX/Patient?identifier=$identifier" \
    -H "Authorization: Bearer ${hospital_token[$(index "$1")]}" -H 'Content-Type: application/fhir+json' \
    -H 'Accept: application/fhir+json' --data-binary "$4")"
  [[ "$status" == 200 || "$status" == 201 ]] || fail "FerroPIX feed $2|$3 answered $status"
}

# pseudonym MEMBER SYSTEM VALUE: the identifier FerroPIX holds for the patient
# in the member's clinical domain, minted on the first ask.
pseudonym() {
  local status ns
  ns="urn:oid:2.999.7.$(index "$1")"
  status="$(call GET "$PIX/Patient/\$ihe-pix" -G --data-urlencode "sourceIdentifier=$2|$3" \
    --data-urlencode "targetSystem=$ns" -H "Authorization: Bearer ${member_token[$(index "$1")]}" \
    -H 'Accept: application/fhir+json')"
  [[ "$status" == 200 ]] || fail "FerroPIX ITI-83 for $2|$3 at member $1 answered $status"
  NS="$ns" jq -er '[.parameter[] | select(.name == "targetIdentifier") | .valueIdentifier
    | select(.system == env.NS) | .value] | if length == 1 then .[0] else error("not one") end' \
    "$WORK/answer" || fail "FerroPIX answered no single pseudonym for $2|$3 at member $1"
}

# ehr_status PSEUDONYM NAMESPACE: the EHR_STATUS FerroEHR's own seed writes.
ehr_status() {
  jq -n --arg id "$1" --arg ns "$2" '{
    _type: "EHR_STATUS", archetype_node_id: "openEHR-EHR-EHR_STATUS.generic.v1",
    archetype_details: {_type: "ARCHETYPED", rm_version: "1.2.0",
      archetype_id: {_type: "ARCHETYPE_ID", value: "openEHR-EHR-EHR_STATUS.generic.v1"}},
    name: {_type: "DV_TEXT", value: "EHR Status"},
    subject: {_type: "PARTY_SELF", external_ref: {_type: "PARTY_REF", namespace: $ns,
      type: "PERSON", id: {_type: "HIER_OBJECT_ID", value: $id}}},
    is_queryable: true, is_modifiable: true}'
}

member_url() {
  printf 'http://127.0.0.1:808%d/ferroehr/rest/openehr/v1' "$(index "$1")"
}

# FerroBRIDGE's Condition template is already stored, by the definitions
# one-shots, since member A checks its system client's writes at start.
step "uploading the synthetic evaluation template to every member through FerroFED's fan-out"
seed_token="$(token demo-seed)"
status="$(call POST "$FED/v1/definition/template/adl1.4" -H "Authorization: Bearer $seed_token" \
  -H 'openEHR-federation-endpoint: *' -H 'Content-Type: application/xml' \
  --data-binary "@$WORK/fixtures/opt/minimal_evaluation.opt")"
[[ "$status" =~ ^(200|201|204|207)$ ]] || fail "FerroFED template fan-out answered $status"
[[ "$status" != 207 ]] || jq -e '[.meta.federation.endpoints[]? | select(.status != "active")] | length == 0' \
  "$WORK/answer" >/dev/null || fail "FerroFED's template fan-out did not reach every member"

step "seeding the patients across the hospitals, FerroPIX and the members"
eva_a=""
number=0
while IFS=$'\t' read -r patient given family gender birth bsn members; do
  [[ -z "$patient" || "$patient" == \#* ]] && continue
  number=$((number + 1))
  [[ "$members" == - ]] && members=a
  for n in $members; do
    upper="$(printf '%s' "$n" | tr "[:lower:]" "[:upper:]")"
    index="$(index "$n")"
    mrn="$upper-$((1000 + number))"
    person="$(jq -n --arg given "$given" --arg family "$family" --arg gender "$gender" \
      --arg birth "$birth" '{resourceType: "Patient", name: [{family: $family, given: [$given]}],
      gender: $gender, birthDate: $birth}')"
    feed "$n" "urn:oid:2.999.3.$index" "$mrn" "$(jq --arg mrn "$mrn" --arg s "urn:oid:2.999.3.$index" \
      --arg p "$patient" --arg ps "$PATIENT_SYSTEM" --arg bsn "$bsn" --arg bs "$BSN_SYSTEM" \
      '.identifier = [{system: $s, value: $mrn}, {system: $ps, value: $p}, {system: $bs, value: $bsn}]' \
      <<<"$person")"
    [[ "$patient" == ffd-test-0004 ]] && continue
    alias_id="$(pseudonym "$n" "urn:oid:2.999.3.$index" "$mrn")"
    [[ "$patient-$n" == ffd-test-0001-a ]] && eva_a="$alias_id"
    ehr_id="$(printf '%s%s%s%s%s%s%s%s' "$n" "$n" "$n" "$n" "$n" "$n" "$n" "$n")-$n$n$n$n-4$n$n$n-8$n$n$n-$(printf '%012d' "$number")"
    status="$(call PUT "$(member_url "$n")/ehr/$ehr_id" -u "$CDR_USER" -H 'Content-Type: application/json' \
      -H 'Prefer: return=minimal' --data-binary "$(ehr_status "$alias_id" "urn:oid:2.999.7.$index")")"
    [[ "$status" =~ ^(201|204)$ ]] || fail "member $n PUT /ehr/$ehr_id answered $status"
    status="$(call POST "$(member_url "$n")/ehr/$ehr_id/composition" -u "$CDR_USER" \
      -H 'Content-Type: application/json' -H 'Prefer: return=minimal' \
      --data-binary "@$WORK/fixtures/composition/minimal_evaluation.json")"
    [[ "$status" =~ ^(201|204)$ ]] || fail "member $n POST composition answered $status"
    feed "$n" "urn:oid:2.999.2.$index" "$ehr_id" "$(jq --arg e "$ehr_id" --arg s "urn:oid:2.999.2.$index" \
      --arg p "$patient" --arg ps "$PATIENT_SYSTEM" \
      '.identifier = [{system: $s, value: $e}, {system: $ps, value: $p}]' <<<"$person")"
  done
done <seed/patients.tsv

# Each seed file is checked on its own, as CI runs shellcheck without -x.
# shellcheck source=seed/ferropix.sh disable=SC1091
. seed/ferropix.sh
# shellcheck source=seed/ferroehr.sh disable=SC1091
. seed/ferroehr.sh

step "loading the FerroEHR sandbox dataset into member A (about a minute)"
identities="$WORK/sandbox-identities"
{
  echo "provider ihe"
  echo "pseudonym_namespace urn:oid:2.999.7.1"
  jq -r '.ehrs[].subject, .marker.subject' "$ferroehr_src/scripts/sandbox/seed/manifest.json" |
    while read -r subject; do
      feed a urn:oid:2.999.3.1 "$subject" "$(jq -n --arg s urn:oid:2.999.3.1 --arg v "$subject" \
        '{resourceType: "Patient", identifier: [{system: $s, value: $v}],
        name: [{family: "Sandbox", given: [$v]}]}')"
      echo "subject $subject $(pseudonym a urn:oid:2.999.3.1 "$subject")"
    done
} >"$identities"
# The demo's FerroTERM serves no LOINC, which the seed's archetype-library
# pin takes under SANDBOX_TERMINOLOGY=without-loinc.
SANDBOX_BASE=http://127.0.0.1:8081 SANDBOX_IDENTITIES="$identities" SANDBOX_TERMINOLOGY=without-loinc \
  bash "$ferroehr_src/scripts/sandbox/reseed.sh" >"$WORK/sandbox.log" 2>&1 ||
  fail "the sandbox seed stopped; its log is demo/.work/sandbox.log"

step "starting FerroBRIDGE and writing a Condition through its facade"
compose up -d --wait --wait-timeout 300 ferrobridge || fail "FerroBRIDGE did not turn healthy"
condition="$(jq -n --arg id "$eva_a" '{resourceType: "Condition",
  meta: {profile: ["http://example.org/fhir/StructureDefinition/family-e2e-condition"]},
  subject: {identifier: {system: "urn:oid:2.999.7.1", value: $id}},
  code: {text: "Seasonal allergic rhinitis"},
  verificationStatus: {coding: [{system: "http://example.org/fhir/CodeSystem/family-e2e-finding", code: "alpha"}]},
  onsetDateTime: "2026-04-02T09:00:00+02:00"}')"
status="$(call POST "$BRIDGE/Condition" -H "Authorization: Bearer $(token demo-seed-fhir)" \
  -H 'Content-Type: application/fhir+json' -H 'Accept: application/fhir+json' --data-binary "$condition")"
[[ "$status" == 201 ]] || fail "FerroBRIDGE POST /fhir/Condition answered $status"
condition_id="$(jq -r .id "$WORK/answer")"

# The FerroFED seed sets rows, the federated answer's size.
rows=0
# shellcheck source=seed/ferrofed.sh disable=SC1091
. seed/ferrofed.sh

step "starting the consoles"
compose up -d --wait --wait-timeout 300 ferroehr-viewer ferroehr-viewer-b ferroehr-viewer-c ferroehr-viewer-d \
  ferropix-console ferrofed-console \
  ferroterm-console ferrobridge-console || fail "a console did not turn healthy"

cat <<EOF

The FerroHEALTH demo is running. Sign in to every console as demo / demo
(steward / steward and auditor / auditor show the narrower roles).

  FerroEHR viewers    http://localhost:3001   member A, the academic hospital (sandbox dataset)
                      http://localhost:3006   member B, the GP practice
                      http://localhost:3007   member C, public health and laboratory
                      http://localhost:3008   member D, the outpatient clinic
  FerroPIX console    http://localhost:3002   patients, review queue, merges
  FerroFED console    http://localhost:3003   members, endpoint health, queries
  FerroTERM console   http://localhost:3004   ICD-10-CM, HL7 Terminology, v2-to-FHIR maps
  FerroBRIDGE console http://localhost:3005   mappings, \$tofhir, \$toopenehr

  Keycloak            https://keycloak.localhost:8443/admin   admin / admin
  FerroFED gateway    http://localhost:8080/v1/query/aql
  FerroEHR members    http://localhost:8081 to 8084   Basic ferroehr / ferroehr
  FerroPIX            https://localhost:8070/fhir
  FerroTERM           https://localhost:8085/r4
  FerroBRIDGE facade  http://localhost:8090/fhir   Condition/$condition_id

Keycloak, FerroPIX and FerroTERM serve certificates of the demo CA in
demo/.work/tls/ca.crt; your browser asks once before it trusts
keycloak.localhost. The federated query just returned $rows rows for Eva Visser
from four members. README.md walks through the rest. Stop it with demo/down.sh.
Demo credentials only, never for production.
EOF
