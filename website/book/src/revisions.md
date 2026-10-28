# Revisions

Revised 2026-10-26.

Every change to a page of this book is a revision, dated on the page itself
and listed here, newest first. A product release that relies on a page names
the page and the date of its revision, for example "the FerroHEALTH security
policy, revised 2026-10-08", and the text of that revision stays in the
[history of this book](https://github.com/FerroHEALTH/FerroHEALTH/commits/main/website/book/src).
A correction of a typing error that changes no statement needs no revision.

`scripts/checks/book-revisions.sh` holds the two in step: every page carries a
revision date, and the newest row here for each page carries the same date.

| Date | Page | Change |
|---|---|---|
| 2026-10-28 | [The EHDS EHR system: readiness](ehds/readiness.md) | The interoperability component is FerroBRIDGE's published `eehrxf` crate; its row and Annex II 2.1 to 2.3 link FerroBRIDGE's pages for the component and for receiving a document. |
| 2026-10-28 | [How the products fit together](architecture.md) | FerroSYS no longer reads as unreleased: every crate is published, the FerroSYS releases page names the current versions, and the products that use it are named. |
| 2026-10-28 | [FerroHEALTH documentation](index.md) | FerroSYS's row says its crates are published and links the FerroSYS releases page. |
| 2026-10-26 | [The EHDS EHR system: readiness](ehds/readiness.md) | FerroEHR ships the whole logging component; the planned move of the access log to a FerroSYS service, which is not planned, is gone. |
| 2026-10-26 | [Annex III 1: a detailed description of the EHR system](ehds/annex-iii-1-description.md) | FerroSYS is no longer named as a planned third product of the EHR system. |
| 2026-10-26 | [Annex III 6: a copy of the EU declaration of conformity](ehds/annex-iii-6-declaration-of-conformity.md) | FerroSYS is no longer named as a planned third product of the EHR system. |
| 2026-10-26 | [Revisions](revisions.md) | The EHDS system documents joined the book. |
| 2026-10-26 | [FerroHEALTH documentation](index.md) | The EHDS system's information sheet, instructions for use, readiness record and technical documentation are listed. |
| 2026-10-26 | [The EHDS EHR system: information sheet](ehds/information-sheet.md) | First revision: the system's information sheet (EHDS Art. 38), moved from FerroEHR's book and written for both products. The version of the system is the release of the product a copy accompanies, with the oldest release of the other product it is tested against, and each release appends its own versions. |
| 2026-10-26 | [The EHDS EHR system: instructions for use](ehds/instructions-for-use.md) | First revision: the system's instructions for use (EHDS Art. 30(1)(d)), moved from FerroEHR's book, with FerroBRIDGE's part beside FerroEHR's. |
| 2026-10-26 | [The EHDS EHR system: readiness](ehds/readiness.md) | First revision: the readiness record, moved from FerroEHR's book and rendered from `website/book/ehds.yaml`, with every issue named by its repository. |
| 2026-10-26 | [The EHDS EHR system: technical documentation](ehds/technical-documentation.md) | First revision: the Annex III index, moved from FerroEHR's book and rendered from `website/book/ehds.yaml`. |
| 2026-10-26 | [Annex III 1: a detailed description of the EHR system](ehds/annex-iii-1-description.md) | First revision, from FerroEHR's `docs/technical-documentation/annex-iii-1-description.md`. |
| 2026-10-26 | [Annex III 2: the system in place to evaluate performance](ehds/annex-iii-2-performance-evaluation.md) | First revision, from FerroEHR's `docs/technical-documentation/annex-iii-2-performance-evaluation.md`. |
| 2026-10-26 | [Annex III 3: the common specifications used](ehds/annex-iii-3-common-specifications.md) | First revision, from FerroEHR's `docs/technical-documentation/annex-iii-3-common-specifications.md`. |
| 2026-10-26 | [Annex III 4: verification and validation results](ehds/annex-iii-4-verification-and-validation.md) | First revision, from FerroEHR's `docs/technical-documentation/annex-iii-4-verification-and-validation.md`. |
| 2026-10-26 | [Annex III 5: a copy of the information sheet](ehds/annex-iii-5-information-sheet.md) | First revision, from FerroEHR's `docs/technical-documentation/annex-iii-5-information-sheet.md`. |
| 2026-10-26 | [Annex III 6: a copy of the EU declaration of conformity](ehds/annex-iii-6-declaration-of-conformity.md) | First revision, from FerroEHR's `docs/technical-documentation/annex-iii-6-declaration-of-conformity.md`. |
| 2026-10-26 | [How the products fit together](architecture.md) | The family end-to-end lane: what it runs and asserts, how to run it on your own machine, and how its image pins follow each release. |
| 2026-10-26 | [How the products fit together](architecture.md) | FerroTASK is restored as the planned product, in the diagram and in the text; FerroPIX is drawn solid as a released, running server; FerroFORMS is greyed out because it is paused. |
| 2026-10-26 | [FerroHEALTH documentation](index.md) | FerroTASK is restored as the planned product; FerroPIX's row no longer says its server is being built. |
| 2026-10-26 | [Licensing and trademarks](licensing.md) | FerroTASK's licence row is restored. |
| 2026-10-26 | [How the products fit together](architecture.md) | FerroSYS is a set of shared crates beside FerroAUTH, FerroAUDIT and FerroUI, never a control plane; it leaves the products and the diagram's instance for the library band. FerroTASK, in no family plan, leaves the page and the diagram. |
| 2026-10-26 | [FerroHEALTH documentation](index.md) | No planned products: FerroSYS joins the shared libraries, and FerroTASK, in no family plan, is no longer listed. |
| 2026-10-26 | [Licensing and trademarks](licensing.md) | FerroSYS's licence is listed with the shared libraries, with the use its Additional Use Grant names; FerroTASK's row is gone and its name stays in the brand terms. |
| 2026-10-25 | [How the products fit together](architecture.md) | The family as five products, each in its own lane, with the protocol each speaks; FerroBRIDGE takes clinical HL7 Version 2 messages in over MLLP; FerroFED asks FerroPIX who a patient is; FerroEHR no longer feeds FerroPIX and is to look a subject up there as a client; the protocol clients and models stay with the product that owns them; every console is reactive; FerroFORMS is paused; FerroSMART is renamed FerroAUTH and holds `ferrohealth-authz` beside `ferrohealth-smart`. |
| 2026-10-25 | [FerroHEALTH documentation](index.md) | The five products and what each owns; FerroFORMS is paused; FerroSMART is renamed FerroAUTH, which holds authentication and the policy decision; every console is reactive. |
| 2026-10-25 | [Licensing and trademarks](licensing.md) | FerroSMART is renamed FerroAUTH. |
| 2026-10-25 | [Security](security.md) | FerroSMART is renamed FerroAUTH. |
| 2026-10-24 | [Security](security.md) | The family's fix-time targets by severity, counted from the confirmed assessment, and the acknowledgement and assessment times in the family wording; the per-product table gains a fix-time column, and the FerroEHR, FerroFED, FerroPIX, FerroAUDIT and FerroSMART rows state the family times. |
| 2026-10-24 | [FerroHEALTH documentation](index.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [How the products fit together](architecture.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [The Cyber Resilience Act](cra.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [Licensing and trademarks](licensing.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [The manufacturer](manufacturer.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [Post-market](post-market.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [Security](security.md) | FerroCHART is renamed FerroFORMS, at ferroforms.eu. |
| 2026-10-24 | [The Cyber Resilience Act](cra.md) | FerroTERM is a default product whose conformity is assessed by internal control (module A), the owner's decision of 2026-10-24, and its row links its CRA user information and risk assessment. |
| 2026-10-23 | [The Cyber Resilience Act](cra.md) | FerroBRIDGE, FerroFED and FerroTERM's CRA information and instructions to the user are linked beside FerroEHR's, and FerroBRIDGE's row names its page. |
| 2026-10-23 | [Security](security.md) | FerroAUDIT, FerroSMART and FerroUI join the per-product table, and the FerroFED, FerroTERM, FerroBRIDGE and FerroPIX rows are current; the release checks every product shares, and each product's VEX documents and image scans; VEX is no longer described as FerroEHR's alone. |
| 2026-10-22 | [Licensing and trademarks](licensing.md) | Each released product's licensing page is linked beside its `LICENSE`, FerroPIX's on `ferropix.eu` included. |
| 2026-10-22 | [FerroHEALTH documentation](index.md) | FerroPIX's book is linked, and FerroUI is the one source for every console's user interface, with its console guide linked. |
| 2026-10-22 | [How the products fit together](architecture.md) | FerroFED and FerroPIX use FerroSMART, FerroEHR and FerroFED use FerroAUDIT, and FerroUI leads every console's user interface. |
| 2026-10-20 | [FerroHEALTH documentation](index.md) | FerroPIX has released and joins the products; the shared libraries FerroSMART, FerroAUDIT and FerroUI are named, and none of them is a product. |
| 2026-10-20 | [How the products fit together](architecture.md) | The shared libraries and who uses each; FerroEHR resolves and feeds FerroPIX, whose pseudonym its EHR_STATUS carries; FerroPIX owns the IHE identity crates; the diagram draws the libraries as a band outside the instance. |
| 2026-10-20 | [Licensing and trademarks](licensing.md) | The shared libraries' licences, their hosted-service definitions and their names; FerroPIX's hosted-service definition. |
| 2026-10-20 | [Security](security.md) | FerroPIX and the shared libraries' reporting routes, and FerroPIX's support statement. |
| 2026-10-19 | [Security](security.md) | Only the newest release of a product is supported; the five years of Art. 13(8) are a commitment to keep publishing fixes in new releases. |
| 2026-10-19 | [The Cyber Resilience Act](cra.md) | The support period is a commitment to keep publishing fixes in new releases, and only the newest release is supported. |
| 2026-10-19 | [The EHDS EHR system: shared responsibility](ehds/shared-responsibility.md) | The deploying organisation runs the newest release, the only one supported. |
| 2026-10-19 | [FerroHEALTH documentation](index.md) | The planned authorisation service is withdrawn. |
| 2026-10-19 | [Licensing and trademarks](licensing.md) | The withdrawn authorisation service left the licence table and the brand names. |
| 2026-10-19 | [How the products fit together](architecture.md) | The withdrawn authorisation service left the diagram; each product authorises its own callers against the deployment's authorization server. |
| 2026-10-08 | [FerroHEALTH documentation](index.md) | First revision. |
| 2026-10-08 | [The manufacturer](manufacturer.md) | First revision, from FerroEHR's manufacturer record and compliance pages. |
| 2026-10-08 | [Security](security.md) | First revision: the shared parts of FerroEHR's `SECURITY.md`, with the points where the products' own policies differ. |
| 2026-10-08 | [Post-market](post-market.md) | First revision, from FerroEHR's post-market page and procedure; the registers stay per product. |
| 2026-10-08 | [The Cyber Resilience Act](cra.md) | First revision: the manufacturer's side of FerroEHR's CRA page, with the conformity route of each product. |
| 2026-10-08 | [The EHDS EHR system: intended purpose](ehds/intended-purpose.md) | First revision: the system-level statement for FerroEHR and FerroBRIDGE, taking over those parts of FerroEHR's statement version 1 of 2026-10-06. |
| 2026-10-08 | [The EHDS EHR system: shared responsibility](ehds/shared-responsibility.md) | First revision, from FerroEHR's shared-responsibility page. |
| 2026-10-08 | [Licensing and trademarks](licensing.md) | First revision, from FerroEHR's licensing page, each product's `LICENSE` and `CONTRIBUTING.md`, and `TRADEMARKS.md`. |
| 2026-10-08 | [How the products fit together](architecture.md) | First revision, around the family architecture diagram. |
| 2026-10-08 | [Revisions](revisions.md) | First revision. |
