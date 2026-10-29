# shellcheck shell=bash
# up.sh defines the helpers, the tokens and ferroehr_src before it sources this.
# shellcheck disable=SC2154
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# The FerroEHR part of the demo's seed, sourced by up.sh after FerroPIX holds
# the population. Each member is a different kind of care: A an academic
# hospital (beside FerroEHR's sandbox dataset), B a GP practice, C a public
# health service with its laboratory, D an outpatient clinic. Every patient a
# member holds, the FerroFED patients and that hospital's own six, gets three
# vital-signs readings over the year and the member's own compositions, from
# the curated examples of FerroEHR v5.5.0's corpus. Each hospital's patients
# get an EHR at its member under their FerroPIX pseudonym, and their ehr_id
# is fed back so FerroFED finds them by BSN.

readonly CKM="$ferroehr_src/corpus/templates/ckm"
readonly SPECIALTY_A="ereferral"
readonly SPECIALTY_B="gp-data-set eprescription-fhir"
readonly SPECIALTY_C="generic-lab-test-result covid19-infection-report"
readonly SPECIALTY_D="international-patient-summary ereferral"

facility() {
  case "$1" in
    a) echo "Academisch Ziekenhuis A" ;;
    b) echo "Huisartsenpraktijk B" ;;
    c) echo "GGD en Laboratorium C" ;;
    d) echo "Polikliniek D" ;;
  esac
}

clinician() {
  case "$1" in
    a) echo "Dr. M. de Vries, internist" ;;
    b) echo "J. Smit, huisarts" ;;
    c) echo "Dr. L. Bakker, arts maatschappij en gezondheid" ;;
    d) echo "Dr. S. Peters, oogarts" ;;
  esac
}

step "uploading the vital-signs and specialty templates to every member through FerroFED"
for slug in vital-signs gp-data-set eprescription-fhir generic-lab-test-result covid19-infection-report \
  international-patient-summary ereferral; do
  status="$(call POST "$FED/v1/definition/template/adl1.4" -H "Authorization: Bearer $seed_token" \
    -H 'openEHR-federation-endpoint: *' -H 'Content-Type: application/xml' --data-binary "@$CKM/$slug.opt")"
  [[ "$status" =~ ^(200|201|204|207|409)$ ]] || fail "FerroFED template fan-out of $slug answered $status"
done

# compose MEMBER EHR SLUG TIME [SEED]: one composition from the curated example,
# with the member's facility and clinician, at TIME; vital signs take values
# that vary with SEED.
compose_at() {
  local body status
  body="$(jq --arg t "$4" --arg who "$(clinician "$1")" --arg fac "$(facility "$1")" \
    --argjson s "${5:-0}" --arg slug "$3" '
    .composer.name = $who
    | .context.start_time.value = $t
    | .context.health_care_facility = {_type: "PARTY_IDENTIFIED", name: $fac}
    | (.. | objects | select(._type? == "POINT_EVENT" or ._type? == "INTERVAL_EVENT") | .time.value) |= $t
    | if $slug == "vital-signs" then
        .content[0].data.events[0].data.items[0].value.magnitude = (36.4 + ($s % 9) / 10)
        | .content[1].data.events[0].data.items[0].value.magnitude = (112 + ($s * 7) % 41)
        | .content[1].data.events[0].data.items[1].value.magnitude = (68 + ($s * 5) % 23)
        | .content[2].data.events[0].data.items[0].value.magnitude = (20.5 + ($s % 11) / 2)
        | .content[3].data.events[0].data.items[0].value.magnitude = (158 + ($s * 3) % 35)
        | .content[4].data.events[0].data.items[0].value.magnitude = (54 + ($s * 11) % 47)
        | .content[5].data.events[0].data.items[0].value.magnitude = (58 + ($s * 13) % 37)
        | .content[6].data.events[0].data.items[0].value.magnitude = (12 + $s % 9)
        | .content[7].data.events[0].data.items[0].value.numerator = (94 + $s % 6)
      else . end' "$CKM/$3.example.json")"
  status="$(call POST "$(member_url "$1")/ehr/$2/composition" -u "$CDR_USER" \
    -H 'Content-Type: application/json' -H 'Prefer: return=minimal' --data-binary "$body")"
  [[ "$status" =~ ^(201|204)$ ]] || fail "member $1 POST $3 composition answered $status"
}

