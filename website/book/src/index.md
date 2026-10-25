# FerroHEALTH documentation

Revised 2026-10-25.

This book holds what is true for every FerroHEALTH product: who makes them,
how a vulnerability or a complaint reaches the manufacturer, what the
manufacturer does under the Cyber Resilience Act (CRA) and the European Health
Data Space Regulation (EHDS), the licence terms, and how the products fit
together. Cadasto B.V. is the manufacturer of every product in the family and
publishes this book.

Each product documents itself in its own book. A product's book keeps what is
about that product (its installation, its configuration, its API, its risk
assessment) and links this book for the rest, so the family-level text exists
once.

## The products

The family is five products, each its own server and repository, reaching
the others only over published protocols.
[How the products fit together](architecture.md) says who owns what.

| Product | What it does | Its documentation | Repository |
|---|---|---|---|
| FerroEHR | The openEHR Clinical Data Repository, over openEHR ITS-REST and AQL | <https://ferroehr.eu/docs/latest/> | [FerroHEALTH/FerroEHR](https://github.com/FerroHEALTH/FerroEHR) |
| FerroBRIDGE | openEHR to HL7 FHIR and to the OMOP Common Data Model, and clinical HL7 Version 2 messages mapped in | <https://ferrobridge.eu/docs/> | [FerroHEALTH/FerroBRIDGE](https://github.com/FerroHEALTH/FerroBRIDGE) |
| FerroFED | The federation gateway | <https://ferrofed.eu/docs/> | [FerroHEALTH/FerroFED](https://github.com/FerroHEALTH/FerroFED) |
| FerroPIX | The Master Patient Index, with the IHE identity profiles; it publishes its identity crates, and the server is being built | <https://ferropix.eu/docs/> | [FerroHEALTH/FerroPIX](https://github.com/FerroHEALTH/FerroPIX) |
| FerroTERM | The HL7 FHIR terminology server | <https://ferroterm.eu/docs/> | [FerroHEALTH/FerroTERM](https://github.com/FerroHEALTH/FerroTERM) |

FerroFORMS, an openEHR form builder and renderer, is paused. Its
documentation stays at <https://ferroforms.eu/docs/> and its repository at
[FerroHEALTH/FerroFORMS](https://github.com/FerroHEALTH/FerroFORMS).

Two more are planned. Each has a repository that holds its licence and its
brand, and neither has a release or a book yet:

| Planned | What it is for | Repository |
|---|---|---|
| FerroSYS | The control plane | [FerroHEALTH/FerroSYS](https://github.com/FerroHEALTH/FerroSYS) |
| FerroTASK | Task planning and decision support over openEHR | [FerroHEALTH/FerroTASK](https://github.com/FerroHEALTH/FerroTASK) |

The family site, <https://ferrohealth.eu/>, shows what each product has
released and when its code last moved.

## The shared libraries

The products are built from three shared libraries. Each is a set of Rust
crates on crates.io, released from its own repository under the Business
Source License 1.1. None of them is a product: none runs on its own, and each
is compiled into the products that use it. They carry the work every product
shares, never a product's domain.

| Library | Crates | What it does | Repository |
|---|---|---|---|
| FerroAUTH | `ferrohealth-smart`, `ferrohealth-authz` | Authentication, through the SMART App Launch, SMART on openEHR and OAuth 2.0 resource server that checks the access tokens a product is handed against the deployment's authorization server and issues none; and the policy decision, with the first usable release of `ferrohealth-authz` in preparation. Renamed from FerroSMART on 2026-10-25 | [FerroHEALTH/FerroAUTH](https://github.com/FerroHEALTH/FerroAUTH) |
| FerroAUDIT | `ihe-atna`, `ehds-logging` | The whole IHE ATNA and BALP audit trail, and the record of each access to electronic health data that the EHDS Regulation asks of an EHR system | [FerroHEALTH/FerroAUDIT](https://github.com/FerroHEALTH/FerroAUDIT) |
| FerroUI | `ferrohealth-ui` | The one source for the user interface of every operator console, each of them reactive ([the console guide](https://github.com/FerroHEALTH/FerroUI/blob/main/docs/consoles.md)) | [FerroHEALTH/FerroUI](https://github.com/FerroHEALTH/FerroUI) |

[How the products fit together](architecture.md#the-shared-libraries) says
which product uses which.

## What is in this book

- **[The manufacturer](manufacturer.md):** Cadasto B.V., its address and its
  single point of contact.
- **[Security](security.md):** how to report a vulnerability, coordinated
  disclosure, security advisories, the support period and how you hear of an
  update.
- **[Post-market](post-market.md):** complaints, serious incidents, corrective
  action and withdrawal, cooperation with the authorities, and what happens if
  the manufacturer ceases operations.
- **[The Cyber Resilience Act](cra.md):** the manufacturer's side of the CRA,
  the conformity route of each product and the questions for counsel.
- **The EHDS EHR system:** the
  [intended purpose](ehds/intended-purpose.md) and the
  [shared responsibility](ehds/shared-responsibility.md) of the EHR system
  that FerroEHR and FerroBRIDGE form together.
- **[Licensing and trademarks](licensing.md):** the Business Source License
  1.1 terms every product carries, commercial licences, the brand terms and the
  terms for contributions.
- **[How the products fit together](architecture.md):** which product calls
  which, and running them side by side.
- **[Revisions](revisions.md):** the dated record of every change to these
  pages.

## Which revision a release relies on

Every page carries the date it was last revised, and the
[revisions](revisions.md) page lists each change with its date. A product
release that relies on a page here names it with that date, for example "the
FerroHEALTH security policy, revised 2026-10-08". The text of every revision
stays in the history of the
[FerroHEALTH repository](https://github.com/FerroHEALTH/FerroHEALTH/commits/main/website/book/src).

## What belongs here

A page belongs in this book when it is about the family or about Cadasto B.V.
as manufacturer, and its text holds for every product it names. A fact about
one product belongs in that product's book, and this book links it. A new
product links these pages from its own book and its repository; it does not
copy them.

> [!NOTE]
> These pages are not legal advice. They say what Cadasto B.V. does as
> manufacturer and Licensor, and they do not say that a product or a
> deployment meets any regulation.
