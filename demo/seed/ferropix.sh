# shellcheck shell=bash
# up.sh defines hospital_token, BSN_SYSTEM and the helpers before it sources this.
# shellcheck disable=SC2154
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# The FerroPIX part of the demo's seed, sourced by up.sh after the FerroFED
# patients are fed: the population of seed/population.tsv over FHIR (ITI-104)
# and, for hospital E, over HL7 v2 MLLP (ITI-8); a revision of six records;
# one removed record; and the steward's work through the operator API, which
# links, rejects and defers candidates, keeps one merge and reverts another,
# and mints research pseudonyms. It uses up.sh's call, token, feed and fail.

readonly OPERATOR=https://localhost:8070/operator
steward_token="$(token demo-steward)"

# operator METHOD PATH [BODY]: one operator API call as the steward.
operator() {
  local status
  if [[ $# -ge 3 ]]; then
    status="$(call "$1" "$OPERATOR$2" -H "Authorization: Bearer $steward_token" \
      -H 'Content-Type: application/json' --data-binary "$3")"
  else
    status="$(call "$1" "$OPERATOR$2" -H "Authorization: Bearer $steward_token")"
  fi
  [[ "$status" =~ ^2 ]] || fail "FerroPIX $1 /operator$2 answered $status"
}

# patient_json ROW...: the FHIR Patient of one population row.
patient_json() {
  jq -n --arg s "urn:oid:2.999.3.$(index "$3")" --arg mrn "$4" --arg given "$5" --arg family "$6" \
    --arg gender "$7" --arg birth "$8" --arg bsn "$9" --arg bs "$BSN_SYSTEM" --arg street "${10}" \
    --arg postcode "${11}" --arg city "${12}" --arg phone "${13}" --arg email "${14}" '
    def given: $given;
    {resourceType: "Patient",
     identifier: ([{system: $s, value: $mrn}] + (if $bsn == "-" then [] else [{system: $bs, value: $bsn}] end)),
     name: [{family: $family, given: [given]}], gender: $gender, birthDate: $birth}
    + (if $street == "-" and $postcode == "-" then {} else {address: [{use: "home",
        line: (if $street == "-" then [] else [$street] end), city: (if $city == "-" then null else $city end),
        postalCode: (if $postcode == "-" then null else $postcode end), country: "NL"} | with_entries(select(.value != null and .value != []))]} end)
    + ([(if $phone == "-" then empty else {system: "phone", value: $phone, use: "mobile"} end),
        (if $email == "-" then empty else {system: "email", value: $email} end)] as $t
       | if ($t | length) == 0 then {} else {telecom: $t} end)'
}

# mllp MESSAGE: one HL7 v2 message to FerroPIX's listener; prints its MSA-1.
mllp() {
  printf '\x0b%s\x1c\r' "$1" | nc -w 5 127.0.0.1 2575 | tr '\r' '\n' | awk -F'|' '$1 == "MSA" { print $2 }'
}

# adt TRIGGER CONTROL ROW...: an ADT message from hospital E for a row.
adt() {
  local trigger="$1" control="$2" phone
  shift 2
  phone="${13}"
  [[ "$phone" == - ]] && phone=""
  printf 'MSH|^~\\&|ADT|HOSP_E|FERROPIX|FERROPIX|20261029120000||ADT^%s^ADT_A01|%s|P|2.5.1\rEVN|%s|20261029120000\rPID|1||%s^^^HOSPE&2.999.3.5&ISO^MR~%s^^^NLMINBIZA&2.16.840.1.113883.2.4.6.3&ISO^NNNLD||%s^%s||%s|%s|||||%s\rPV1|1|O' \
    "$trigger" "$control" "$trigger" "$4" "$9" "$6" "$5" "${8//-/}" "$(printf '%s' "$7" | cut -c1 | tr '[:lower:]' '[:upper:]')" "$phone"
}

# person_of HOSPITAL NUMBER: the FerroPIX person a hospital's record belongs to.
person_of() {
  operator POST /search/identifier "$(jq -n --arg s "urn:oid:2.999.3.$(index "$1")" --arg v "$2" \
    '{system: $s, value: $v}')"
  jq -er '.persons[0].id' "$WORK/answer" || fail "FerroPIX knows no person for $1 $2"
}

days_from_now() {
  date -u -v+"$1"d +%F 2>/dev/null || date -u -d "+$1 days" +%F
}

step "feeding the FerroPIX population: four hospitals over FHIR, hospital E over HL7 v2"
hl7_sent=0
while IFS=$'\t' read -r -a row; do
  [[ -z "${row[0]:-}" || "${row[0]}" == \#* ]] && continue
  if [[ "${row[2]}" == e ]]; then
    hl7_sent=$((hl7_sent + 1))
    ack="$(mllp "$(adt A04 "DEMO-$hl7_sent" "${row[@]}")")"
    [[ "$ack" == AA ]] || fail "FerroPIX answered $ack to hospital E's ADT^A04 for ${row[3]}"
    continue
  fi
  feed "${row[2]}" "urn:oid:2.999.3.$(index "${row[2]}")" "${row[3]}" "$(patient_json "${row[@]}")"
done <seed/population.tsv

step "revising six records, a hospital E update over HL7 v2, and the refusals a sender sees"
revised=0
while IFS=$'\t' read -r -a row; do
  [[ "${row[0]}" == single && "${row[3]}" =~ [13]$ ]] || continue
  row[9]="Nieuwe Gracht $((10 + revised))"
  row[10]="3512 LK"
  row[11]="Utrecht"
  feed "${row[2]}" "urn:oid:2.999.3.$(index "${row[2]}")" "${row[3]}" "$(patient_json "${row[@]}")"
  revised=$((revised + 1))
done <seed/population.tsv
first_e="$(awk -F'\t' '$3 == "e" { print; exit }' seed/population.tsv)"
IFS=$'\t' read -r -a row <<<"$first_e"
row[12]="+31 6 55500011"
[[ "$(mllp "$(adt A08 DEMO-A08 "${row[@]}")")" == AA ]] || fail "FerroPIX refused hospital E's ADT^A08"
# An unknown sender and a discharge FerroPIX does not take: the source page
# shows the refusals beside the accepted messages.
unknown="$(adt A04 DEMO-UNKNOWN "${row[@]}")"
mllp "${unknown/ADT|HOSP_E/LAB|HOSP_X}" >/dev/null
mllp "$(adt A03 DEMO-A03 "${row[@]}")" >/dev/null

step "removing one record (ITI-104 Remove Patient)"
removed="$(awk -F'\t' '$1 == "control" && $3 == "d" { print $4; exit }' seed/population.tsv)"
status="$(call DELETE "$PIX/Patient?identifier=urn:oid:2.999.3.4%7C$removed" \
  -H "Authorization: Bearer ${hospital_token[4]}" -H 'Accept: application/fhir+json')"
[[ "$status" =~ ^(200|204)$ ]] || fail "FerroPIX Remove Patient answered $status"

step "the steward's work: decisions, a kept merge, a reverted merge, research pseudonyms"
# decide KEY VERDICT [UNTIL]: decide the open candidate between a pair's records.
decide() {
  local a b id body candidate
  read -r a b <<<"$(awk -F'\t' -v k="$1" '$2 == k { printf "%s %s ", $3, $4 }' seed/population.tsv |
    awk '{ print $1 "|" $2, $3 "|" $4 }')"
  a="$(person_of "${a%%|*}" "${a#*|}")"
  b="$(person_of "${b%%|*}" "${b#*|}")"
  id=""
  operator GET "/candidates"
  # NOTE: a queue row names its records but not their persons, so each
  # candidate is read until the one between the pair's two persons.
  for candidate in $(jq -r '.rows[].id' "$WORK/answer"); do
    operator GET "/candidates/$candidate"
    if A="$a" B="$b" jq -e '(.a.person == env.A and .b.person == env.B)
      or (.a.person == env.B and .b.person == env.A)' "$WORK/answer" >/dev/null; then
      id="$candidate"
      break
    fi
  done
  [[ -n "$id" ]] || fail "FerroPIX holds no open candidate for pair $1"
  body="$(jq --arg v "$2" --arg until "${3:-}" '{verdict: $v, a_version: .a.version,
    b_version: .b.version, reason: "Demo seed: decided by the data steward"}
    + (if $until == "" then {} else {until: $until} end)' "$WORK/answer")"
  operator POST "/candidates/$id/decide" "$body"
}
decide D1 link
decide D2 link
decide T1 not-a-match
decide T2 not-a-match
decide F1 defer "$(days_from_now 1)"
decide F2 defer "$(days_from_now 30)"

# merge KEY: merge a pair's second person into its first; prints the merge id.
merge() {
  local survivor merged body
  survivor="$(person_of a "$(awk -F'\t' -v k="$1" '$2 == k && $3 == "a" { print $4 }' seed/population.tsv)")"
  merged="$(person_of c "$(awk -F'\t' -v k="$1" '$2 == k && $3 == "c" { print $4 }' seed/population.tsv)")"
  operator GET "/merges/preview?survivor=$survivor&merged=$merged"
  body="$(jq '{survivor: .survivor.id, survivor_version: .survivor.version, merged: .merged.id,
    merged_version: .merged.version, reason: "Demo seed: married name, same person"}' "$WORK/answer")"
  operator POST /merges "$body"
  jq -er '.merge // .id' "$WORK/answer"
}
merge M1 >/dev/null
reverted="$(merge M2)"
operator GET "/merges/preview?revert=$reverted"
operator POST "/merges/$reverted/revert" "$(jq '{survivor_version: .survivor.version,
  reason: "Demo seed: merged in error, reverted"}' "$WORK/answer")"

operator GET /pseudonym-domains
research="$(jq -r '[.. | objects | select(.namespace? == "urn:oid:2.999.7.9")][0].id' "$WORK/answer")"
while read -r hospital number; do
  operator POST /pseudonyms "$(jq -n --arg p "$(person_of "$hospital" "$number")" --arg d "$research" \
    '{person: $p, domain: $d}')"
done < <(awk -F'\t' '$1 == "bsn-link" && !seen[$2]++ { print $3, $4 }' seed/population.tsv | head -n 5)
