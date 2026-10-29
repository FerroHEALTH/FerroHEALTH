<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# The FerroHEALTH family demo

One command starts every FerroHEALTH product and its console on your machine,
seeds them with synthetic patients, and signs you in to all of them through one
Keycloak as `demo` / `demo`.

Everything here uses demo credentials. Never use this setup, its passwords or
its keys for real patient data.

## What runs

| Product | Console | What the demo holds |
|---|---|---|
| Keycloak | <https://keycloak.localhost:8443/admin> (`admin` / `admin`) | `ferrohealth-demo`: three users, one client per console and one per server that calls another |
| FerroEHR, four members | a viewer per member: A <http://localhost:3001>, B <http://localhost:3006>, C <http://localhost:3007>, D <http://localhost:3008> | A is an academic hospital with FerroEHR's sandbox dataset, B a GP practice, C a public health service with its laboratory, D an outpatient clinic; every patient has a year of vital signs and the member's own compositions |
| FerroPIX | <http://localhost:3002> | about 150 records from five hospitals, hospital E's over HL7 v2; a review queue at every grade, decided candidates, a kept and a reverted merge, the members' pseudonyms and a research registry |
| FerroFED | <http://localhost:3003> | the gateway over the four members and a suspended fifth, resolving patients through FerroPIX (PIXm and PDQm), with stored queries, an integrity incident and managed configuration revisions |
| FerroTERM | <http://localhost:3004> | ICD-10-CM from the CMS release, the HL7 Terminology package (2,541 value sets) and the HL7 v2-to-FHIR ConceptMaps (264 concept maps) |
| FerroBRIDGE | <http://localhost:3005> | the FHIR R4 facade over member A, with one Condition written through it |

Every port binds loopback only. `compose.yaml` lists them all.

## Start and stop

You need a container engine with compose (Docker, or Podman with
`docker-compose`), `curl`, `jq`, `openssl`, `git` and `nc`, and about 8 GB of memory
for the containers. Nothing is built locally; every image is pulled by its
release digest.

```sh
demo/up.sh     # about ten minutes on a first run, most of it pulling images and seeding
demo/down.sh   # stops everything and deletes its data
```

`up.sh` prints every URL when it is done. With Podman, point compose at its
socket first, for example
`DOCKER_HOST=unix:///var/run/docker.sock FERROHEALTH_DEMO_COMPOSE=docker-compose demo/up.sh`.

Keycloak serves HTTPS from a development CA that `up.sh` makes in
`demo/.work/tls/ca.crt`. The first time a console sends you to
`keycloak.localhost`, your browser warns about the certificate. Accept it for
the session, or trust the CA for as long as you keep it:

```sh
# macOS; remove it again in Keychain Access when you are done
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain demo/.work/tls/ca.crt
```

`down.sh` keeps the CA, so a browser that trusts it keeps trusting it.
`down.sh --purge` deletes it with everything else under `demo/.work/`.

## The users

| User | Password | Roles |
|---|---|---|
| `demo` | `demo` | everything: FerroEHR administrator, FerroPIX steward and administrator, operator of FerroFED and FerroBRIDGE, FerroTERM administrator |
| `steward` | `steward` | FerroEHR user and FerroPIX steward; FerroPIX's console shows no administration |
| `auditor` | `auditor` | FerroEHR read-only; the viewer refuses every write |

## Walkthrough

### 1. One patient, four hospitals (FerroFED)

Eva Visser (`ffd-test-0001`, BSN 900000016) has an EHR at all four members.
Each member knows her only by a pseudonym that FerroPIX minted for that member,
so no member holds her identifier or her BSN.

Open the FerroFED console at <http://localhost:3003>, sign in as `demo`, and
run this query on the query page:

```sql
SELECT c/uid/value AS uid
FROM EHR e CONTAINS COMPOSITION c
WHERE e/ehr_status/subject/external_ref/id/value = 'ffd-test-0001'
  AND e/ehr_status/subject/external_ref/namespace = 'urn:oid:2.999.1.1'
```

The gateway asks FerroPIX which `ehr_id` each member holds for her (ITI-83),
sends each member a query for that `ehr_id` alone, and merges the answers: her
vital signs and each member's own compositions, from all four members. Daan
Smit (`ffd-test-0002`) is at members B and D, Lotte Meijer (`ffd-test-0003`)
at member C, and Bram Mulder (`ffd-test-0004`) has no EHR anywhere.

Ask for her by BSN instead, with `'900000016'` and the namespace
`'urn:oid:2.16.840.1.113883.2.4.6.3'`: the gateway first asks FerroPIX's PDQm
which person the BSN names, then answers with the same rows.

The rest of the console:

