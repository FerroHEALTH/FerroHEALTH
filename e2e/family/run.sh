#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# run.sh: the family end-to-end lane. It starts the published images of
# compose.yaml, drives one synthetic patient through every product, asserts
# each answer, and stops the stack. No specification governs a cross-product
# test: our own design.
#
#   e2e/family/run.sh [--keep]
#
# --keep leaves the stack running after the last step. FAMILY_E2E_COMPOSE
# names the compose command, `docker compose` by default.
#
# Each step prints what it asks of which product. A failure prints one line,
# "family-e2e: FAIL <product> <call>: <what was wrong>", the answer it got,
# and the logs of the stack, and exits 1. Needs curl, jq, openssl and a
# compose implementation; every image is pulled, none is built.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$here"

readonly WORK="$here/.work"
readonly ISSUER=http://localhost:8180/family
readonly FERROFED=http://127.0.0.1:8080
readonly BRIDGE=http://127.0.0.1:8090/fhir
readonly NODE_A=http://127.0.0.1:8081/ferroehr/rest/openehr/v1
readonly NODE_B=http://127.0.0.1:8082/ferroehr/rest/openehr/v1
readonly TERM=http://127.0.0.1:8083/r4
readonly PIX=http://127.0.0.1:8070/fhir
readonly CDR_USER=ferroehr:ferroehr

# The synthetic patient: FerroFED's cross-reference rows name the same values.
readonly PATIENT_SYSTEM=urn:oid:2.999.1.1
readonly PATIENT_VALUE=family-e2e-0001
readonly EHR_A=aaaaaaaa-aaaa-4aaa-8aaa-0000000e2e01
readonly EHR_B=bbbbbbbb-bbbb-4bbb-8bbb-0000000e2e01
# The ehr_id domains of the two nodes at FerroPIX.
readonly DOMAIN_A=urn:oid:2.999.10
readonly DOMAIN_B=urn:oid:2.999.20

readonly FINDINGS=http://example.org/fhir/CodeSystem/family-e2e-finding
readonly FINDINGS_VS=http://example.org/fhir/ValueSet/family-e2e-findings
readonly FINDINGS_MAP=http://example.org/fhir/ConceptMap/family-e2e-finding-to-target
readonly ALPHA_DISPLAY="Family lane finding alpha"
readonly PROFILE=http://example.org/fhir/StructureDefinition/family-e2e-condition

# The synthetic templates and composition, from FerroBRIDGE's testkit at a
# fixed commit, each checked against its SHA-256 before it is used.
readonly FIXTURE_BASE=https://raw.githubusercontent.com/FerroHEALTH/FerroBRIDGE/191b51b05714d4e658b1d3674aea54963aaa2ca8/tools/ferrobridge-testkit/fixtures
readonly FIXTURES=(
  "opt/diagnose.opt d088aece7904c888e4d70620ca7e30d8b1ffa9bf0371cb7680544a990d45c86c"
  "opt/minimal_evaluation.opt d04d6b4a2e75726edd096a2ed545486b4d818f71ff4630ce4695c8165dd927e0"
  "composition/minimal_evaluation.json e644c18f2ef65f2f3f811015bf80112492a7cbac83c3650f34e7e2c55db85ad1"
)

keep=0
for arg in "$@"; do
  case "$arg" in
    --keep) keep=1 ;;
    *)
      echo "usage: e2e/family/run.sh [--keep]" >&2
      exit 2
      ;;
  esac
done

files=(-f compose.yaml)
read -r -a compose_cmd <<<"${FAMILY_E2E_COMPOSE:-docker compose}"

compose() {
  "${compose_cmd[@]}" "${files[@]}" "$@"
}

step() {
  echo "family-e2e: $1 $2"
}

# fail PRODUCT CALL WHAT: the one failure line, then the answer it got.
fail() {
  echo "family-e2e: FAIL $1 $2: $3" >&2
  if [[ -s "$WORK/answer" ]]; then
    echo "family-e2e: the answer was: $(head -c 2000 "$WORK/answer")" >&2
  fi
  exit 1
}

cleanup() {
  local status=$?
  if [[ "$status" -ne 0 ]]; then
    compose ps -a >&2 || true
    compose logs --no-color --tail=150 >&2 || true
  fi
  if [[ "$keep" -eq 0 ]]; then
    compose down -v --remove-orphans >/dev/null 2>&1 || true
  fi
  exit "$status"
}

