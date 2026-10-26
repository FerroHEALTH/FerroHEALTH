#!/usr/bin/env bash
# SPDX-FileCopyrightText: Cadasto B.V.
# SPDX-License-Identifier: Apache-2.0
#
# ehds-tracker.sh: the EHDS readiness source never says "planned" about work
# the tracker has closed, and names no issue that does not exist.
#
#   scripts/checks/ehds-tracker.sh              read the states through gh
#   scripts/checks/ehds-tracker.sh --self-test  prove the decision offline
#
# website/book/ehds.yaml names its issues with their repository
# (`FerroEHR#3606`, `FerroBRIDGE#12`), because the EHR system it describes is
# two products with a tracker each. This reads every named issue's state from
# its own repository, one GraphQL call per repository, and fails when:
#
#   * an entry says `status: planned` and every issue it names is closed,
#     which means the page claims as planned what has shipped or been dropped;
#   * an issue it names does not exist.
#
# The other direction, "shipped" beside an open issue, is a split row the
# YAML is allowed to carry (a shipped capability with follow-up work), so it
# is not refused.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

readonly SRC=website/book/ehds.yaml

die() { echo "ehds-tracker: $*" >&2; exit 1; }

# findings STATES_JSON ENTRIES_JSON: prints one line per finding. STATES maps
# "Repo#N" to OPEN, CLOSED or UNKNOWN; ENTRIES is a list of
# {where, status, issues}.
findings() {
  jq -nr --argjson states "$1" --argjson entries "$2" '
    $entries[]
    | . as $e
    | ([$e.issues[] | $states[.] // "UNKNOWN"]) as $s
    | ( ($e.issues | to_entries[] | select(($states[.value] // "UNKNOWN") == "UNKNOWN")
          | "\($e.where) names \(.value), which does not exist"),
        (if $e.status == "planned" and ($s | length) > 0 and ($s | all(. == "CLOSED"))
         then "\($e.where) says planned, and every issue it names is closed: \($e.issues | join(", "))"
         else empty end) )'
}

self_test() {
  local states entries out
  states='{"FerroEHR#1":"CLOSED","FerroEHR#2":"OPEN","FerroBRIDGE#3":"CLOSED"}'
  entries='[{"where":"a","status":"planned","issues":["FerroEHR#1","FerroBRIDGE#3"]},
            {"where":"b","status":"planned","issues":["FerroEHR#1","FerroEHR#2"]},
            {"where":"c","status":"shipped","issues":["FerroEHR#2"]},
            {"where":"d","status":"partial","issues":["FerroEHR#9"]}]'
  out="$(findings "$states" "$entries")"
  [[ "$out" == *"a says planned"* ]] || die "self-test: a planned row whose issues are all closed passed"
  [[ "$out" != *"b says planned"* ]] || die "self-test: a planned row with an open issue was refused"
  [[ "$out" != *"c "* ]] || die "self-test: a shipped row with an open issue was refused"
  [[ "$out" == *"d names FerroEHR#9, which does not exist"* ]] || die "self-test: a missing issue passed"
  echo "ehds-tracker: self-test OK (closed planned row, open planned row, shipped split row, missing issue)."
}

case "${1:-}" in
  --self-test) self_test; exit 0 ;;
  "") ;;
  *) die "usage: $0 [--self-test]" ;;
esac

for tool in yq jq gh; do
  command -v "$tool" >/dev/null || die "$tool is not on PATH"
done

json="$(yq -o=json '.' "$SRC")"
# Every object that carries `issues`, with where it sits and its status.
entries="$(jq -c '[paths(objects) as $p | getpath($p) | select(type == "object" and has("issues"))
  | {where: (.id // .name // "an entry"), status: (.status // ""), issues: .issues}]' <<<"$json")"
refs="$(jq -r '[.[].issues[]] | unique | .[]' <<<"$entries")"
[[ -n "$refs" ]] || { echo "ehds-tracker: $SRC names no issue"; exit 0; }

states='{}'
while IFS= read -r repo; do
  numbers="$(jq -r --arg r "$repo" '[.[].issues[] | select(startswith($r + "#")) | split("#")[1]] | unique | .[]' <<<"$entries")"
  query="query(\$owner:String!,\$name:String!){repository(owner:\$owner,name:\$name){"
  for n in $numbers; do query+="i$n: issue(number:$n){number state} "; done
  query+="}}"
  # A missing issue makes GitHub answer with an error beside the data, and
  # gh exits non-zero; the data still names every issue that exists.
  body="$(gh api graphql -f owner=FerroHEALTH -f name="$repo" -f query="$query" 2>/dev/null || true)"
  [[ -n "$body" ]] || die "gh could not read FerroHEALTH/$repo"
  got="$(jq -c --arg r "$repo" '(.data.repository // {}) | to_entries | map(select(.value != null))
    | map({("\($r)#\(.value.number)"): .value.state}) | add // {}' <<<"$body")"
  states="$(jq -c --argjson more "$got" '. + $more' <<<"$states")"
done < <(jq -r '[.[].issues[] | split("#")[0]] | unique | .[]' <<<"$entries")

out="$(findings "$states" "$entries")"
if [[ -n "$out" ]]; then
  while IFS= read -r line; do echo "ehds-tracker: $line" >&2; done <<<"$out"
  exit 1
fi
echo "ehds-tracker: $(wc -l <<<"$refs" | tr -d ' ') issues in $SRC agree with their trackers."
