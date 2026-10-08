# Licensing and trademarks

Revised 2026-10-08.

Every FerroHEALTH product is source-available under the Business Source
License 1.1 (SPDX `BUSL-1.1`), with Cadasto B.V. as the Licensor. This page
states the terms every product shares, how to arrange a commercial licence,
the terms of the FerroHEALTH names and artwork, and the terms under which
contributions are accepted. It is a summary for evaluators and deployers, not
legal advice.

## Each product's `LICENSE` is the authority

The Business Source License 1.1 is a template: its parameters (the Licensor,
the Licensed Work, the Additional Use Grant, the Change Date) are filled in by
each product. Each product's own `LICENSE` is the text that applies to it:

| Product | Licence |
|---|---|
| FerroCHART | [`LICENSE`](https://github.com/FerroHEALTH/FerroCHART/blob/main/LICENSE) |
| FerroEHR | [`LICENSE`](https://github.com/FerroHEALTH/FerroEHR/blob/main/LICENSE) |
| FerroTERM | [`LICENSE`](https://github.com/FerroHEALTH/FerroTERM/blob/main/LICENSE) |
| FerroBRIDGE | [`LICENSE`](https://github.com/FerroHEALTH/FerroBRIDGE/blob/main/LICENSE) |
| FerroFED | [`LICENSE`](https://github.com/FerroHEALTH/FerroFED/blob/main/LICENSE) |
| FerroPIX | [`LICENSE`](https://github.com/FerroHEALTH/FerroPIX/blob/main/LICENSE) |
| FerroSMART | [`LICENSE`](https://github.com/FerroHEALTH/FerroSMART/blob/main/LICENSE) |
| FerroSYS | [`LICENSE`](https://github.com/FerroHEALTH/FerroSYS/blob/main/LICENSE) |
| FerroTASK | [`LICENSE`](https://github.com/FerroHEALTH/FerroTASK/blob/main/LICENSE) |

The Business Source License 1.1 is not an OSI-approved open-source licence,
and no product claims that it is. A product may publish some of its parts
under another licence, such as the Apache-2.0 `openehr-*` model crates of
FerroEHR; its own book says which parts and why.

## Do you need a commercial licence?

The same boundary holds for every product, in the order people ask about it:

| What you are doing | What you need | Why |
|---|---|---|
| Reading, building, modifying or redistributing the source | Free | The licence grants it without a fee and without asking anyone. |
| Development, testing, evaluation, prototyping | Free | All non-production use is granted. |
| Production use for Non-Commercial Purposes | Free | Personal use, academic or scientific research, teaching, and use by a non-profit organisation or public body that is not in the course of a business, does not deliver a service for payment, and is not for commercial advantage. |
| A hospital, clinic or care provider running it for its patients | Commercial licence | Delivering health care, or any other service for payment, is production use outside the grant. |
| A vendor or integrator, or any company running it in production | Commercial licence | Production use in the course of a business is outside the grant. |
| Offering it, or a work derived from it, to third parties as a hosted, managed or embedded service | Commercial licence | Excluded from the grant in every case, whoever you are. |
| Selling, sublicensing or otherwise distributing it for a fee | Commercial licence | Excluded from the grant in every case, whoever you are. |

The last two rows hold whatever else you are: they need a commercial licence
even for an organisation the rows above would otherwise leave free.

### What counts as a hosted service

The Additional Use Grant excludes offering a product "to third parties as a
hosted, managed, or embedded service". Each product's `LICENSE` says what such
a service is for that product, meaning a service through which anyone other
than you and your affiliates:

| Product | does this through it |
|---|---|
| FerroCHART | builds, renders, or captures health data |
| FerroEHR | stores, manages, or queries health data held by it |
| FerroTERM | stores, manages, or queries terminology, code system content, or health data held by it |
| FerroBRIDGE | maps, converts, or exchanges health data |
| FerroFED | discovers, queries, or exchanges health records across organisations |

The planned products' licences are in their repositories, linked above.

## The Change Date

Each version of each product becomes available under the Apache License 2.0,
its Change License, four years after that version is published. The licence
ties the change to the version's publication date and to nothing else.

## Arranging a commercial licence

A commercial licence is arranged with Cadasto B.V., the Licensor, which
handles the business side of every product: write to
[info@cadasto.com](mailto:info@cadasto.com) or use
<https://www.cadasto.com/contact/>. Companies and care providers building on a
FerroHEALTH product are welcome, and the commercial licence is the normal path
for them. Technical questions go to the maintainer, Ruben Talstra
(`@rubentalstra` on GitHub), through the product's repository. How a
commercial licence is installed in a running product is in that product's
book; FerroEHR's is in its
[licensing page](https://ferroehr.eu/docs/latest/licensing.html).

## Trademarks and brand terms

The names FerroHEALTH, FerroCHART, FerroEHR, FerroTERM, FerroBRIDGE,
FerroPIX, FerroSMART, FerroFED, FerroSYS and FerroTASK, the FerroHEALTH mark
with its icon and lockup variants, and the architecture diagram are covered by
the FerroHEALTH brand terms,
[`TRADEMARKS.md`](https://github.com/FerroHEALTH/FerroHEALTH/blob/main/TRADEMARKS.md).
The artwork is copyright Cadasto B.V., all rights reserved, and is not
licensed under Apache-2.0 or any other open licence. The Apache License 2.0
grants no right to the names or the marks either (its section 6).

**What you may do.** Use the names, and the marks and the diagram unmodified,
to refer to the projects: in an article, a talk, a slide or a review; to link
to a project or show which of them you build on, deploy or integrate with; and
to show how the projects fit together. You may scale a mark or the diagram,
and convert it to another file format, provided the result looks the same.

**What needs permission from Cadasto B.V.:**

- a modified mark: recoloured, reordered, redrawn, combined with another mark,
  or with its wordmark set in another typeface;
- a name or a mark in the name or the logo of your own product, service,
  company, domain or social account;
- a use that suggests Cadasto B.V. endorses, sponsors or maintains your work
  when it does not;
- merchandise.

A fork of a product may say that it is derived from that product. It does not
carry the product's name or mark as its own. Ask at
[info@cadasto.com](mailto:info@cadasto.com) or
<https://www.cadasto.com/contact/>.

Each product's own mark is in its repository under that repository's terms.

**Other organisations' marks.** openEHR® is a registered trademark of the
openEHR Foundation. HL7® and FHIR® are registered trademarks of Health Level
Seven International. SNOMED CT® is a registered trademark of SNOMED
International. None of these organisations endorse FerroHEALTH.

## Contributions

The five released products accept contributions on the same terms. By
submitting a contribution to one of them you:

1. certify that you wrote it, or otherwise have the right to submit it under
   these terms;
2. license it under the licence of the files it changes: for the product's own
   code, the Business Source License 1.1 as applied to the version it lands
   in, including that version's Change License, so it becomes Apache 2.0 with
   the rest of that version. A product that publishes some parts under
   another licence names them in its `CONTRIBUTING.md`; and
3. grant the Licensor named in `LICENSE`, Cadasto B.V., a perpetual,
   irrevocable, worldwide, royalty-free, transferable right to use, reproduce,
   modify, distribute, sublicense and relicense the contribution as part of
   the Licensed Work under any terms, including commercial licences.

You keep your copyright. Point 3 is what lets each product stay one work with
one licensor: a commercial licence, a change of the licence parameters, or a
transfer of the project can then cover every line, not only the maintainer's
own. There is no separate agreement to sign: each repository's pull request
template carries a checkbox recording your acceptance of these terms, and a
pull request from a person does not merge without it (the
`contribution-licence-guard` check).

This site and its documentation, including this book, are Apache-2.0
([`LICENSE`](https://github.com/FerroHEALTH/FerroHEALTH/blob/main/LICENSE)),
and contributions to them follow the same three points with Apache-2.0 in
point 2
([`CONTRIBUTING.md`](https://github.com/FerroHEALTH/FerroHEALTH/blob/main/CONTRIBUTING.md#licensing-of-contributions)).