# chart MEMBER EHR SEED: three vital-signs readings and the member's specialty.
chart() {
  local slug specialty
  compose_at "$1" "$2" vital-signs 2026-03-11T09:15:00+01:00 "$3"
  compose_at "$1" "$2" vital-signs 2026-06-17T10:40:00+02:00 "$(($3 + 1))"
  compose_at "$1" "$2" vital-signs 2026-09-23T14:05:00+02:00 "$(($3 + 2))"
  case "$1" in
    a) specialty="$SPECIALTY_A" ;;
    b) specialty="$SPECIALTY_B" ;;
    c) specialty="$SPECIALTY_C" ;;
    d) specialty="$SPECIALTY_D" ;;
  esac
  for slug in $specialty; do
    compose_at "$1" "$2" "$slug" 2026-09-23T15:00:00+02:00
  done
}

step "charting the FerroFED patients at every member that holds them"
chart_seed=1
while IFS=$'\t' read -r patient _ _ _ _ _ members; do
  [[ -z "$patient" || "$patient" == \#* || "$members" == - ]] && continue
  number="${patient##*-}"
  for n in $members; do
    chart "$n" "$(printf '%s%s%s%s%s%s%s%s' "$n" "$n" "$n" "$n" "$n" "$n" "$n" "$n")-$n$n$n$n-4$n$n$n-8$n$n$n-$(printf '%012d' "$((10#$number))")" "$chart_seed"
    chart_seed=$((chart_seed + 3))
  done
done <seed/patients.tsv

step "giving each hospital's own patients an EHR at its member, charted"
while IFS=$'\t' read -r -a row; do
  [[ "${row[0]}" == single && "${row[2]}" != e ]] || continue
  n="${row[2]}"
  i="$(index "$n")"
  alias_id="$(pseudonym "$n" "urn:oid:2.999.3.$i" "${row[3]}")"
  ehr_id="$(printf '%s%s%s%s%s%s%s%s' "$n" "$n" "$n" "$n" "$n" "$n" "$n" "$n")-$n$n$n$n-4$n$n$n-8$n$n$n-0000000${row[3]#*-}0"
  status="$(call PUT "$(member_url "$n")/ehr/$ehr_id" -u "$CDR_USER" -H 'Content-Type: application/json' \
    -H 'Prefer: return=minimal' --data-binary "$(ehr_status "$alias_id" "urn:oid:2.999.7.$i")")"
  [[ "$status" =~ ^(201|204)$ ]] || fail "member $n PUT /ehr/$ehr_id answered $status"
  feed "$n" "urn:oid:2.999.2.$i" "$ehr_id" "$(jq -n --arg s "urn:oid:2.999.2.$i" --arg e "$ehr_id" \
    --arg bs "$BSN_SYSTEM" --arg bsn "${row[8]}" --arg given "${row[4]}" --arg family "${row[5]}" \
    --arg gender "${row[6]}" --arg birth "${row[7]}" '{resourceType: "Patient",
    identifier: [{system: $s, value: $e}, {system: $bs, value: $bsn}],
    name: [{family: $family, given: [$given]}], gender: $gender, birthDate: $birth}')"
  chart "$n" "$ehr_id" "$chart_seed"
  chart_seed=$((chart_seed + 3))
done <seed/population.tsv

step "storing each member's own queries"
for n in a b c d; do
  status="$(call PUT "$(member_url "$n")/definition/query/nl.hospital-$n::vital_signs/1.0.0" -u "$CDR_USER" \
    -H 'Content-Type: text/plain' --data-binary "SELECT e/ehr_id/value AS ehr_id, c/context/start_time/value AS taken, o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS systolic, o/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude AS diastolic FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o[openEHR-EHR-OBSERVATION.blood_pressure.v2] ORDER BY c/context/start_time/value DESC")"
  [[ "$status" =~ ^(200|201|204|409)$ ]] || fail "member $n PUT stored query answered $status"
done