# call METHOD URL [CURL_ARGS...]: one request; prints the status and keeps the
# answer in $WORK/answer. A transport failure prints 000.
call() {
  local method="$1" url="$2"
  shift 2
  curl -4 -sS -X "$method" "$url" -o "$WORK/answer" -w '%{http_code}' "$@" 2>"$WORK/curl.err" ||
    printf '000'
}

# expect PRODUCT CALL WANT GOT: the status the call had to answer.
expect() {
  [[ "$4" == "$3" ]] || fail "$1" "$2" "answered $4, expected $3"
}

# holds PRODUCT CALL JQ_FILTER WHAT: the answer satisfies the filter. A
# filter reads the values it compares from the environment (env.WANT).
holds() {
  jq -e "$3" "$WORK/answer" >/dev/null 2>&1 || fail "$1" "$2" "$4"
}

# wait_for PRODUCT CALL URL SECONDS: polls until the URL answers 200.
wait_for() {
  local product="$1" name="$2" url="$3" seconds="$4" status=000 i
  for ((i = 0; i < seconds; i += 2)); do
    status="$(call GET "$url")"
    [[ "$status" == 200 ]] && return 0
    sleep 2
  done
  fail "$product" "$name" "not ready after ${seconds}s, last status $status"
}

# token CLIENT SCOPE: an access token from the lane's issuer.
token() {
  local status
  status="$(call POST "$ISSUER/token" -d grant_type=client_credentials \
    -d "client_id=$1" -d client_secret=family-e2e -d "scope=$2")"
  expect issuer "POST /family/token ($1)" 200 "$status"
  jq -er .access_token "$WORK/answer" 2>/dev/null ||
    fail issuer "POST /family/token ($1)" "no access_token in the answer"
}

sha256() {
  if command -v sha256sum >/dev/null; then
    sha256sum "$1" | cut -c1-64
  else
    shasum -a 256 "$1" | cut -c1-64
  fi
}

# aql NODE_URL QUERY: an ad hoc AQL query at a FerroEHR node, rows in the answer.
aql() {
  jq -n --arg q "$2" '{q: $q}' >"$WORK/query.json"
  call POST "$1/query/aql" -u "$CDR_USER" -H 'Content-Type: application/json' \
    -H 'Accept: application/json' --data-binary "@$WORK/query.json"
}

for tool in curl jq openssl; do
  command -v "$tool" >/dev/null || fail lane preflight "$tool is not installed"
done

mkdir -p "$WORK/secrets" "$WORK/fixtures/opt" "$WORK/fixtures/composition"
: >"$WORK/answer"

step lane "fetching the synthetic fixtures from the FerroBRIDGE testkit"
for entry in "${FIXTURES[@]}"; do
  path="${entry%% *}"
  want="${entry##* }"
  curl --proto '=https' --proto-redir '=https' -fsSL "$FIXTURE_BASE/$path" -o "$WORK/fixtures/$path" ||
    fail lane "GET fixture $path" "could not be fetched"
  [[ "$(sha256 "$WORK/fixtures/$path")" == "$want" ]] ||
    fail lane "GET fixture $path" "its SHA-256 is not the pinned one"
done

step lane "writing the development secrets under .work/"
# The containers run as non-root users that must read these files, so they
# are world-readable inside a directory git ignores. Development values only.
printf 'ferroehr' >"$WORK/secrets/cdr_password"
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-384 \
  -out "$WORK/secrets/ferrofed-signing-key.pem" 2>/dev/null
printf 'family-e2e' >"$WORK/secrets/ferrofed-pix-client-secret"
openssl rand -base64 32 >"$WORK/secrets/ferropix-data-key"
openssl rand -hex 16 | tr -d '\n' >"$WORK/secrets/ferropix-postgres-password"
pix_password="$(openssl rand -hex 16)"
printf '%s' "$pix_password" >"$WORK/secrets/ferropix-db-password"
printf 'postgresql://ferropix:%s@ferropix-postgres:5432/ferropix' "$pix_password" \
  >"$WORK/secrets/ferropix-db-url"
