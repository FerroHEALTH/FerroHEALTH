# The EHDS EHR system: intended purpose

Revised 2026-10-08.

This page is the statement by Cadasto B.V., the manufacturer, of the use it
intends the EHR system that FerroEHR and FerroBRIDGE form together for: what
the system is for, who uses it, which data it is designed to process, how it
is operated, and what the intended purpose excludes. Each product's book
carries its own part of the statement: its essential functions, the data it
holds, the environment it relies on, and the use and misuse that can be
foreseen for it.

Two regulations measure the system against this statement. The Cyber
Resilience Act (CRA, Regulation (EU) 2024/2847) defines the intended purpose
as "the use for which a product with digital elements is intended by the
manufacturer, including the specific context and conditions of use, as
specified in the information supplied by the manufacturer in the instructions
for use, promotional or sales materials and statements, as well as in the
technical documentation" (CRA Art. 3(23)), and asks for it "including the
security environment provided by the manufacturer" in the information that
accompanies the product (Annex II point 4). The EHDS (Regulation (EU)
2025/327) asks for "its intended purpose, and the date and version of the EHR
system" in the technical documentation (Annex III 1(a)) and on the
information sheet (Art. 38(2)(c)), and forbids advertising that suggests uses
"other than those stated to form part of the intended purpose in the technical
documentation" (Art. 28(c)).

