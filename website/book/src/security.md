# Security

Revised 2026-10-08.

This page is the vulnerability-handling policy of Cadasto B.V., the
manufacturer of every FerroHEALTH product: how to report a vulnerability,
what happens after you do, how a fix and its advisory reach you, how long a
release is supported, and what the manufacturer reports to the authorities.
Each product's `SECURITY.md` keeps what is particular to it: the artefacts it
publishes, its scope notes and the release-by-release support table. Where a
product applies the policy differently today, the
[table below](#how-each-product-applies-it-today) says so.

> [!WARNING]
> The quotations are from the Official Journal text of the
> [CRA](https://eur-lex.europa.eu/eli/reg/2024/2847/oj), Regulation (EU)
> 2024/2847, at EUR-Lex. The exact text these pages were checked against is
> vendored in the FerroEHR repository at
> [`docs/law/eu/cra/text.html`](https://github.com/FerroHEALTH/FerroEHR/blob/main/docs/law/eu/cra/text.html).

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Report it privately
through GitHub private vulnerability reporting on the product's repository:

- FerroCHART: <https://github.com/FerroHEALTH/FerroCHART/security/advisories/new>
- FerroEHR: <https://github.com/FerroHEALTH/FerroEHR/security/advisories/new>
- FerroTERM: <https://github.com/FerroHEALTH/FerroTERM/security/advisories/new>
- FerroBRIDGE: <https://github.com/FerroHEALTH/FerroBRIDGE/security/advisories/new>
- FerroFED: <https://github.com/FerroHEALTH/FerroFED/security/advisories/new>

The form is "Report a vulnerability" on the repository's Security tab, and it
needs a GitHub account. Without one, email
[info@cadasto.com](mailto:info@cadasto.com), the manufacturer's single point
of contact, with the product's name and "vulnerability" in the subject, for
example "FerroEHR vulnerability". CRA Art. 13(17) has the single point of
contact "not limit such means to automated tools". The address has no
published encryption key, so send what you are comfortable sending by email
and say that more is available; a channel for the rest is agreed with you.

Include what you can: the product and the version, tag or commit; what an
attacker can do; steps to reproduce or a proof of concept; and any fix you
suggest. Never include patient data. Describe the case, or build a synthetic
one. Never test against a live clinical deployment you do not own.

**If you have seen the vulnerability exploited, say so in the report.** Your
report is one way the manufacturer becomes aware of an actively exploited
vulnerability, and that starts the 24-hour clock
[below](#what-cadasto-bv-reports-to-the-authorities).

## What happens next

- **Acknowledgement and assessment.** The maintainer acknowledges the report
  and assesses its severity, then states an intended fix window. The times
  each product commits to are in the
  [table below](#how-each-product-applies-it-today). If you hear nothing within
  that time, the report has not reached us: try the other route, or open a
  public issue saying only that a private report awaits acknowledgement, with
  no details.
- **Coordinated disclosure.** A disclosure date is agreed with you, and you
  are told when the fix ships. If the manufacturer misses its commitments,
  publishing is your call.
- **Credit.** The advisory credits the reporter with the name and link they
  give, if they want credit; say in the report whether you do. Declining
  credit changes nothing about how the report is handled.

### Safe harbour

FerroEHR's policy carries this safe harbour. Cadasto B.V. will not pursue or
support legal action against anyone who reports a vulnerability in good faith
and follows this policy: you tested against your own deployment or a test
instance you control, you did not access, modify or retain data belonging to
anyone else, you did not degrade service for others, and you gave the
manufacturer the response times above before publishing. If you are unsure
whether something is in scope, ask first; a question is always in good faith.

## How a fix reaches you

**A fix ships forward, in a new release.** A published release is immutable:
its assets and its tag cannot be changed. There are no maintenance branches
and no backports in any product, so the security update for a release ships
in the newest release, and the action for you is to upgrade. Old releases stay
downloadable as an archive, and an older release does not receive the fix.

CRA Art. 13(10) allows this where a manufacturer has placed successive
substantially modified versions of a software product on the market: it may
meet the requirement to remediate vulnerabilities (Annex I Part II(2)) "only
for the version that it has last placed on the market, provided that the
users of the versions that were previously placed on the market have access to the version last placed on the market
free of charge and do not incur additional costs to adjust the hardware and
software environment in which they use the original version of that
product". Every release of a product is published under the same licence
terms as the one before it, so a user with the right to run one release has
the same right to run the newest. Whether this holds for every commercial
licence is a [question for counsel](cra.md#questions-for-counsel); a
commercial licensee for whom it does not hold raises it with Cadasto B.V. at
[info@cadasto.com](mailto:info@cadasto.com).

**A security fix comes alone where it can.** CRA Annex I Part II(2) asks that
"where technically feasible, new security updates shall be provided
separately from functionality updates". A security fix ships in a
security-only patch release: the next patch on the current line, carrying the
fix and nothing that adds or changes functionality. A release may carry a
security fix with functional changes only when a recorded reason makes the
separate release technically infeasible, and that reason is written in the
release's notes under its `### Security` heading.

**Updates stay available.** Each security update stays available for at
least ten years after it is issued, or for the rest of the support period if
that is longer (CRA Art. 13(9)). Releases are never deleted.

## Security advisories

Every fixed vulnerability gets a GitHub security advisory on the product's
repository, published with the release that fixes it (CRA Annex I Part II(4)).
That covers a vulnerability in the product's own code, and a fix to a
dependency or a base image that changes what a shipped artefact contains or
how it behaves. Where a product publishes VEX statements (FerroEHR does, under
[`security/vex/`](https://github.com/FerroHEALTH/FerroEHR/tree/main/security/vex)),
a dependency finding that a statement shows does not affect the artefact gets
no advisory, and the statement is its record. Each advisory carries:

- a description of the vulnerability and its impact;
- its severity, as a CVSS vector and score;
- the affected and fixed versions of each artefact concerned;
- what to do: the release to upgrade to, and any mitigation that works before
  you can upgrade;
- the CVE identifier when one is assigned, and credit to the reporter unless
  they declined it.

The product's changelog entry for the fix carries the advisory's `GHSA-`
identifier, and the release notes repeat it.

### When the details may wait

Annex I Part II(4) allows that "in duly justified cases, where manufacturers
consider the security risks of publication to outweigh the security benefits,
they may delay making public information regarding a fixed vulnerability until
after users have been given the possibility to apply the relevant patch".
Cadasto B.V. uses it only when all three of these hold, and records the reason
in the draft advisory:

1. the vulnerability can be exploited without credentials, or by any
   authenticated caller, against a deployment that has not yet upgraded;
2. no mitigation short of upgrading is available;
3. the details are not already public, and the vulnerability is not actively
   exploited. An actively exploited vulnerability is told to users at once,
   under CRA Art. 14(8).

Even then the advisory is published with the fixing release, naming the
affected versions, the severity and the release to upgrade to. Only the
technical description and any reproduction wait, and they are added no later
than 30 days after the fixing release, or as soon as they become public
elsewhere. The 30-day ceiling is an [open point](post-market.md#open-points)
that Cadasto B.V. still has to confirm.

## The support period

CRA Art. 13(8) has the manufacturer handle a product's vulnerabilities for a
support period that "shall be at least five years", unless the product is
expected to be in use for less time, and Art. 13(19) has its end date,
"including at least the month and the year", stated to the user. These
articles bind the releases placed on the market from 11 December 2027
(CRA Art. 71(2) and 69(2)). Each product states its support period in its own
`SECURITY.md`, because the line of releases and their end dates are its own.
Where products differ today, the table below says how.

A release withdrawn because it did not conform is unsupported, and the
product's `SECURITY.md` lists it with the release to move to
([withdrawing a release](post-market.md#corrective-action-withdrawal-and-recall)).

## Hearing of an update

To hear of new releases and fixes for a product, subscribe to its release
feed and read its published advisories. For a product `<Product>`:

- the release feed, `https://github.com/FerroHEALTH/<Product>/releases.atom`;
- the advisories, `GET https://api.github.com/repos/FerroHEALTH/<Product>/security-advisories`,
  machine-readable through the GitHub REST API. An advisory that names a
  published crate also reaches the GitHub Advisory Database in OSV format.

Cadasto B.V. also writes directly to the users it knows from a contract when a
vulnerability or an incident needs action from them (CRA Art. 14(8)).

## What Cadasto B.V. reports to the authorities

CRA Art. 14 has the manufacturer notify "any actively exploited vulnerability
contained in the product with digital elements that it becomes aware of"
(Art. 14(1)) and "any severe incident having an impact on the security of the
product with digital elements" (Art. 14(3)). An actively exploited
vulnerability is one "for which there is reliable evidence that a malicious
actor has exploited it in a system without permission of the system owner"
(Art. 3(42)). The duty applies from 11 September 2026 (Art. 71(2)), and
Art. 69(3) reaches the products "placed on the market before 11 December
2027", so it covers every release of every product.

The notification goes through ENISA's single reporting platform to the CSIRT
designated as coordinator in the Netherlands, where Cadasto B.V. has its main
establishment, and is visible to ENISA at the same time (Art. 14(7)). It
comes in three steps, each counted from the moment the manufacturer becomes
aware:

| Step | Deadline | Content |
|---|---|---|
| Early warning | 24 hours | that it happened, and the Member States where the manufacturer knows the affected release is made available; for an incident, whether it is suspected to be unlawful or malicious (Art. 14(2)(a), 14(4)(a)) |
| Notification | 72 hours | the release concerned, the nature of the exploit or incident, the corrective or mitigating measures taken and those users can take (Art. 14(2)(b), 14(4)(b)) |
| Final report | a vulnerability: 14 days after a corrective or mitigating measure is available; an incident: one month after the notification | the description, severity and impact, what is known of the actor or the root cause, and the update or measures (Art. 14(2)(c), 14(4)(c)) |

Users are told of the vulnerability or incident, and of what they can do about
it, through a GitHub security advisory on the product's repository and the
release notes of the fixing release (Art. 14(8)). Coordinated disclosure with
the reporter continues alongside the notification. The steps the manufacturer
follows, and how a CRA notification relates to an EHDS serious-incident
report and to a hospital's own NIS2 notification, are on the
[post-market](post-market.md) page.

## Vulnerabilities in a component a product integrates

A vulnerability the manufacturer finds, or is told of, in a component a
product integrates (a Rust crate, a base image, a vendored asset) is reported
to that component's maintainer through its own channel, and a fix written for
it is offered upstream (CRA Art. 13(6)). A vulnerability you find yourself in
such a component goes to its maintainer; tell the manufacturer as well if it
reaches a FerroHEALTH product. The procedure is on the
[post-market](post-market.md#vulnerabilities-in-integrated-components) page.

## How each product applies it today

The products adopted this policy at different times, and their `SECURITY.md`
files still differ on these points. Each product's own file is the statement
for that product until it links this page in place of its own text.

| Product | Reporting routes its `SECURITY.md` names | Acknowledgement, then assessment | Support period it states | Security-only patch releases | Safe harbour |
|---|---|---|---|---|---|
| [FerroEHR](https://github.com/FerroHEALTH/FerroEHR/blob/main/SECURITY.md) | private reporting, or email to info@cadasto.com | 5 working days, then 10 working days | five years from the month a release is published, with the end date in each release's notes | yes | yes |
| [FerroFED](https://github.com/FerroHEALTH/FerroFED/blob/main/SECURITY.md) | private reporting | 7 days | five years from the release date, with a table of end dates | not stated | not stated |
| [FerroTERM](https://github.com/FerroHEALTH/FerroTERM/blob/main/SECURITY.md) | private reporting, or the maintainer's email to agree a channel | about 5 business days, then about 10, best effort | the latest release only, no end date | not stated | not stated |
| [FerroBRIDGE](https://github.com/FerroHEALTH/FerroBRIDGE/blob/main/SECURITY.md) | private reporting, or the maintainer's GitHub profile to agree a channel | about 5 business days, then about 10, best effort | the latest release only, no end date | not stated | not stated |
| [FerroCHART](https://github.com/FerroHEALTH/FerroCHART/blob/main/SECURITY.md) | private reporting, or the maintainer's GitHub profile to agree a channel | about 5 business days, then about 10, best effort | the latest release only, no end date | not stated | not stated |

The email address info@cadasto.com reaches the manufacturer of every product,
whichever routes a product's file names. The duties of CRA Art. 13 and Annex
I, the support period among them, bind the releases placed on the market from
11 December 2027; the reporting of Art. 14 binds every release now.
