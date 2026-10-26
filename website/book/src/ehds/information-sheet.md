# The EHDS EHR system: information sheet

Revised 2026-10-26.

This is the information sheet of the EHR system that FerroEHR and FerroBRIDGE
form together. A copy accompanies each release of either product, free of
charge for the user, as the EHDS (Regulation (EU) 2025/327) asks: each EHR
system is "accompanied, free of charge for the user, by the information sheet
provided for in Article 38 and clear and complete instructions for use"
(Art. 30(1)(d)). Article 38(1) asks for "concise, complete, correct and clear
information that is relevant, accessible and comprehensible to professional
users", and Article 38(2) lists what the sheet specifies. Each section below
is one point of that list. The
[instructions for use](instructions-for-use.md) accompany it.

<!-- toc -->

> [!NOTE]
> This page holds what stays true from one release to the next. The copy a
> release carries is cut from the revision of this page that the release
> pins, and the release lane appends that release's own facts under the
> heading "This copy": the version of each product, the release date and the
> version of each standard in the table under (e). Read the copy of the
> release you run. The quotations are from the Official Journal text of the
> [EHDS](https://eur-lex.europa.eu/eli/reg/2025/327/oj). No conformity
> assessment has been carried out and no EU declaration of conformity exists;
> nothing on this sheet says that the EHR system meets the Regulation.

## (a) The manufacturer

EHDS Art. 38(2)(a): "the identity, registered trade name or registered
trademark, and contact details of the manufacturer and, where applicable, of
its authorised representative".

| | |
|---|---|
| Manufacturer | Cadasto B.V. |
| Postal address | Comeniusstraat 2d, 1817 MS Alkmaar, The Netherlands |
| Single point of contact | [info@cadasto.com](mailto:info@cadasto.com) |
| Website | <https://www.cadasto.com/contact/> |
| Authorised representative | none: Cadasto B.V. is established in the Union |
| Vulnerability reports | each product's `SECURITY.md`, or info@cadasto.com ([security](../security.md)) |
| Complaints and serious incidents | info@cadasto.com ([post-market](../post-market.md)) |

Cadasto B.V. is the manufacturer of both products and of every other
FerroHEALTH product ([the manufacturer](../manufacturer.md)).

## (b) Name, version and release date

EHDS Art. 38(2)(b): "the name and version of the EHR system and date of its
release".

- **Name:** FerroEHR with FerroBRIDGE, the EHR system Cadasto B.V. declares.
  FerroEHR, the openEHR Clinical Data Repository, ships the European logging
  software component. FerroBRIDGE, the bridge from openEHR to HL7 FHIR and to
  the OMOP Common Data Model, ships the European interoperability software
  component. The two are separate products on their own release lines and
  meet only over the openEHR REST API
  ([how the products fit together](../architecture.md)).
- **Version:** the release of the product this copy accompanies, with the
  oldest release of the other product it is tested against. A copy attached
  to a FerroEHR release names that FerroEHR release and the oldest FerroBRIDGE
  release FerroEHR is tested against; a copy attached to a FerroBRIDGE release
  names it the other way round. "This copy" at the end of the copy states both.
- **Release date:** the date of the release this copy accompanies, as its
  product's changelog heads that release. "This copy" states it.
- **Support period:** only the newest release of each product is supported.
  Cadasto B.V. commits to keep publishing security fixes for at least five
  years after each release and ships them only in the newest release
  ([security](../security.md), [the Cyber Resilience Act](../cra.md)). The end
  month of that commitment is in the notes of each release.

## (c) Intended purpose

EHDS Art. 38(2)(c): "the intended purpose of the EHR system".

The EHR system stores, versions and queries the structured health records of
one healthcare provider, records every access to them, and exchanges them
with other systems in HL7 FHIR and, for research and analytics, as rows of
the OMOP Common Data Model. FerroEHR holds the records and serves them through
the openEHR REST API and AQL to the software the provider's health
professionals and patients use, and records every access in its access log.
FerroBRIDGE reads and writes FerroEHR over that API and maps the records to
FHIR and to the OMOP Common Data Model, driven by mapping specifications the
deployment loads. Neither product has a clinical user interface, and the
system is not intended for any medical device purpose. Each product runs one
instance per organisation.

The full statement, with the users and what the intended purpose excludes, is
the [intended purpose](intended-purpose.md). Each product's book carries its
own part of it.

## (d) The categories of electronic health data

EHDS Art. 38(2)(d): "the categories of electronic health data that the EHR
system has been designed to process".

- **Clinical content:** the priority categories of EHDS Art. 14(1), "(a)
  patient summaries; (b) electronic prescriptions; (c) electronic
  dispensations; (d) medical imaging studies and related imaging reports; (e)
  medical test results, including laboratory and other diagnostic results and
  related reports; and (f) discharge reports", and any category a Member State
  adds in national law, as far as the operational templates the deploying
  organisation loads describe them. FerroEHR stores this content. Imaging
  studies are held as attachments or as references to an imaging archive;
  neither product implements DICOM image transfer. FerroBRIDGE maps the same
  content to FHIR resources and to OMOP Common Data Model rows as it passes,
  and the readiness record names which category has a mapping today
  ([readiness](readiness.md)).
- **Identities:** FerroEHR holds persons, organisations and roles, and their
  identifiers, in a separate demographic domain, and the link between a record
  and its subject in a separate linkage domain. FerroBRIDGE keeps the
  correspondence between the FHIR identifiers it serves and the openEHR
  identifiers they stand for.
- **The access log:** FerroEHR records who accessed which record, when, from
  which origin and in which priority category, naming health professionals
  and patients.

## (e) Standards, formats and specifications

EHDS Art. 38(2)(e): "the standards, formats and specifications supported by
the EHR system and versions of those standards, formats and specifications".

The table names each standard and the product that supports it. The versions
move with each release, so the release lane of each product appends the
versions of its own release under "This copy", read from the pins of that
release.

| Standard or specification | Product | Used for |
|---|---|---|
| openEHR Reference Model, BASE and Terminology | FerroEHR | the record content |
| openEHR Archetype Model, ADL and operational templates | FerroEHR | archetypes and templates |
| openEHR ITS-REST | FerroEHR serves it, FerroBRIDGE calls it | the REST API between the two products and to clinical applications |
| openEHR Archetype Query Language (AQL) | FerroEHR serves it, FerroBRIDGE sends it | queries |
| openEHR canonical JSON and XML, and the simplified formats | FerroEHR | serialisation and data entry |
| IHE ATNA (ITI-19, ITI-20, ITI-81) and the IHE Basic Audit Log Patterns | FerroEHR | the access log |
| DICOM PS3.15 audit message | FerroEHR | the access log over syslog |
| HL7 FHIR `AuditEvent` | FerroEHR | the access log as FHIR |
| Syslog over TLS (RFC 5424, RFC 5425) | FerroEHR | the access-log feed |
| HL7 FHIR RESTful API and resources | FerroBRIDGE | the FHIR face of the records |
| FHIRconnect | FerroBRIDGE | the mappings between openEHR and FHIR |
| OMOP Common Data Model and OMOCL | FerroBRIDGE | the mappings to research and analytics tables |
| HL7 Version 2 messages over MLLP | FerroBRIDGE | clinical messages mapped in |
| HL7 FHIR terminology operations | both | codes and value sets, against the deployment's terminology server |
| OAuth 2.0, JWT, OpenID Connect and SMART App Launch | both | authentication and authorisation of callers |
| TLS | both | transport security |
| PostgreSQL | both | the databases the deployment provides |

The European electronic health record exchange format of EHDS Art. 15 has not
been adopted; when it is, FerroBRIDGE carries it. Each product measures its
conformance to the specifications it implements and publishes the record in
its own book; those records measure the specifications, not the EHDS.

## This copy

The release lane appends this section to the copy it attaches: the product
and release the copy accompanies, its release date, the oldest release of the
other product it is tested against, and the version of each standard above
for that release. This page in the book carries no such facts.