chmod 644 "$WORK"/secrets/*

trap cleanup EXIT

first=(issuer ferroterm ferroehr-a ferroehr-b ferropix)
step lane "starting ${first[*]}"
compose pull --quiet
compose up -d --wait "${first[@]}" || fail lane "compose up" "a service did not turn healthy"
wait_for issuer "GET /family/.well-known/openid-configuration" \
  "$ISSUER/.well-known/openid-configuration" 120

# FerroTERM: the synthetic set it serves from its mount.
step FerroTERM "GET /r4/CodeSystem/\$lookup"
status="$(call GET "$TERM/CodeSystem/\$lookup" -G --data-urlencode "system=$FINDINGS" \
  --data-urlencode code=alpha -H 'Accept: application/fhir+json')"
expect FerroTERM "GET CodeSystem/\$lookup" 200 "$status"
WANT="$ALPHA_DISPLAY" holds FerroTERM "GET CodeSystem/\$lookup" \
  '.parameter[] | select(.name == "display") | .valueString == env.WANT' \
  "the display of alpha is not the one the mounted CodeSystem defines"

step FerroTERM "GET /r4/ValueSet/\$validate-code"
status="$(call GET "$TERM/ValueSet/\$validate-code" -G --data-urlencode "url=$FINDINGS_VS" \
  --data-urlencode "system=$FINDINGS" --data-urlencode code=beta -H 'Accept: application/fhir+json')"
expect FerroTERM "GET ValueSet/\$validate-code" 200 "$status"
holds FerroTERM "GET ValueSet/\$validate-code" \
  '.parameter[] | select(.name == "result") | .valueBoolean == true' \
  "beta is not a member of the mounted value set"

step FerroTERM "GET /r4/ConceptMap/\$translate"
status="$(call GET "$TERM/ConceptMap/\$translate" -G --data-urlencode "url=$FINDINGS_MAP" \
  --data-urlencode "system=$FINDINGS" --data-urlencode code=alpha -H 'Accept: application/fhir+json')"
expect FerroTERM "GET ConceptMap/\$translate" 200 "$status"
holds FerroTERM "GET ConceptMap/\$translate" \
  '[.parameter[] | select(.name == "match") | .part[] | select(.name == "concept") | .valueCoding.code] | index("T-ALPHA") != null' \
  "alpha does not translate to T-ALPHA through the mounted concept map"

# The two FerroEHR nodes: the templates, the patient's EHR at each, and one
# composition committed directly at each.
for node in "A $NODE_A $EHR_A" "B $NODE_B $EHR_B"; do
  read -r name root ehr <<<"$node"
  templates=(minimal_evaluation.opt)
  [[ "$name" == A ]] && templates+=(diagnose.opt)
  for template in "${templates[@]}"; do
    step FerroEHR "node $name: POST /definition/template/adl1.4 ($template)"
    status="$(call POST "$root/definition/template/adl1.4" -u "$CDR_USER" \
      -H 'Content-Type: application/xml' --data-binary "@$WORK/fixtures/opt/$template")"
    [[ "$status" == 201 || "$status" == 204 || "$status" == 200 ]] ||
      fail FerroEHR "node $name POST /definition/template/adl1.4 ($template)" "answered $status"
  done

  step FerroEHR "node $name: PUT /ehr/$ehr"
  jq -n --arg id "$PATIENT_VALUE" --arg ns "$PATIENT_SYSTEM" '{
    _type: "EHR_STATUS", archetype_node_id: "openEHR-EHR-EHR_STATUS.generic.v1",
    name: {_type: "DV_TEXT", value: "EHR Status"},
    archetype_details: {_type: "ARCHETYPED", rm_version: "1.1.0",
      archetype_id: {_type: "ARCHETYPE_ID", value: "openEHR-EHR-EHR_STATUS.generic.v1"}},
    subject: {_type: "PARTY_SELF", external_ref: {_type: "PARTY_REF", namespace: $ns,
      type: "PERSON", id: {_type: "GENERIC_ID", value: $id, scheme: "family-e2e"}}},
    is_queryable: true, is_modifiable: true}' >"$WORK/ehr_status.json"
  status="$(call PUT "$root/ehr/$ehr" -u "$CDR_USER" -H 'Content-Type: application/json' \
    -H 'Prefer: return=minimal' --data-binary "@$WORK/ehr_status.json")"
  [[ "$status" == 201 || "$status" == 204 ]] || fail FerroEHR "node $name PUT /ehr/$ehr" "answered $status"

  step FerroEHR "node $name: POST /ehr/$ehr/composition"
  status="$(call POST "$root/ehr/$ehr/composition" -u "$CDR_USER" -H 'Content-Type: application/json' \
    -H 'Prefer: return=minimal' --data-binary "@$WORK/fixtures/composition/minimal_evaluation.json")"
  [[ "$status" == 201 || "$status" == 204 ]] ||
    fail FerroEHR "node $name POST /ehr/$ehr/composition" "answered $status"
done

# FerroBRIDGE: started now that node A holds the template its mappings name.
step lane "starting ferrobridge"
compose up -d ferrobridge || fail lane "compose up ferrobridge" "the service did not start"
wait_for FerroBRIDGE "GET /health/readiness" http://127.0.0.1:8090/health/readiness 180

bridge_token="$(token family-e2e-client "user/Condition.cr")"
step FerroBRIDGE "POST /fhir/Condition (a coding with no display)"
jq -n --arg profile "$PROFILE" --arg ns "$PATIENT_SYSTEM" --arg id "$PATIENT_VALUE" \
  --arg system "$FINDINGS" '{
    resourceType: "Condition", meta: {profile: [$profile]},
    subject: {identifier: {system: $ns, value: $id}},
    code: {text: "Family lane problem"},
    verificationStatus: {coding: [{system: $system, code: "alpha"}]},
    onsetDateTime: "2026-10-01T09:00:00+02:00"}' >"$WORK/condition.json"
status="$(call POST "$BRIDGE/Condition" -H "Authorization: Bearer $bridge_token" \
  -H 'Content-Type: application/fhir+json' -H 'Accept: application/fhir+json' \
  --data-binary "@$WORK/condition.json")"
expect FerroBRIDGE "POST /fhir/Condition" 201 "$status"
condition_id="$(jq -er .id "$WORK/answer" 2>/dev/null)" ||
  fail FerroBRIDGE "POST /fhir/Condition" "the created resource carries no id"

step FerroBRIDGE "GET /fhir/Condition/$condition_id"
status="$(call GET "$BRIDGE/Condition/$condition_id" -H "Authorization: Bearer $bridge_token" \
  -H 'Accept: application/fhir+json')"
expect FerroBRIDGE "GET /fhir/Condition/{id}" 200 "$status"
SYSTEM="$FINDINGS" WANT="$ALPHA_DISPLAY" holds FerroBRIDGE "GET /fhir/Condition/{id}" \
  '.verificationStatus | .text == env.WANT and any(.coding[]; .system == env.SYSTEM and .code == "alpha")' \
  "the verification status is not alpha with the display FerroTERM's \$lookup gave as its text"

# The composition counts per node, and the certainty FerroBRIDGE wrote. The
# DV_CODED_TEXT value is the CodeableConcept's text (FHIRconnect v1.0.0,
# data-type/DV_CODED_TEXT).
step FerroEHR "node A: POST /query/aql (compositions of the patient's EHR)"
status="$(aql "$NODE_A" "SELECT c/uid/value AS uid FROM EHR e[ehr_id/value='$EHR_A'] CONTAINS COMPOSITION c")"
expect FerroEHR "node A POST /query/aql" 200 "$status"
holds FerroEHR "node A POST /query/aql" '.rows | length == 2' \
  "node A does not hold two compositions for the patient (one committed directly, one through FerroBRIDGE)"

step FerroEHR "node A: POST /query/aql (the certainty FerroBRIDGE committed)"
status="$(aql "$NODE_A" "SELECT d/data[at0001]/items[at0073]/value/value AS certainty, d/data[at0001]/items[at0073]/value/defining_code/code_string AS code FROM EHR e[ehr_id/value='$EHR_A'] CONTAINS COMPOSITION c CONTAINS EVALUATION d[openEHR-EHR-EVALUATION.problem_diagnosis.v1]")"
expect FerroEHR "node A POST /query/aql" 200 "$status"
WANT="$ALPHA_DISPLAY" holds FerroEHR "node A POST /query/aql" '.rows == [[env.WANT, "alpha"]]' \
  "the stored DV_CODED_TEXT is not alpha with FerroTERM's display"

step FerroEHR "node B: POST /query/aql (compositions of the patient's EHR)"
status="$(aql "$NODE_B" "SELECT c/uid/value AS uid FROM EHR e[ehr_id/value='$EHR_B'] CONTAINS COMPOSITION c")"
expect FerroEHR "node B POST /query/aql" 200 "$status"
holds FerroEHR "node B POST /query/aql" '.rows | length == 1' "node B does not hold one composition for the patient"

# FerroPIX: both sites feed the patient, and the cross-reference links them.
for site in "a $DOMAIN_A $EHR_A" "b $DOMAIN_B $EHR_B"; do
  read -r name domain ehr <<<"$site"
  source_token="$(token "family-e2e-source-$name" "system/Patient.cud")"
  step FerroPIX "PUT /fhir/Patient?identifier=$domain|<ehr_id> (ITI-104, site $name)"
  jq -n --arg d "$domain" --arg e "$ehr" --arg ns "$PATIENT_SYSTEM" --arg id "$PATIENT_VALUE" '{
    resourceType: "Patient",
    identifier: [{system: $d, value: $e}, {system: $ns, value: $id}],
    name: [{family: "Lane", given: ["Family"]}], gender: "unknown", birthDate: "1970-01-01"}' \
    >"$WORK/patient.json"
  status="$(call PUT "$PIX/Patient" -G --data-urlencode "identifier=$domain|$ehr" \
    -H "Authorization: Bearer $source_token" -H 'Content-Type: application/fhir+json' \
    -H 'Accept: application/fhir+json' --data-binary "@$WORK/patient.json")"
  [[ "$status" == 201 || "$status" == 200 ]] ||
    fail FerroPIX "PUT /fhir/Patient (ITI-104, site $name)" "answered $status"
done

consumer_token="$(token family-e2e-client "system/Patient.rs")"
step FerroPIX "POST /fhir/Patient/\$ihe-pix (ITI-83)"
jq -n --arg src "$PATIENT_SYSTEM|$PATIENT_VALUE" --arg a "$DOMAIN_A" --arg b "$DOMAIN_B" '{
  resourceType: "Parameters", parameter: [
    {name: "sourceIdentifier", valueString: $src},
    {name: "targetSystem", valueString: $a}, {name: "targetSystem", valueString: $b}]}' \
  >"$WORK/pix.json"
status="$(call POST "$PIX/Patient/\$ihe-pix" -H "Authorization: Bearer $consumer_token" \
  -H 'Content-Type: application/fhir+json' -H 'Accept: application/fhir+json' \
  --data-binary "@$WORK/pix.json")"
expect FerroPIX "POST /fhir/Patient/\$ihe-pix" 200 "$status"
A="$EHR_A" B="$EHR_B" holds FerroPIX "POST /fhir/Patient/\$ihe-pix" \
  '[.parameter[] | select(.name == "targetIdentifier") | .valueIdentifier.value] | sort == ([env.A, env.B] | sort)' \
  "the cross-reference does not name both nodes' ehr_ids"

step FerroPIX "GET /fhir/Patient?identifier= (ITI-78)"
status="$(call GET "$PIX/Patient" -G --data-urlencode "identifier=$PATIENT_SYSTEM|$PATIENT_VALUE" \
  -H "Authorization: Bearer $consumer_token" -H 'Accept: application/fhir+json')"
expect FerroPIX "GET /fhir/Patient (ITI-78)" 200 "$status"
holds FerroPIX "GET /fhir/Patient (ITI-78)" \
  '[.entry[]? | select(.resource.resourceType == "Patient")] | length == 1' \
  "the search does not find exactly one person for the patient"

# FerroFED: one query answered from both nodes, each row carrying its node.
step lane "starting ferrofed"
compose up -d --wait ferrofed || fail lane "compose up ferrofed" "the service did not turn healthy"
fed_token="$(token family-e2e-client "user/aql-*.s user/composition-*.r")"
step FerroFED "POST /v1/query/aql (the patient's compositions at every node)"
jq -n --arg id "$PATIENT_VALUE" --arg ns "$PATIENT_SYSTEM" \
  '{q: "SELECT c/uid/value AS uid FROM EHR e CONTAINS COMPOSITION c WHERE e/ehr_status/subject/external_ref/id/value = \u0027\($id)\u0027 AND e/ehr_status/subject/external_ref/namespace = \u0027\($ns)\u0027"}' \
  >"$WORK/fed.json"
status="$(call POST "$FERROFED/v1/query/aql" -H "Authorization: Bearer $fed_token" \
  -H 'Content-Type: application/json' -H 'Accept: application/json' --data-binary "@$WORK/fed.json")"
expect FerroFED "POST /v1/query/aql" 200 "$status"
holds FerroFED "POST /v1/query/aql" '.rows | length == 3' "the federated answer does not hold three rows"
holds FerroFED "POST /v1/query/aql" \
  '[.rows[][0] | select(contains("::node-a.family-e2e.local::"))] | length == 2' \
  "node A's two compositions are not in the federated answer"
holds FerroFED "POST /v1/query/aql" \
  '[.rows[][0] | select(contains("::node-b.family-e2e.local::"))] | length == 1' \
  "node B's composition is not in the federated answer"

# TODO(#66): the federated patient summary from both nodes, with codes
# translated through FerroTERM, once FerroFED and FerroPIX release it.
step FerroFED "GET /fhir/Patient/\$summary: pending, see FerroHEALTH#66"

step lane "every step passed"