- **Topology and services:** four members up, hospital E's member suspended
  (Off), and two identity services at FerroPIX, the PIXm cross-reference and
  PDQm demographics, both up because the seed asked each once.
- **Stored queries:** `org.ferrohealth.demo::patient_compositions` in two
  versions and `::composition_count`, each distributed to every member, beside
  the gateway's built-in EEHRxF queries. Run one from the query page with the
  parameter `patient` = `ffd-test-0001`.
- **Integrity:** one open incident. Members C and D both claim the EHR id
  `ee000000-0000-4000-8000-00000000c011`, which the gateway found when it was
  asked for that EHR; Clear resolves it.
- **Configuration:** the running configuration as revision 1, with its
  members, credentials and history.

### 2. The patient index (FerroPIX)

Open <http://localhost:3002> as `demo`. Five hospitals feed it: A to D over
FHIR (ITI-104) and hospital E over HL7 v2 (ITI-8, MLLP on port 2575). Search
for Visser, or for BSN 900000016: she is one person, linked across the four
hospitals because every record carries the same BSN.

- **Review queue:** candidate pairs that share no BSN, so only their
  demographics link them, at every grade: certain, probable and possible.
  Open one to see the evidence field by field, and link it or reject it.
- **Decided work:** two pairs were linked, two pairs of twins were marked not
  a match, two pairs are deferred, one merge is kept (a married name) and one
  is reverted. The audit trail shows each with its reason.
- **Sources and domains:** each hospital's FHIR client, hospital E's HL7 v2
  sender with its accepted and refused messages, and every identifier and
  pseudonymisation domain, a steward-only research registry among them.

Sign in as `steward` to see the same console without its administration pages.

### 3. Four kinds of care (FerroEHR viewers)

Each member has its own viewer, and each signs in through Keycloak as `demo`:

- **Member A** (<http://localhost:3001>), the academic hospital: FerroEHR's
  sandbox dataset with its templates, folders, parties and stored queries.
- **Member B** (<http://localhost:3006>), the GP practice: GP data sets and
  e-prescriptions.
- **Member C** (<http://localhost:3007>), public health and laboratory: lab
  results and infection reports.
- **Member D** (<http://localhost:3008>), the outpatient clinic: patient
  summaries and referrals.

Every patient has three vital-signs readings over 2026. Each member also
holds a stored query, `nl.hospital-<member>::vital_signs`, over its blood
pressures, and the Server pages show its health, metrics and build. Sign in
as `auditor` to see a member read-only.

### 4. Code systems (FerroTERM)

Open <http://localhost:3004> as `demo`. Browse ICD-10-CM's hierarchy, expand
any of the HL7 Terminology value sets, or translate an HL7 v2 table value
through the v2-to-FHIR ConceptMaps. The same operations answer without
signing in over the FHIR API:

```sh
curl -s 'http://localhost:8085/r4/CodeSystem/$lookup?system=http://hl7.org/fhir/sid/icd-10-cm&code=J30.2'
curl -s 'http://localhost:8085/r4/ConceptMap/$translate?url=http://hl7.org/fhir/uv/v2mappings/ConceptMap/table-hl70001-to-administrative-gender&system=http://terminology.hl7.org/CodeSystem/v2-0001&code=F'
```

### 5. FHIR over openEHR (FerroBRIDGE)

Open <http://localhost:3005> as `demo`. The console lists the loaded mapping
and the template it compiles against. `up.sh` wrote one Condition for Eva
Visser through the facade; FerroBRIDGE stored it at member A as an openEHR
composition, with the display of its verification status taken from
FerroTERM. Read it back with a token of the `demo-seed-fhir` client:

```sh
token=$(curl -s --cacert demo/.work/tls/ca.crt \
  -d grant_type=client_credentials -d client_id=demo-seed-fhir -d client_secret=demo-seed-fhir \
  https://keycloak.localhost:8443/realms/ferrohealth-demo/protocol/openid-connect/token | jq -r .access_token)
curl -s -H "Authorization: Bearer $token" http://localhost:8090/fhir/Condition/<id printed by up.sh>
```

## How the pieces trust each other

Each product checks Keycloak's tokens itself; none of them issues tokens. The
servers read the issuer at `https://keycloak.localhost:8443/realms/ferrohealth-demo`
and trust the development CA through their `ca_file` setting. The containers
reach that name through a network alias, and your browser resolves every
`*.localhost` name to loopback, so the issuer URL is the same on both sides.

The servers that call one another use client credentials: FerroFED to the
members and to FerroPIX, each member to FerroPIX for its pseudonyms, and
FerroBRIDGE to member A. Every client secret is `demo-` followed by the client
id, and is written in `keycloak/ferrohealth-demo-realm.json`.
