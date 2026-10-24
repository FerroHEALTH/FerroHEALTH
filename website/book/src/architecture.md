# How the products fit together

Revised 2026-10-24.

Each FerroHEALTH product runs on its own, and each speaks a published
specification to the others. This page shows which product calls which, and
what running them side by side involves, and which shared libraries they are
built from. Each product's own book carries its configuration and its pinned
specification versions.

[![What calls what across the FerroHEALTH family](../assets/diagrams/ferrohealth-architecture.svg)](../assets/diagrams/ferrohealth-architecture.svg)

The diagram is one file, shared with the family site and drawn by a generator
in the FerroHEALTH repository. Select it to open it at full size.

## Reading the diagram

The frame is one FerroHEALTH instance serving one organisation. The eight
inside are the products; clinicians, applications, HL7 FHIR, the OMOP database
and other organisations sit outside it. A dashed outline is a server not
running yet (FerroSYS and FerroTASK are planned, and FerroPIX's server is being
built), and a dashed line is a call into one. The band under the frame holds
the shared libraries, which run inside the products and take no call.

Left to right is the order data moves. Four servers are the data path:
FerroFORMS takes the record down, FerroEHR keeps it, FerroTERM gives its codes
meaning, and FerroBRIDGE carries it out. FerroPIX, FerroFED,
FerroSYS and FerroTASK frame that path. An arrowhead points at what is called
or written to, and each edge names the specification it speaks.

## Which product calls which

| Caller | Calls | Over | What for |
|---|---|---|---|
| FerroFORMS | FerroTERM | the FHIR terminology API, `$expand` | the codes a coded field admits |
| FerroFORMS | FerroEHR | the openEHR REST API | committing the compositions a form produces |
| Any application | FerroEHR | the openEHR REST API | reading and writing the record directly |
| FerroEHR | FerroTERM | the FHIR terminology API, `$validate-code` | validating a coded value at commit time |
| FerroBRIDGE | FerroEHR | the openEHR REST API | reading the record it carries out |
| FerroBRIDGE | FerroTERM | the FHIR terminology API, `$lookup` and `$translate` | resolving a display and translating a code |
| FerroBRIDGE | HL7 FHIR clients | its FHIR facade, both ways | reading openEHR out as FHIR, and writing FHIR back in |
| FerroBRIDGE | an OMOP Common Data Model database | SQL | a batch load of typed rows, for research |
| Applications | FerroFED | the openEHR REST API and AQL | one query answered from every node of a federation |
| FerroFED | FerroEHR and other organisations' openEHR CDRs | the openEHR REST API and AQL | each node's part of the answer, merged with the node named |

These calls come once the servers behind them run:

- **FerroPIX** is the Master Patient Index. FerroEHR resolves the subject of
  each EHR through it (PIXm, ITI-83, and PDQm, ITI-78) and feeds it each EHR
  it creates or whose subject changes (the Patient Identity Feed FHIR,
  ITI-104). The subject an EHR's EHR_STATUS carries is then the pseudonym
  FerroPIX mints, so the record holds no directly identifying identifier.
  FerroFED asks it where a patient's records are (PIXm) before it dispatches
  a query. FerroPIX also owns the crates of the IHE identity profiles,
  `ihe-iti` (PIXm, PDQm, PMIR, mCSD, XCPD and IUA, a feature each), and
  `nl-generic-functions`, the Dutch Generic Functions, which moved to it from
  FerroFED and which it publishes from its own repository.
- **FerroTASK** reads FerroEHR over the openEHR REST API and AQL for task
  plans and GDL2 guidelines, and commits the state of each plan back.
- **FerroSYS** is the control plane. Every server reports health, telemetry
  and events to it and is configured from it, so it is drawn as a band under
  everything.

Every call in the table speaks a published specification, so any product can
be swapped for another implementation of the same standard: FerroTERM for any
FHIR terminology server, FerroEHR for any openEHR CDR, and so on.

