# shellcheck shell=bash
# up.sh defines the helpers, FED and PATIENT_SYSTEM before it sources this.
# shellcheck disable=SC2154
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# The FerroFED part of the demo's seed, sourced by up.sh once the members hold
# their patients: three stored queries distributed to every member, the first
# in two versions; one EHR id claimed by two members, which the ask-all probe
# records as an integrity incident; and the federated query for Eva Visser,
# which gives every endpoint its first health state.

fed_token="$(token demo-seed)"

# fed METHOD PATH [CURL_ARGS...]: one gateway call as the demo client.
fed() {
  local method="$1" path="$2"
  shift 2
  call "$method" "$FED$path" -H "Authorization: Bearer $fed_token" "$@"
}

step "storing three queries at the gateway, distributed to every member"
# store NAME [VERSION] AQL: one stored query, sent to every member.
store() {
  local status path="/v1/definition/query/org.ferrohealth.demo::$1"
  [[ -n "$2" ]] && path="$path/$2"
  status="$(fed PUT "$path" -H 'Content-Type: text/plain' -H 'openEHR-federation-endpoint: *' \
    --data-binary "$3")"
  [[ "$status" =~ ^(200|201|204|207)$ ]] || fail "FerroFED PUT $path answered $status"
}
patient_where="e/ehr_status/subject/external_ref/id/value = \$patient AND e/ehr_status/subject/external_ref/namespace = '$PATIENT_SYSTEM'"
store patient_compositions 1.0.0 \
  "SELECT c/uid/value AS uid FROM EHR e CONTAINS COMPOSITION c WHERE $patient_where"
store patient_compositions "" \
  "SELECT c/uid/value AS uid, c/name/value AS name, c/archetype_details/template_id/value AS template FROM EHR e CONTAINS COMPOSITION c WHERE $patient_where"
store composition_count 1.0.0 "SELECT COUNT(c/uid/value) AS compositions FROM EHR e CONTAINS COMPOSITION c"
status="$(fed POST /v1/query/org.ferrohealth.demo::patient_compositions -H 'Content-Type: application/json' \
  --data-binary '{"query_parameters": {"patient": "ffd-test-0001"}}')"
[[ "$status" == 200 ]] || fail "FerroFED POST /v1/query/org.ferrohealth.demo::patient_compositions answered $status"

step "claiming one EHR id at members C and D, and letting the gateway find it"
# The same ehr_id at two members is an integrity incident the ask-all probe
# records; the console's Integrity page shows it with its Clear action.
collision="ee000000-0000-4000-8000-00000000c011"
for n in c d; do
  status="$(call PUT "$(member_url "$n")/ehr/$collision" -u "$CDR_USER" -H 'Content-Type: application/json' \
    -H 'Prefer: return=minimal' \
    --data-binary "$(ehr_status "$(openssl rand -hex 16 | sed -E 's/(.{8})(.{4}).(.{3}).(.{3})(.{12})/\1-\2-4\3-8\4-\5/')" \
      "urn:oid:2.999.7.$(index "$n")")")"
  [[ "$status" =~ ^(201|204)$ ]] || fail "member $n PUT /ehr/$collision answered $status"
done
status="$(fed GET "/v1/ehr/$collision" -H 'Accept: application/json')"
[[ "$status" == 409 ]] || fail "FerroFED GET /v1/ehr/$collision answered $status, expected 409 for two claimants"

step "asking FerroFED for Eva Visser (ffd-test-0001) at every member"
query="SELECT c/uid/value AS uid FROM EHR e CONTAINS COMPOSITION c WHERE e/ehr_status/subject/external_ref/id/value = 'ffd-test-0001' AND e/ehr_status/subject/external_ref/namespace = '$PATIENT_SYSTEM'"
status="$(fed POST /v1/query/aql -H 'Content-Type: application/json' -H 'Accept: application/json' \
  --data-binary "$(jq -n --arg q "$query" '{q: $q}')")"
[[ "$status" == 200 ]] || fail "FerroFED POST /v1/query/aql answered $status"
rows="$(jq '.rows | length' "$WORK/answer")"
[[ "$rows" -ge 4 ]] || fail "FerroFED answered $rows rows for ffd-test-0001, expected one or more per member"

step "asking FerroFED for Eva Visser by her BSN, which it resolves through PDQm first"
# A BSN is a namespace [pdqm.namespaces] names, so the gateway asks FerroPIX's
# PDQm for the person first; that gives the Demographics service its health.
query="SELECT c/uid/value AS uid FROM EHR e CONTAINS COMPOSITION c WHERE e/ehr_status/subject/external_ref/id/value = '900000016' AND e/ehr_status/subject/external_ref/namespace = '$BSN_SYSTEM'"
status="$(fed POST /v1/query/aql -H 'Content-Type: application/json' -H 'Accept: application/json' \
  --data-binary "$(jq -n --arg q "$query" '{q: $q}')")"
[[ "$status" == 200 ]] || fail "FerroFED POST /v1/query/aql by BSN answered $status"
[[ "$(jq '.rows | length' "$WORK/answer")" -eq "$rows" ]] ||
  fail "FerroFED answered Eva Visser's BSN with other rows than her patient identifier"
