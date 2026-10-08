# How the products fit together

Revised 2026-10-08.

Each FerroHEALTH product runs on its own, and each speaks a published
specification to the others. This page shows which product calls which, and
what running them side by side involves. Each product's own book carries its
configuration and its pinned specification versions.

[![What calls what across the FerroHEALTH family](../assets/diagrams/ferrohealth-architecture.svg)](../assets/diagrams/ferrohealth-architecture.svg)

The diagram is one file, shared with the family site and drawn by a generator
in the FerroHEALTH repository. Select it to open it at full size.

## Reading the diagram

The frame is one FerroHEALTH instance serving one organisation. The nine
inside are the family; clinicians, applications, HL7 FHIR, the OMOP database
and other organisations sit outside it. A dashed outline is a planned product,
and a dashed line is a call into one.

Left to right is the order data moves. Four servers are the data path:
FerroCHART takes the record down, FerroEHR keeps it, FerroTERM gives its codes
meaning, and FerroBRIDGE carries it out. FerroPIX, FerroSMART, FerroFED,
FerroSYS and FerroTASK frame that path. An arrowhead points at what is called
or written to, and each edge names the specification it speaks.

## Which product calls which

| Caller | Calls | Over | What for |
|---|---|---|---|
| FerroCHART | FerroTERM | the FHIR terminology API, `$expand` | the codes a coded field admits |
| FerroCHART | FerroEHR | the openEHR REST API | committing the compositions a form produces |
| Any application | FerroEHR | the openEHR REST API | reading and writing the record directly |
| FerroEHR | FerroTERM | the FHIR terminology API, `$validate-code` | validating a coded value at commit time |
| FerroBRIDGE | FerroEHR | the openEHR REST API | reading the record it carries out |
| FerroBRIDGE | FerroTERM | the FHIR terminology API, `$lookup` and `$translate` | resolving a display and translating a code |
| FerroBRIDGE | HL7 FHIR clients | its FHIR facade, both ways | reading openEHR out as FHIR, and writing FHIR back in |
| FerroBRIDGE | an OMOP Common Data Model database | SQL | a batch load of typed rows, for research |
| Applications | FerroFED | the openEHR REST API and AQL | one query answered from every node of a federation |
| FerroFED | FerroEHR and other organisations' openEHR CDRs | the openEHR REST API and AQL | each node's part of the answer, merged with the node named |

The planned products add these calls once they exist:

- **FerroSMART** is the SMART on openEHR authorisation server. FerroCHART
  obtains its token and launch context there (OIDC, SMART launch), and
  FerroEHR asks it whether a token may do what it asks (token
  introspection). FerroEHR carries the SMART on openEHR layer itself today.
- **FerroPIX** is the Master Patient Index. FerroEHR feeds it each EHR it
  creates (the IHE PIXm Patient Identity Feed), and FerroFED asks it where a
  patient's records are (PIXm) before it dispatches a query.
- **FerroTASK** reads FerroEHR over the openEHR REST API and AQL for task
  plans and GDL2 guidelines, and commits the state of each plan back.
- **FerroSYS** is the control plane. Every server reports health, telemetry
  and events to it and is configured from it, so it is drawn as a band under
  everything.

Every call in the table speaks a published specification, so any product can
be swapped for another implementation of the same standard: FerroTERM for any
FHIR terminology server, FerroEHR for any openEHR CDR, and so on.

## Running them side by side

No product needs another to start. A deployment runs the ones it needs, each
as its own process or container, and points each caller at the others through
its configuration:

| Product | Where its book describes deploying it |
|---|---|
| FerroCHART | [The renderer](https://ferrochart.eu/docs/operate/renderer.html) |
| FerroEHR | [Installation](https://ferroehr.eu/docs/latest/installation/index.html) |
| FerroTERM | [Installing](https://ferroterm.eu/docs/operate/install.html) |
| FerroBRIDGE | [What FerroBRIDGE runs beside](https://ferrobridge.eu/docs/operate/deployment-shape.html) |
| FerroFED | [The container](https://ferrofed.eu/docs/operate/container.html) |

Three rules hold across the family:

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