## The shared libraries

What every product would otherwise write for itself lives in three shared
libraries. Each is a set of Rust crates on crates.io, released from its own
repository under the Business Source License 1.1, and compiled into the
products that use it. None of them is a product: none runs as a process, and
nothing calls one over the network, so the diagram draws them as a band
outside the instance with no edges.

| Library | Crates | What it does | Who uses it |
|---|---|---|---|
| [FerroSMART](https://github.com/FerroHEALTH/FerroSMART) | `ferrohealth-smart` | The SMART App Launch, SMART on openEHR and OAuth 2.0 resource server: token validation against the authorization server's keys, the SMART scopes and the patient compartment, machine authentication, and one audit line per request. It checks tokens and never issues one. | FerroEHR, FerroTERM, FerroBRIDGE, FerroFED and FerroPIX |
| [FerroAUDIT](https://github.com/FerroHEALTH/FerroAUDIT) | `ihe-atna`, `ehds-logging` | The IHE ATNA Record Audit Event (ITI-20) and the Basic Audit Log Patterns (BALP), with the store-and-forward spool ITI-20 asks of a sender, and the record of each access to electronic health data that Regulation (EU) 2025/327 asks of an EHR system | FerroEHR, FerroFED and FerroPIX, and FerroSYS plans to build the receiving Audit Record Repository on it |
| [FerroUI](https://github.com/FerroHEALTH/FerroUI) | `ferrohealth-ui` | The one source for the user interface of every operator console: the components, the stylesheet with a theme per product, and the design; each console moves onto a new release in one rollout with the others, as [its console guide](https://github.com/FerroHEALTH/FerroUI/blob/main/docs/consoles.md) describes | the consoles of FerroEHR, FerroTERM, FerroBRIDGE and FerroFED |

The release of each library is on its card on the
[family site](https://ferrohealth.eu/#libraries), read from its repository.

## Running them side by side

No product needs another to start. A deployment runs the ones it needs, each
as its own process or container, and points each caller at the others through
its configuration:

| Product | Where its book describes deploying it |
|---|---|
| FerroFORMS | [The renderer](https://ferroforms.eu/docs/operate/renderer.html) |
| FerroEHR | [Installation](https://ferroehr.eu/docs/latest/installation/index.html) |
| FerroTERM | [Installing](https://ferroterm.eu/docs/operate/install.html) |
| FerroBRIDGE | [What FerroBRIDGE runs beside](https://ferrobridge.eu/docs/operate/deployment-shape.html) |
| FerroFED | [The container](https://ferrofed.eu/docs/operate/container.html) |

Five rules hold across the family:

- **One instance per organisation.** FerroEHR is single-tenant: several
  organisations are served by several instances, each with its own database.
  The diagram's frame is one such instance.
- **The record lives in the CDR.** FerroEHR holds the record. FerroBRIDGE's
  FHIR facade stores nothing, and its OMOP load writes into a database outside
  it. FerroFED holds no clinical data of its own: it passes each node's answer
  through.
- **The products meet over published specifications.** Every edge in the
  diagram is one. FerroEHR and FerroBRIDGE meet only over the openEHR REST
  API, which is what lets them form one EHR system under the EHDS while
  staying independent of each other
  ([intended purpose](ehds/intended-purpose.md)).
- **Each product authorises its own callers.** Every product is its own
  SMART App Launch 2.x resource server: it checks the access tokens it is
  handed against the deployment's own authorization server, through the
  FerroSMART library in its own process. The family runs no central
  authorisation service, because one would hold the signing key every
  product's access depends on.
- **Audit is written once.** FerroAUDIT is the family's audit
  implementation, sending to an Audit Record Repository the deployment runs.
  FerroEHR, FerroFED and FerroPIX write their audit trails through it, and
  FerroEHR and FerroFED their EHDS access records.
