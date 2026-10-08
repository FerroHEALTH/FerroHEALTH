# The Cyber Resilience Act

Revised 2026-10-08.

The Cyber Resilience Act (CRA, Regulation (EU) 2024/2847) sets cybersecurity
requirements for "a software or hardware product and its remote data
processing solutions" (CRA Art. 3(1)) made available on the EU market, and
duties for the manufacturer that places it there. This page is the
manufacturer's side, which is the same for every FerroHEALTH product: who the
manufacturer is, which duties apply from when, how conformity is assessed for
each product, and which questions are open. Each product keeps its own risk
assessment and its own Annex II information in its own book.

> [!WARNING]
> The quotations are from the Official Journal text of the
> [CRA](https://eur-lex.europa.eu/eli/reg/2024/2847/oj) at EUR-Lex. The
> amendments that Article 104 of the
> [EHDS](https://eur-lex.europa.eu/eli/reg/2025/327/oj), Regulation (EU)
> 2025/327, makes to the CRA are read from that Regulation, and the product
> categories from Implementing Regulation
> [(EU) 2025/2392](https://eur-lex.europa.eu/eli/reg_impl/2025/2392/oj). The
> exact texts these pages were checked against are vendored in the FerroEHR
> repository under
> [`docs/law/eu/`](https://github.com/FerroHEALTH/FerroEHR/tree/main/docs/law/eu).
> No conformity assessment has been carried out for any product, no EU
> declaration of conformity exists and no product carries the CE marking.
> This page is the manufacturer's reading, not legal advice.

## The manufacturer and the products

Cadasto B.V. is the manufacturer of each tagged release of every FerroHEALTH
product in the sense of CRA Art. 3(13)
([the manufacturer](manufacturer.md)). Each tagged release is one product with
digital elements. Its single point of contact (CRA Art. 13(17)) is
[info@cadasto.com](mailto:info@cadasto.com), beside GitHub private
vulnerability reporting on each product's repository
([security](security.md#reporting-a-vulnerability)).

A library a product publishes on its own, such as the `openehr-*` crates
FerroEHR publishes on crates.io, is a product of its own. Its owning product's
book says what the CRA asks of it.

## Not free and open-source software

CRA Art. 3(48) defines free and open-source software as software "made
available under a free and open-source licence which provides for all rights
to make it freely accessible, usable, modifiable and redistributable". Every
FerroHEALTH product is published under the Business Source License 1.1, whose
Additional Use Grant allows production use for non-commercial purposes only;
any other production use needs a commercial licence from Cadasto B.V.
([licensing](licensing.md)). The licence does not provide for all of those
rights, so no product is free and open-source software under the CRA. The
provisions written for such software do not apply: the open-source software
steward regime of CRA Art. 24, and the option of CRA Art. 32(5) to use the
internal control procedure for an important product whose technical
documentation is public.

Each version becomes available under the Apache License 2.0 four years after
its publication ([the Change Date](licensing.md#the-change-date)). The
position above is about each release as Cadasto B.V. places it on the market.
A library a product publishes under Apache-2.0 is free and open-source
software, and its owning product's book treats it separately.

## What applies, and from when

| Duty | Applies from | Text |
|---|---|---|
| Report actively exploited vulnerabilities and severe incidents (Art. 14) | 11 September 2026, for every release, including those published before 11 December 2027 | Art. 71(2); Art. 69(3) |
| The essential requirements of Annex I, the manufacturer's obligations of Art. 13, technical documentation, conformity assessment, the declaration and the CE marking | 11 December 2027 | Art. 71(2) |
| A product placed on the market before 11 December 2027 | the requirements reach it only "if, from that date, those products are subject to a substantial modification" | Art. 69(2) |

Each product ships new releases often, and each tagged release is placed on
the market when it is published, so the releases published from 11 December
2027 are the ones the full Regulation measures.

## Reporting, the support period and vulnerability handling

- **Reporting (Art. 14).** Cadasto B.V. notifies an actively exploited
  vulnerability or a severe incident to the CSIRT designated as coordinator in
  the Netherlands and to ENISA, through the single reporting platform: an
  early warning within 24 hours, a notification within 72 hours, and a final
  report. The steps are on the [security](security.md#what-cadasto-bv-reports-to-the-authorities)
  and [post-market](post-market.md#actively-exploited-vulnerabilities-and-severe-incidents-cra-art-14)
  pages.
- **The support period (Art. 13(8)).** "the support period shall be at least
  five years", and "Where the product with digital elements is expected to be
  in use for less than five years, the support period shall correspond to the
  expected use time". The end date, month and year, is stated to the user
  (Art. 13(19)). Each product states its own period and the end date of each
  release ([security](security.md#the-support-period)).
- **Vulnerability handling (Annex I Part II).** Fixes ship forward in the
  newest release, as Art. 13(10) allows, security fixes ship separately from
  functionality where technically feasible, and every fixed vulnerability gets
  an advisory ([security](security.md#how-a-fix-reaches-you)).
- **Software bill of materials (Annex I Part II(1)).** Each product's release
  lane attaches SBOMs and signed provenance to its releases; each product's
  `SECURITY.md` lists them and says how to verify a release.

## The information that accompanies each release

CRA Art. 13(18) has each product "accompanied by the information and
instructions to the user set out in Annex II". Three of its points are the
same for every product, and this book is their source:

| Annex II point | Where |
|---|---|
| 1. "the name, registered trade name or registered trademark of the manufacturer, and the postal address, the email address or other digital contact as well as, where available, the website at which the manufacturer can be contacted" | [the manufacturer](manufacturer.md) |
| 2. "the single point of contact where information about vulnerabilities of the product with digital elements can be reported and received, and where the manufacturer’s policy on coordinated vulnerability disclosure can be found" | [security](security.md#reporting-a-vulnerability) |
| 7. "the type of technical security support offered by the manufacturer", the first half of the point | [security](security.md#how-a-fix-reaches-you); the second half, "the end-date of the support period", is each product's own |

The other points are product-specific, and each product answers them in its
own book. FerroEHR's are on its
[CRA information and instructions to the user](https://ferroehr.eu/docs/latest/compliance/cra-user-information.html)
page.

## How conformity is assessed, product by product

Cadasto B.V. declares two EHR systems under the EHDS: FerroEHR with
FerroBRIDGE, and FerroFED. EHDS Article 104 amends the CRA for that case:

- **The procedure.** CRA Art. 32(5a), inserted by EHDS Art. 104(3):
  "Manufacturers of products with digital elements that are classified as EHR
  systems under Regulation (EU) 2025/327 \[…\] shall demonstrate conformity
  with the essential requirements set out in Annex I to this Regulation using
  the relevant conformity assessment procedure provided for in Chapter III of
  Regulation (EU) 2025/327."
- **One set of technical documentation.** CRA Art. 31(3), as EHDS
  Art. 104(2) replaces it: "a single set of technical documentation shall be
  drawn up containing the information referred to in Annex VII and the
  information required by those Union legal acts".
- **One risk assessment.** CRA Art. 13(4), as EHDS Art. 104(1) replaces it:
  for such a product, "the cybersecurity risk assessment may be part of the
  risk assessment required by those Union legal acts".
- **One declaration.** CRA Art. 28(3): "Where a product with digital elements
  is subject to more than one Union legal act requiring an EU declaration of
  conformity, a single EU declaration of conformity shall be drawn up".

| Product | Conformity route | The product's own record |
|---|---|---|
| FerroEHR and FerroBRIDGE | one EHR system: the EHDS Chapter III procedure (CRA Art. 32(5a)), one technical documentation set and one declaration naming both. FerroEHR's reading is a default product, against a competing reading of Annex III class I point 1 | [FerroEHR's CRA page](https://ferroehr.eu/docs/latest/compliance/cra.html), its [risk assessment](https://ferroehr.eu/docs/latest/compliance/cra-risk-assessment.html) and its [technical documentation](https://ferroehr.eu/docs/latest/compliance/technical-documentation.html). FerroBRIDGE's book carries no CRA page yet |
| FerroFED | an EHR system of its own: the EHDS Chapter III procedure (CRA Art. 32(5a)), with one documentation set, declaration and CE marking for both acts | [FerroFED's regulatory status](https://ferrofed.eu/docs/evaluate/regulatory-status.html#the-cyber-resilience-act) |
| FerroTERM, FerroCHART | not recorded: whether each is a default product or an important product under Annex III is open | none yet |

### The EU declaration of conformity

CRA Art. 28 has the manufacturer draw up an EU declaration of conformity,
Art. 13(20) has it accompany the product or be available at an address the
user information states (Annex II point 6), and Art. 28(3) makes one
declaration cover every Union act that applies. None has been drawn up for any
product. The obligation applies from 11 December 2027. Recording the
conformity route of each product and drawing up the declaration is tracked in
[FerroEHR#3696](https://github.com/FerroHEALTH/FerroEHR/issues/3696); when a
declaration exists, it is published with each release it covers, and this
page gives its address.

### Default product, or important product

CRA Art. 7(1): products "which have the core functionality of a product
category set out in Annex III shall be considered to be important products
with digital elements", and "The integration of a product with digital
elements which has the core functionality of a product category set out in
Annex III shall not in itself render the product in which it is integrated
subject to the conformity assessment procedures referred to in Article 32(2)
and (3)". Implementing Regulation (EU) 2025/2392 gives each category's
technical description. For an important product of class I whose
manufacturer has not applied harmonised standards, common specifications or a
certification scheme in full, CRA Art. 32(2) requires a third-party procedure
(module B with C, or module H). Each product's book states its reading of its
own core functionality; FerroEHR's is on its
[CRA page](https://ferroehr.eu/docs/latest/compliance/cra.html).

## A deployment Cadasto B.V. hosts as a service

Cadasto B.V. may host a product as a service for another organisation. The
CRA reaches "remote data processing solutions", which recital 11 describes as
"data processing at a distance for which the software is designed and
developed by or on behalf of the manufacturer \[…\], the absence of which
would prevent the product with digital elements from performing one of its
functions". Recital 12 adds that "Directive (EU) 2022/2555 applies to cloud
computing services and cloud service models, such as Software as a Service
(SaaS)", and that cloud solutions are remote data processing solutions "only
if they meet the definition laid down in this Regulation". For EHR systems,
EHDS recital 112 states that "EHR systems offered through the SaaS licensing
and delivery model do not fall within the scope of that Regulation", the CRA,
and that "EHR systems that are developed and used in-house do not fall within
the scope of that Regulation, as they are not placed on the market".
FerroFED's book reads its hosted deployments that way. A recital is not an
operative article, and EHDS Art. 26(2) still counts an EHR system offered as a
service as put into service. Whether a hosted deployment of a self-hostable
product is inside the CRA's product scope, and whether Cadasto B.V. is then an
essential or important entity under NIS2, are questions for counsel.

In a hosted deployment Cadasto B.V. also operates the instance and is the
customer's processor under a GDPR Art. 28 contract
([shared responsibility](ehds/shared-responsibility.md#when-cadasto-bv-is-also-your-processor)).

## Who the CRA binds in a self-hosted deployment

The manufacturer's duties are Cadasto B.V.'s. An organisation that runs an
unmodified release for itself is a user of the product and not its
manufacturer. CRA Art. 22(1) makes a person "that carries out a substantial
modification of a product with digital elements and makes that product
available on the market" a manufacturer; whether an organisation that modifies
the source and only runs the result for itself is reached is a question for
counsel, as is the corresponding EHDS question.

## Questions for counsel

1. Whether each product is an important product under Annex III and
   Implementing Regulation (EU) 2025/2392, and whether CRA Art. 32(5a) changes
   the procedure for the products declared as EHR systems.
2. Whether CRA Art. 13(10) holds for commercial licensees under BUSL-1.1, and
   whether security updates are free of charge for every commercial licence
   (Annex I Part II(8)), tracked for FerroEHR in
   [FerroEHR#3647](https://github.com/FerroHEALTH/FerroEHR/issues/3647).
3. Whether a deployment that modifies the source and puts the result into
   service becomes a manufacturer itself (CRA Art. 21 and 22, EHDS Art. 34).
4. Whether a deployment Cadasto B.V. hosts as a service is remote data
   processing outside the CRA's product scope, and whether Cadasto B.V. is then
   an essential or important entity under NIS2.
5. Whether user information in English alone meets the CRA Art. 13(18) duty
   ("a language which can be easily understood by users and market
   surveillance authorities") in each Member State where a product is made
   available, or which Member States require a translation.
