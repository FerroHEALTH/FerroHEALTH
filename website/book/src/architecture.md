# How the products fit together

Revised 2026-10-26.

The FerroHEALTH family is five products, each its own server, image and
repository, and each reaches the others only over a published protocol. No
product is a compile-time dependency of another. This page says who owns
what, which protocol each speaks, which shared libraries they are built from,
and what running them side by side involves. Each product's own book carries
its configuration and its pinned specification versions.

| Product | What it is | How the others reach it |
|---|---|---|
| FerroEHR | the openEHR Clinical Data Repository | openEHR ITS-REST and AQL |
| FerroBRIDGE | openEHR to HL7 FHIR (FHIRconnect) and to the OMOP Common Data Model (OMOCL), and clinical HL7 Version 2 messages mapped in through HL7's Version 2 to FHIR guide | it calls the CDR over ITS-REST; clients call its FHIR face and its MLLP listener |
| FerroFED | the federation gateway (the openEHR Federation Tier with AQL, EHDS cross-border exchange, MyHealth@EU) | it calls each CDR over ITS-REST; clients call its ITS-REST and FHIR faces |
| FerroPIX | the Master Patient Index (IHE PIX, PIXm, PDQ, PDQm, PMIR) | IHE PIXm, PDQm and PMIR, and the HL7 Version 2 identity feed and queries (ITI-8, ITI-9, ITI-21) over MLLP |
| FerroTERM | the HL7 FHIR terminology server | the FHIR terminology operations |

## Each product in its own lane

A product does one job and leaves the others' jobs to them:

- **FerroEHR implements no FHIR, OMOP, federation or IHE profile.** FHIR and
  OMOP are FerroBRIDGE's, federation is FerroFED's, and identity and the IHE
  profiles are FerroPIX's.
- **A product that needs another's function calls that server as a client**,
  over the other's protocol. FerroEHR validates codes at FerroTERM over the
  FHIR terminology API, and FerroFED asks FerroPIX who a patient is; neither
  carries a terminology or an identity service of its own.
- **Nothing is written twice.** What every product needs lives in a shared
  library, and the protocol clients and models live with the product that
  owns the protocol. When one lacks something, it is added in the repository
  that owns it and released, and no product keeps a local copy.
- **Every console is reactive.** A link, a form or an action in an operator
  console never reloads the whole page; WebAssembly is the normal path, and
  the page without it is only the fallback.

FerroFORMS, an openEHR form builder and renderer at
<https://ferroforms.eu/>, is paused. It is still drawn and listed, as a client
of the CDR and of the terminology server.

[![What calls what across the FerroHEALTH family](../assets/diagrams/ferrohealth-architecture.svg)](../assets/diagrams/ferrohealth-architecture.svg)

The diagram is one file, shared with the family site and drawn by a generator
in the FerroHEALTH repository. Select it to open it at full size.

## Reading the diagram