> [!WARNING]
> The quotations are from the Official Journal texts at EUR-Lex: the
> [CRA](https://eur-lex.europa.eu/eli/reg/2024/2847/oj), the
> [EHDS](https://eur-lex.europa.eu/eli/reg/2025/327/oj) and the
> [MDR](https://eur-lex.europa.eu/eli/reg/2017/745/oj), Regulation (EU)
> 2017/745. The exact texts these pages were checked against are vendored in
> the FerroEHR repository under
> [`docs/law/eu/`](https://github.com/FerroHEALTH/FerroEHR/tree/main/docs/law/eu).
> This page says what the manufacturer intends. It does not say that the
> system, or a deployment of it, meets either regulation: no conformity
> assessment has been carried out and no EU declaration of conformity exists.

## The statement, its version and its scope

| | |
|---|---|
| Issued by | Cadasto B.V., Comeniusstraat 2d, 1817 MS Alkmaar, The Netherlands, [info@cadasto.com](mailto:info@cadasto.com) |
| Statement version | the revision of 2026-10-08. It takes over the system-level parts of FerroEHR's statement version 1 of 2026-10-06 |
| Applies to | the EHR system formed by FerroEHR (its server, images and Helm chart) and FerroBRIDGE, from the releases whose documentation links this revision |
| Where each version lives | the [revisions](../revisions.md) page dates every change, and the text of each revision stays in the history of the [FerroHEALTH repository](https://github.com/FerroHEALTH/FerroHEALTH/commits/main/website/book/src/ehds/intended-purpose.md) |

A change to the intended purpose is a new revision of this page, and the
release notes of the release that relies on it name its date. Under the CRA, a
change that "results in a modification to the intended purpose for which the
product with digital elements has been assessed" is a substantial
modification (CRA Art. 3(30)), so each product's risk assessment is revised
with it.

FerroFED is an EHR system of its own, with its own statement on its
[regulatory status](https://ferrofed.eu/docs/evaluate/regulatory-status.html#intended-purpose)
page. This page does not cover it.

## What the EHR system is for

The EHR system stores, versions and queries the structured health records of
one healthcare provider, serves them to the software that provider's health
professionals and patients use, and exchanges them in the European electronic
health record exchange format. It has no clinical user interface of its own:
health professionals reach it through the clinical applications the provider
connects to it.

EHDS Art. 2(2)(k) defines an EHR system as "any system whereby the software,
or a combination of the hardware and the software of that system, allows
personal electronic health data that belong to the priority categories of
personal electronic health data established under this Regulation to be
stored, intermediated, exported, imported, converted, edited or viewed, and
intended by the manufacturer to be used by healthcare providers when
providing patient care or by patients when accessing their electronic health
data". EHDS Art. 25(1) asks an EHR system to include both harmonised software
components, and the two products carry one each:

| Component | Product | What it does |
|---|---|---|
| European logging software component (EHDS Art. 2(2)(o), Annex II point 3) | FerroEHR | holds the records as openEHR compositions with their full version history, serves them through the openEHR REST API and the Archetype Query Language, and records every access to them in its access log |
| European interoperability software component (EHDS Art. 2(2)(n), Annex II points 2.1 to 2.3) | FerroBRIDGE | holds the mappings from openEHR to the European electronic health record exchange format and reads FerroEHR over the openEHR REST API. The format itself is set by implementing acts under EHDS Art. 15(1), which have not been adopted |

The EHDS defines each component as independent of the other. FerroEHR and
FerroBRIDGE are separate products that meet only over the openEHR REST API.
FerroEHR documents the logging component's requirements and the system-level
ones of Annex II point 1; FerroBRIDGE documents the interoperability
component's.

## Who uses it

| User | How they use the EHR system |
|---|---|
| A healthcare provider, the deploying organisation | runs the system for its own records, as controller of the data in it. Its operators install, configure, upgrade and monitor each product |
| Developers of clinical applications | connect an application to FerroEHR's REST API and AQL, on behalf of the provider |
| Health professionals | use the system only through those applications. The application's caller is authenticated by the provider's identity provider, and FerroEHR authorises each request and records it |
| Patients | do not use the system directly. A patient reads their record, and the log of who accessed it, through an electronic health data access service, which EHDS Art. 4(1) has the Member States establish. FerroEHR serves one patient's access log to such a service when the deployment configures it |
| Clinical modellers and administrators | load templates, write stored queries, maintain the mappings and run the operational surfaces of each product |

## The data the EHR system is designed to process

EHDS Annex III 1(b) and Art. 38(2)(d) ask for "the categories of personal
electronic health data that the EHR system has been designed to process". The
system is designed for the priority categories of EHDS Art. 14(1): "(a)
patient summaries; (b) electronic prescriptions; (c) electronic
dispensations; (d) medical imaging studies and related imaging reports; (e)
medical test results, including laboratory and other diagnostic results and
related reports; and (f) discharge reports", and any category a Member State
adds in national law. Which of them a deployment holds depends on the
templates it loads, and the deployment declares that. Beside the clinical
content, the system holds the identities of the record subjects, the link
between the two, and the access log.

Each product's book lists the data it holds, domain by domain:
[FerroEHR's](https://ferroehr.eu/docs/latest/compliance/intended-purpose.html).

## How the EHR system is operated

The system runs in one of two ways:

- **Self-hosted.** The deploying organisation installs and runs it, or has a
  processor of its own choosing do so. Cadasto B.V. is the manufacturer only
  and has no access to the deployment or its data.
- **Hosted by Cadasto B.V.** Cadasto B.V. may run the system as a service for
  an organisation. It is then also the operator, and that organisation's
  processor under a contract that GDPR Art. 28(3) requires. An EHR system
  offered as a service to a person established in the Union "shall be
  considered as having been put into service" (EHDS Art. 26(2)).

In both cases each organisation gets its own instance of each product. The
environment each product relies on and does not provide itself, such as TLS
termination, an identity provider and database protection, is stated in that
product's book (CRA Annex II point 4):
[FerroEHR's security environment](https://ferroehr.eu/docs/latest/compliance/intended-purpose.html#the-security-environment-ferroehr-assumes).

## What the intended purpose excludes

- **Medical device purposes.** Cadasto B.V. does not intend the EHR system
  for any of the "specific medical purposes" in the MDR's definition of a
  medical device (MDR Art. 2(1)): "diagnosis, prevention, monitoring,
  prediction, prognosis, treatment or alleviation of disease", and the others
  that article lists. The system stores, returns and converts records; it
  computes no diagnosis, score, alert or treatment advice.
- **Several organisations in one deployment.** One deployment serves one
  healthcare provider.

Each product's book lists the exclusions particular to it, and the use and
misuse that can be foreseen for it.

## Where this statement is used

- Each product's CRA risk assessment analyses its risks "based on the intended
  purpose and reasonably foreseeable use" (CRA Art. 13(3)):
  [FerroEHR's](https://ferroehr.eu/docs/latest/compliance/cra-risk-assessment.html).
- The hazard log of the logging component assesses patient safety "during
  normal conditions of use" (EHDS Annex II 1.1):
  [FerroEHR's hazard log](https://ferroehr.eu/docs/latest/compliance/hazard-log.html).
- The claims review checks every public text against it (EHDS Art. 28(c)):
  [FerroEHR's](https://ferroehr.eu/docs/latest/compliance/claims-review.html).
- The technical documentation maps EHDS Annex III 1(a) onto it, and the
  information sheet of EHDS Art. 38 repeats it:
  [FerroEHR's technical documentation](https://ferroehr.eu/docs/latest/compliance/technical-documentation.html)
  and [information sheet](https://ferroehr.eu/docs/latest/compliance/information-sheet.html).

FerroBRIDGE's book carries none of these pages yet.
