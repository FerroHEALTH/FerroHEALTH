# FerroHEALTH documentation

Revised 2026-10-08.

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

| Product | What it does | Its documentation | Repository |
|---|---|---|---|
| FerroCHART | An openEHR form builder and renderer | <https://ferrochart.eu/docs/> | [FerroHEALTH/FerroCHART](https://github.com/FerroHEALTH/FerroCHART) |
| FerroEHR | An openEHR Clinical Data Repository | <https://ferroehr.eu/docs/latest/> | [FerroHEALTH/FerroEHR](https://github.com/FerroHEALTH/FerroEHR) |
| FerroTERM | An HL7 FHIR terminology server | <https://ferroterm.eu/docs/> | [FerroHEALTH/FerroTERM](https://github.com/FerroHEALTH/FerroTERM) |
| FerroBRIDGE | A bridge from openEHR to FHIR and to the OMOP Common Data Model | <https://ferrobridge.eu/docs/> | [FerroHEALTH/FerroBRIDGE](https://github.com/FerroHEALTH/FerroBRIDGE) |
| FerroFED | An openEHR federation gateway | <https://ferrofed.eu/docs/> | [FerroHEALTH/FerroFED](https://github.com/FerroHEALTH/FerroFED) |

Four more are planned. Each has a repository that holds its licence and its
brand, and none has a release or a book yet:

| Planned | What it is for | Repository |
|---|---|---|
| FerroPIX | Patient identity: a Master Patient Index | [FerroHEALTH/FerroPIX](https://github.com/FerroHEALTH/FerroPIX) |
| FerroSMART | The SMART on openEHR authorisation server | [FerroHEALTH/FerroSMART](https://github.com/FerroHEALTH/FerroSMART) |
| FerroSYS | The control plane | [FerroHEALTH/FerroSYS](https://github.com/FerroHEALTH/FerroSYS) |
| FerroTASK | Task planning and decision support over openEHR | [FerroHEALTH/FerroTASK](https://github.com/FerroHEALTH/FerroTASK) |

The family site, <https://ferrohealth.eu/>, shows what each product has
released and when its code last moved.

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