The frame is one FerroHEALTH instance serving one organisation. The six
inside are the products; clinicians, applications, HL7 FHIR, HL7 Version 2
senders, the OMOP database and other organisations sit outside it. A dashed
outline is a server not running yet (FerroPIX's server is being built), and a
dashed line is a call into one. The band under the frame holds
the shared libraries, which run inside the products and take no call.

Left to right is the order data moves. The top row is the data path:
FerroFORMS takes the record down, FerroEHR keeps it, FerroTERM gives its codes
meaning, and FerroBRIDGE carries it out and brings HL7 Version 2 messages in.
FerroPIX and FerroFED frame that path. An arrowhead
points at what is called or written to, and each edge names the
specification it speaks.

## Which product calls which

| Caller | Calls | Over | What for |
|---|---|---|---|
| FerroFORMS (paused) | FerroTERM | the FHIR terminology API, `$expand` | the codes a coded field admits |
| FerroFORMS (paused) | FerroEHR | the openEHR REST API | committing the compositions a form produces |
| Any application | FerroEHR | the openEHR REST API and AQL | reading and writing the record directly |
| FerroEHR | FerroTERM | the FHIR terminology API, `$validate-code` | validating a coded value at commit time, as a client |
| FerroBRIDGE | FerroEHR | the openEHR REST API | reading the record it carries out, and committing what it maps in |
| FerroBRIDGE | FerroTERM | the FHIR terminology API, `$lookup` and `$translate` | resolving a display and translating a code |
| HL7 FHIR clients | FerroBRIDGE | its FHIR face, both ways | reading openEHR out as FHIR, and writing FHIR back in |
| HL7 Version 2 senders | FerroBRIDGE | its MLLP listener | clinical HL7 Version 2 messages, mapped through HL7's Version 2 to FHIR guide and committed to the CDR |
| FerroBRIDGE | an OMOP Common Data Model database | SQL | a batch load of typed rows, for research |
| Applications | FerroFED | its ITS-REST and FHIR faces | one query answered from every node of a federation |
| FerroFED | FerroPIX | IHE PIXm | who the patient is and where the records are, before it dispatches a query |
| FerroFED | FerroEHR and other organisations' openEHR CDRs | the openEHR REST API and AQL | each node's part of the answer, merged with the node named |

These calls come once the server behind them runs:

- **FerroPIX** is the Master Patient Index, and identity and the IHE identity
  profiles are its job alone. It answers IHE PIXm, PDQm and PMIR, and the
  HL7 Version 2 identity feed and queries (ITI-8, ITI-9, ITI-21) over MLLP.
  FerroFED asks it where a patient's records are (PIXm) before it dispatches a query, and
  keeps no identity service of its own. FerroEHR is to look the subject of an
  EHR up there as a client (PIXm and PDQm), so the subject an EHR_STATUS
  carries can be the pseudonym FerroPIX mints. FerroPIX publishes the crates
  of the identity specifications, `ihe-iti` and `nl-generic-functions`, the
  Dutch Generic Functions, for every product to use.

Every call in the table speaks a published specification, so any product can
be swapped for another implementation of the same standard: FerroTERM for any
FHIR terminology server, FerroEHR for any openEHR CDR, and so on.

## The shared libraries

What every product would otherwise write for itself lives in four shared
libraries. Each is a set of Rust crates on crates.io, released from its own
repository under the Business Source License 1.1, and compiled into the
products that use it. A shared library carries cross-cutting work and never a
product's domain. None of them is a product: none runs as a process, and
nothing calls one over the network, so the diagram draws them as a band
outside the instance with no edges.

| Library | Crates | What it does | Who uses it |
|---|---|---|---|
| [FerroAUTH](https://github.com/FerroHEALTH/FerroAUTH) | `ferrohealth-smart`, `ferrohealth-authz` | Authentication and the policy decision. `ferrohealth-smart` is the SMART App Launch, SMART on openEHR and OAuth 2.0 resource server: token validation against the authorization server's keys, the authenticated subject with its scopes and roles, the patient compartment, machine authentication, and one audit line per request. It checks tokens and never issues one. `ferrohealth-authz` makes the policy decision (ABAC, Cedar, a remote PDP), with its first usable release in preparation. The repository was renamed from FerroSMART on 2026-10-25, and the crate names stay. | FerroEHR, FerroTERM, FerroBRIDGE, FerroFED and FerroPIX |
| [FerroAUDIT](https://github.com/FerroHEALTH/FerroAUDIT) | `ihe-atna`, `ehds-logging` | The whole audit trail: the IHE ATNA Record Audit Event (ITI-20) and the Basic Audit Log Patterns (BALP), with sending, the store-and-forward spool ITI-20 asks of a sender, forwarding and retrieving; and the record of each access to electronic health data that Regulation (EU) 2025/327 asks of an EHR system | FerroEHR, FerroFED and FerroPIX |
| [FerroUI](https://github.com/FerroHEALTH/FerroUI) | `ferrohealth-ui` | The one source for the user interface of every operator console: the components, the stylesheet with a theme per product, and the design. Every console built on it is reactive, so an action never reloads the whole page. Each console moves onto a new release in one rollout with the others, as [its console guide](https://github.com/FerroHEALTH/FerroUI/blob/main/docs/consoles.md) describes | the consoles of FerroEHR, FerroTERM, FerroBRIDGE and FerroFED |
| [FerroSYS](https://github.com/FerroHEALTH/FerroSYS) | `ferrohealth-secret`, `ferrohealth-config`, `ferrohealth-telemetry`, `ferrohealth-health`, `ferrohealth-server`, `ferrohealth-usage-report` | The system plumbing every product shares: secrets and redaction, configuration, logging and OpenTelemetry, health, the HTTP stack and its drain, and the usage report. It is a set of crates like FerroAUTH and FerroAUDIT, never a control plane or a central service, and it is being built, with no release yet. | the products, as each crate is released |

The protocol clients and models stay with the product that owns the
protocol, and every other product uses them from there:

| Crates | Published by | What they are |
|---|---|---|
| `fhir-types`, `ferrobridge-term` | FerroBRIDGE | the generated HL7 FHIR model, and the FHIR terminology client |
| `ihe-iti`, `nl-generic-functions` | FerroPIX | the IHE identity profiles, and the Dutch Generic Functions |
| the `openehr-*` crates | FerroEHR | the openEHR models and the ITS-REST client |

The release of each library is on its card on the
[family site](https://ferrohealth.eu/#libraries), read from its repository.

## Running them side by side

No product needs another to start. A deployment runs the ones it needs, each
as its own process or container, and points each caller at the others through
its configuration:

| Product | Where its book describes deploying it |
|---|---|
| FerroFORMS (paused) | [The renderer](https://ferroforms.eu/docs/operate/renderer.html) |
| FerroEHR | [Installation](https://ferroehr.eu/docs/latest/installation/index.html) |
| FerroTERM | [Installing](https://ferroterm.eu/docs/operate/install.html) |
| FerroBRIDGE | [What FerroBRIDGE runs beside](https://ferrobridge.eu/docs/operate/deployment-shape.html) |
| FerroFED | [The container](https://ferrofed.eu/docs/operate/container.html) |

Five rules hold across the family:

- **One instance per organisation.** FerroEHR is single-tenant: several
  organisations are served by several instances, each with its own database.
  The diagram's frame is one such instance.
- **The record lives in the CDR.** FerroEHR holds the record. FerroBRIDGE's
  FHIR face stores nothing, and its OMOP load writes into a database outside
  it. FerroFED holds no clinical data of its own: it passes each node's answer
  through.
- **The products meet over published specifications.** Every edge in the
  diagram is one. FerroEHR and FerroBRIDGE meet only over the openEHR REST
  API, which is what lets them form one EHR system under the EHDS while
  staying independent of each other
  ([intended purpose](ehds/intended-purpose.md)).
- **Each product authorises its own callers.** Every product is its own
  SMART App Launch 2.x resource server: it checks the access tokens it is
  handed against the deployment's own authorization server, through
  FerroAUTH's `ferrohealth-smart` in its own process. The family runs no central
  authorisation service, because one would hold the signing key every
  product's access depends on.
- **Audit is written once.** FerroAUDIT is the family's audit
  implementation, sending to an Audit Record Repository the deployment runs.
  FerroEHR, FerroFED and FerroPIX write their audit trails through it, and
  FerroEHR and FerroFED their EHDS access records.
