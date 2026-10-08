# Post-market

Revised 2026-10-08.

This page is the post-market procedure Cadasto B.V. runs as manufacturer of
every FerroHEALTH product: how to complain or report an incident, how a report
is classified, what happens when a released version turns out not to conform,
the reports to the authorities, and what happens if the manufacturer ceases
operations. The duties come from two regulations: Regulation (EU) 2025/327 on
the European Health Data Space (the EHDS), Articles 30, 43, 44 and 45, and
Regulation (EU) 2024/2847, the Cyber Resilience Act (the CRA), Articles 13
and 14. The steps that carry them out are the manufacturer's own design.

Each product keeps its own registers and the steps bound to its own
repository (its tracker, its release lane, its withdrawal tooling), and its
book lists what counts as a possible serious incident for that product.

> [!WARNING]
> The quotations are from the Official Journal texts at EUR-Lex: the
> [EHDS](https://eur-lex.europa.eu/eli/reg/2025/327/oj), the
> [CRA](https://eur-lex.europa.eu/eli/reg/2024/2847/oj), the
> [NIS2 Directive](https://eur-lex.europa.eu/eli/dir/2022/2555/oj),
> [Regulation (EU) 2019/1020](https://eur-lex.europa.eu/eli/reg/2019/1020/oj)
> and Commission Delegated Regulation
> [(EU) 2026/881](https://eur-lex.europa.eu/eli/reg_del/2026/881/oj). The exact
> texts these pages were checked against are vendored in the FerroEHR
> repository under
> [`docs/law/eu/`](https://github.com/FerroHEALTH/FerroEHR/tree/main/docs/law/eu).
> This page is not legal advice, and it says nothing about whether a product
> or a deployment meets either regulation. It says what the manufacturer does.

## Which products the duties reach

The CRA reaches every product: each tagged release is a product with digital
elements that Cadasto B.V. places on the market. The EHDS duties on this page
bind the manufacturer of an EHR system. Cadasto B.V. declares two:

- the EHR system that **FerroEHR and FerroBRIDGE** form together
  ([intended purpose](ehds/intended-purpose.md));
- **FerroFED**, which Cadasto B.V. classifies as an EHR system of its own
  ([FerroFED's regulatory status](https://ferrofed.eu/docs/evaluate/regulatory-status.html)).

This book records no EHDS classification for FerroTERM or FerroCHART.

## When the duties apply

| Duty | Applies from | Text |
|---|---|---|
| CRA Art. 14, reporting actively exploited vulnerabilities and severe incidents | 11 September 2026, for every release, including those published before 11 December 2027 | CRA Art. 71(2), Art. 69(3) |
| EHDS Art. 30 (complaints, registers, corrective action), Art. 43 to 45 (market surveillance, serious incidents) | 26 March 2027 | EHDS Art. 105, which gives none of them a later date |
| CRA Art. 13(6), 13(21), 13(23) and Annex I Part II (upstream reporting, corrective measures, cessation, vulnerability handling) | 11 December 2027 | CRA Art. 71(2) |

The procedure runs now for all of them, so that it is practised before the
EHDS and the rest of the CRA apply.

## Who does what

| Who | What |
|---|---|
| Cadasto B.V., the manufacturer | Receives complaints and incident reports at [info@cadasto.com](mailto:info@cadasto.com), the single point of contact (EHDS Art. 30(1)(g)). Decides whether an event is a serious incident or an actively exploited vulnerability, and signs every report to an authority. |
| The maintainer, Ruben Talstra | Reads private vulnerability reports, the reports Cadasto B.V. forwards, and the trackers; enters the register rows, prepares the correcting release, withdraws a release, and drafts the advisory and the reports for Cadasto B.V. to send. |
| The deploying organisation | Supplies the facts of its deployment. Owes its own notifications under the GDPR and, where it is an essential or important entity, under NIS2. None of the manufacturer's reports stands in for them. |

## Making a complaint or a report

EHDS Art. 30(1)(n) asks the manufacturer to "establish channels of complaint
and keep distributors informed thereof". Pick the channel by what the report
contains, and put the product's name in the subject:

| What | Channel | Who reads it |
|---|---|---|
| A vulnerability, including one you have seen exploited | GitHub private vulnerability reporting on the product's repository, or [info@cadasto.com](mailto:info@cadasto.com) with "*Product* vulnerability" in the subject ([security](security.md#reporting-a-vulnerability)) | the maintainer; an email is forwarded by Cadasto B.V. the same day |
| Anything that harmed a person, or could have | [info@cadasto.com](mailto:info@cadasto.com), subject "*Product* incident" | Cadasto B.V., forwarded to the maintainer the same day |
| Any other complaint | [info@cadasto.com](mailto:info@cadasto.com), subject "*Product* complaint", or a public GitHub issue on the product's repository | Cadasto B.V. and the maintainer |

Say which product and which version you run, and how it is deployed, and
describe what happened. Never send patient data: describe the case, or build a
synthetic one. A product may offer a command that writes a report of the
deployment for this purpose; its book says which.

An emailed vulnerability report runs through the same procedure as a private
GitHub report. Its arrival is the moment the manufacturer becomes aware for
CRA Art. 14, so whoever reads info@cadasto.com forwards a message about a
vulnerability or an exploit to the maintainer at once and writes down the hour
it arrived.

## How a report is classified

| Class | When |
|---|---|
| complaint | the product behaves as documented, and the report asks for something else |
| non-conformity | a released version misses an EHDS Annex II item, an obligation of EHDS Chapter III or a CRA Annex I requirement; continue with [corrective action](#corrective-action-withdrawal-and-recall) |
| serious incident | the event meets EHDS Art. 2(2)(r); start the [serious-incident clock](#serious-incidents-ehds-art-44) at once |
| exploited vulnerability | a vulnerability with reliable evidence of exploitation (CRA Art. 3(42)), or a severe incident (CRA Art. 14(5)); start the [CRA clock](#actively-exploited-vulnerabilities-and-severe-incidents-cra-art-14) at once |

The person who reported is answered through the channel they used.

## The registers

EHDS Art. 30(1)(o) asks the manufacturer to "keep a register of complaints
and a register of non-conforming EHR systems and keep distributors informed
thereof". CRA Art. 13(6) adds the record of vulnerabilities reported upstream.
The registers are kept per product, public, in the product's repository,
appended and never rewritten:

| Product | Registers |
|---|---|
| FerroEHR | [complaints](https://github.com/FerroHEALTH/FerroEHR/blob/main/docs/registers/complaints.tsv), [non-conforming versions](https://github.com/FerroHEALTH/FerroEHR/blob/main/docs/registers/non-conforming-versions.tsv), [upstream reports](https://github.com/FerroHEALTH/FerroEHR/blob/main/docs/registers/upstream-reports.tsv) |
| FerroFED | [complaints](https://github.com/FerroHEALTH/FerroFED/blob/main/docs/registers/complaints.tsv), [non-conforming versions](https://github.com/FerroHEALTH/FerroFED/blob/main/docs/registers/non-conforming-versions.tsv) |
| FerroCHART, FerroTERM, FerroBRIDGE | none yet |

A complaint gets its row within one working day of receipt, whatever the
channel. No row names the person who complained or carries patient data, and
the upstream register names components, never people. A vulnerability enters
the registers when its advisory is published, so a row never discloses one
before its fix; until then the draft advisory is the record.

## Corrective action, withdrawal and recall

When the manufacturer considers, or has reason to believe, that released
versions "are not or are no longer in conformity with the essential
requirements laid down in Annex II", it takes "without undue delay any
necessary corrective action", or recalls or withdraws them (EHDS
Art. 30(1)(i)). CRA Art. 13(21) asks for the same "immediately" where a
product or the manufacturer's processes do not conform with the CRA's
Annex I.

A withdrawal is any measure that prevents a product in the supply chain from
being made available; a recall is any measure that achieves the return of a
product already made available to the end user (Regulation (EU) 2019/1020
Art. 3(22) and (23), which EHDS Art. 2(1)(d) and CRA Art. 3(49) and (50)
adopt). The steps:

1. The finding enters the product's register of non-conforming versions.
2. The fix ships in a new patch release. A published release is immutable, so
   a non-conforming version is never changed or deleted.
3. The manufacturer decides between correction, withdrawal and recall, and
   writes the decision and its timetable into the register. A withdrawal moves
   the product's floating image tags (`<major>.<minor>` and `latest`) to the
   correcting release and lists the version as unsupported in the product's
   `SECURITY.md`. The version's own tag and image digests stay published, so a
   deployment pinned to them keeps running the withdrawn version until it
   moves. A recall adds a direct message to every known user to replace the
   version. FerroEHR and FerroFED each carry `scripts/release/withdraw.sh`
   for the steps bound to their own repository.
4. The national authorities of each Member State where the version was made
   available or put into service are told of the non-conformity, of the
   corrective action "including the timetable for implementation", and of the
   date the version was "brought into conformity or been recalled or
   withdrawn" (EHDS Art. 30(1)(i)).
5. Distributors, the authorised representative, importers and users are told
   of "the non-conformity and of any corrective action, recall or withdrawal"
   (EHDS Art. 30(1)(j)): through a security advisory or an announcement, the
   release notes of the correcting version, and directly where the
   manufacturer knows them.

The same routes carry any "mandatory preventive maintenance of the EHR
systems and its frequency" (EHDS Art. 30(1)(k)).

## Serious incidents (EHDS Art. 44)

EHDS Art. 2(2)(r) defines a serious incident as "any malfunction or
deterioration in the characteristics or performance of an EHR system made
available on the market that directly or indirectly leads, might have led or
might lead to any of the following: (i) the death of a natural person or
serious harm to a natural person’s health; (ii) serious prejudice to a
natural person’s rights; (iii) serious disruption of the management and
operation of critical infrastructure in the health sector". Each EHR system's
book lists the events its manufacturer treats as possible serious incidents:
[FerroEHR's](https://ferroehr.eu/docs/latest/compliance/post-market.html) and
[FerroFED's](https://ferrofed.eu/docs/evaluate/post-market.html).

EHDS Art. 44(7) sets the report:

- **To whom:** "the market surveillance authorities of the Member States
  where such serious incident occurred and of the Member States where such
  EHR systems are placed on the market or put into service". Each Member
  State designates its authority, and "The Commission and the Member States
  shall make that information publicly available" (Art. 43(2)).
- **What:** the incident, including "a description of the corrective action
  taken or envisaged by the manufacturer".
- **When:** "immediately after the manufacturer has established a causal link
  between the EHR system and the serious incident or the reasonable
  likelihood of such a link and, in any event, not later than three days
  after the manufacturer becomes aware of the serious incident involving the
  EHR system". The three days run from awareness, so the report goes in on
  time while the cause is still being established, and is completed later.

The steps:

1. **Day 0, on awareness.** The date and hour are written down, and the
   complaint and non-conformity rows are entered. The deployment is asked how
   it is deployed and what happened.
2. **The same day.** The manufacturer checks whether the event is also a
   CRA Art. 14 matter. If it is, that clock runs as well; neither report
   replaces the other.
3. **By day 3 at the latest.** Cadasto B.V. reports to the authorities above:
   what happened, the versions involved, the causal link as far as it is
   established, and the corrective action taken or envisaged.
4. **Harm.** Where an authority finds that an EHR system "has caused harm to
   the health or safety of natural persons", the manufacturer "shall
   immediately provide information and documentation" to the affected person
   or user (Art. 44(3)).
5. Corrective action continues as [above](#corrective-action-withdrawal-and-recall)
   for every copy placed on the market in the Union (Art. 44(4)).

Where a serious incident concerns personal data protection, the market
surveillance authority informs the data protection supervisory authorities
(Art. 44(6)); a deployment's own duties under the GDPR remain its own.

## Actively exploited vulnerabilities and severe incidents (CRA Art. 14)

The manufacturer becomes aware through a private vulnerability report, an
emailed one, a CSIRT telling it of someone else's notification
(CRA Art. 15(4)), or its own finding. The deadlines and the content of each
step are on the [security](security.md#what-cadasto-bv-reports-to-the-authorities)
page. The steps:

1. **Hour 0.** The date and hour are written down. Cadasto B.V. decides, on
   the evidence, whether the vulnerability is actively exploited or the
   incident severe. CRA Art. 14(5) calls an incident severe when it affects or
   can affect the ability to protect the availability, authenticity,
   integrity or confidentiality of sensitive or important data or functions,
   or when it has led or can lead to malicious code.
2. **Within 24 hours: the early warning**, through ENISA's single reporting
   platform to the CSIRT designated as coordinator in the Netherlands.
3. **Within 72 hours: the notification**, saying how sensitive Cadasto B.V.
   considers the information. Where a fix is expected within 72 hours, the
   notification says so: that is a condition under which the receiving CSIRT
   may delay passing it on (Commission Delegated Regulation (EU) 2026/881
   Art. 3(a), adopted for the delay CRA Art. 16(2) allows).
4. **Users are told** through a GitHub security advisory on the product's
   repository and the release notes of the fixing release, with the
   mitigations users can apply before they upgrade (Art. 14(8)).
5. **On request, an intermediate report** to the CSIRT (Art. 14(6)).
6. **The final report**: for a vulnerability, no later than 14 days after a
   corrective or mitigating measure is available; for an incident, within one
   month after the notification.

An event can be an EHDS serious incident and a CRA notification at once. Each
report is then made, each on its own clock.

## NIS2

EHDS Art. 44(7) makes the serious-incident report "without prejudice to
incident notification requirements under Directive (EU) 2022/2555", the NIS2
Directive. NIS2 Art. 23 has each Member State require essential and important
entities to notify significant incidents to their CSIRT or competent
authority, and healthcare providers are a sector in its Annex I. A hospital
running a FerroHEALTH product may owe that notification under its own
national law. The manufacturer's EHDS report and CRA notification do not
stand in for it, and the hospital's notification does not stand in for them.
The manufacturer gives the hospital the facts it needs: the advisory, the
affected versions, the mitigations and the timeline it reported.

## Security advisories

CRA Annex I Part II(4) has the manufacturer, "once a security update has been
made available, share and publicly disclose information about fixed
vulnerabilities". Every fixed vulnerability gets a GitHub security advisory on
the product's repository, published with the fixing release. What an advisory
carries, and when its technical details may wait, is on the
[security](security.md#security-advisories) page.

## Vulnerabilities in integrated components

When the manufacturer identifies a vulnerability "in a component, including
in an open source-component, which is integrated in the product", it shall
"report the vulnerability to the person or entity manufacturing or
maintaining the component", and share any fix it wrote (CRA Art. 13(6)).

- **Who reports:** the maintainer, on behalf of Cadasto B.V.
- **When:** as soon as the vulnerability is confirmed in the component,
  whether the product's own work found it (a fuzz crash, a review, a test) or
  a reporter told the manufacturer of it. A component vulnerability that a
  scanner reports from a published advisory is already known upstream and
  needs no report.
- **Through which channel:** the component's own security policy first. For a
  Rust crate, its `SECURITY.md` or private vulnerability reporting on its
  repository, then a RustSec advisory once it can be public; for a base-image
  package, the project's security contact or the distribution's security
  tracker; for a vendored asset, its publisher's contact.
- **The fix:** a patch the manufacturer wrote is offered upstream, under the
  component's licence.
- **The product's own side:** the vulnerability is handled like any other: a
  draft advisory, a security-only release when the product is affected, or a
  VEX statement when it is not.
- **The record:** a row in the product's upstream register once the upstream
  advisory is public, naming the component and never a person.

## A request from an authority

On request, the manufacturer gives a market surveillance authority "all the
information and documentation necessary to demonstrate the conformity" of the
product, in an official language of the Member State concerned (EHDS
Art. 30(1)(l)), "in paper or electronic form" and "in a language which can be
easily understood by that market surveillance authority" (EHDS Art. 30(5);
CRA Art. 13(22)), and cooperates on any action to bring the product into
conformity or to eliminate its risks (EHDS Art. 30(1)(m), Art. 44(1)). A
request goes to the single point of contact,
[info@cadasto.com](mailto:info@cadasto.com). An authority may restrict,
recall or withdraw an EHR system whose manufacturer does not cooperate or whose
information "is incomplete or incorrect" (EHDS Art. 43(5)).

## If the manufacturer ceases operations

CRA Art. 13(23): "A manufacturer that ceases its operations and, as a result,
is not able to comply with this Regulation shall inform, before the cessation
of operations takes effect, the relevant market surveillance authorities as
well as, by any means available and to the extent possible, the users of the
relevant products with digital elements placed on the market, of the
impending cessation of operations."

If that happens, Cadasto B.V. will:

1. **Decide and date it.** The board of Cadasto B.V. decides that it will
   cease operations, or that a product will no longer be maintained, and the
   date it takes effect. The steps below run as soon as that date is set, so
   every notice goes out before it.
2. **Tell the authorities first:** the market surveillance authority of each
   Member State where a product is made available, and, while the EHDS
   applies, of each Member State where an EHR system is put into service. The
   notice names the products, the date, the date from which vulnerabilities
   are no longer handled, and what stays published.
3. **Tell the known users:** a direct message to every operator and every
   commercial licensee it knows of.
4. **Tell the public:** a pinned issue on each product's repository, a notice
   at the top of each product's `SECURITY.md`, on its documentation site and
   in this book, and a final security advisory naming the last supported
   release. The notice says that the support periods end early, on the
   cessation date.
5. **Leave everything published.** Every release, image, chart, crate,
   advisory, register and page stays where it is. Releases are immutable, and
   nothing is withdrawn because the manufacturer stops.
6. **Close the registers:** every open row gets its outcome as it stands.

Under the licence published with each version, a version becomes licensed
under the Apache License 2.0 four years after its publication
([licensing](licensing.md#the-change-date)). The licence text ties that change
to the version's publication date and sets no condition on the Licensor
continuing to exist. A commercial licence is governed by its own contract.

## Open points

Nothing in the products' repositories answers these. Cadasto B.V. supplies
them:

1. The CSIRT designated as coordinator for the Netherlands under CRA
   Art. 14(7), and Cadasto B.V.'s account on ENISA's single reporting
   platform (Art. 16(1)).
2. Who at Cadasto B.V. decides that a vulnerability is actively exploited or
   an incident severe, and signs the CRA notification and the EHDS
   serious-incident report; and who stands in when that person is away, since
   the clock runs in hours.
3. The market surveillance authority of each Member State where a product is
   placed on the market or put into service, with its contact for a
   serious-incident report.
4. Whether Cadasto B.V. is itself an essential or important entity under NIS2
   in the Netherlands, in particular once it hosts a product as a service for
   other organisations.
5. The list of distributors, importers and known users to whom the
   EHDS Art. 30(1)(j) and (n) notices go, which is the register of economic
   operators of EHDS Art. 35.
6. Whether info@cadasto.com should publish an encryption key for
   vulnerability reports, and who reads that inbox and forwards a report the
   same day, including outside working hours.
7. The 30-day ceiling on delaying an advisory's technical details, which the
   [security](security.md#when-the-details-may-wait) page states, needs
   Cadasto B.V.'s confirmation.
8. Who on the board of Cadasto B.V. decides a cessation of operations, and
   whether a successor would take over the support periods.
9. Whether the certified scope of Cadasto B.V.'s ISO 9001, ISO/IEC 27001 and
   NEN 7510 certificates covers the development and release of the products,
   these procedures, and a service Cadasto B.V. hosts for other
   organisations.
