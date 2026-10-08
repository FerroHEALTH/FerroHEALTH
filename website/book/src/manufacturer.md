# The manufacturer

Revised 2026-10-08.

Cadasto B.V. is the manufacturer of every FerroHEALTH product and the
Licensor named in each product's `LICENSE`. This page gives its details and
says what being the manufacturer covers.

> [!WARNING]
> The quotations are from the Official Journal texts at EUR-Lex: the
> [CRA](https://eur-lex.europa.eu/eli/reg/2024/2847/oj), Regulation (EU)
> 2024/2847, and the [EHDS](https://eur-lex.europa.eu/eli/reg/2025/327/oj),
> Regulation (EU) 2025/327. The exact texts these pages were checked against
> are vendored in the FerroEHR repository under
> [`docs/law/eu/`](https://github.com/FerroHEALTH/FerroEHR/tree/main/docs/law/eu),
> each with its provenance and digest.

## Contact details

| | |
|---|---|
| Name | Cadasto B.V. |
| Postal address | Comeniusstraat 2d, 1817 MS Alkmaar, The Netherlands |
| Single point of contact | [info@cadasto.com](mailto:info@cadasto.com) |
| Website | <https://www.cadasto.com/contact/> |

EHDS Art. 30(1)(g) has the manufacturer of an EHR system "indicate the name,
registered trade name or registered trade mark, the postal address, and the
website, email address or other digital contact details through which they
can be contacted", with "a single point at which the manufacturer can be
contacted". CRA Art. 13(17) asks a manufacturer for "a single point of contact
to enable users to communicate directly and rapidly with them". The address
above is that point for every product: a complaint, an incident report, a
vulnerability report by email, a licensing question and a request from an
authority all go there.

## What the manufacturer is

CRA Art. 3(13) defines the manufacturer as "a natural or legal person who
develops or manufactures products with digital elements or has products with
digital elements designed, developed or manufactured, and markets them under
its name or trademark, whether for payment, monetisation or free of charge".

Cadasto B.V. places each tagged release of each product on the market. A
release is one product with digital elements: the source archive and the
binaries, images and charts that the product's release lane publishes for
that tag. What a release contains is product-specific, so each product lists
it:

| Product | What one release contains |
|---|---|
| FerroEHR | the `ferroehr` binaries, the `ferroehr`, `ferroehr-viewer` and `ferroehr-postgres` container images, the Helm chart and the source archive ([FerroEHR's CRA page](https://ferroehr.eu/docs/latest/compliance/cra.html)) |
| FerroFED | the source tag, the binary tarballs, and the gateway and console images ([FerroFED's regulatory status](https://ferrofed.eu/docs/evaluate/regulatory-status.html)) |
| FerroCHART, FerroTERM, FerroBRIDGE | the release assets each repository's `SECURITY.md` lists under how a release is verified |

An organisation that runs a release for itself puts that product into service.
It does not become the manufacturer by doing so. Whether an organisation that
modifies the source and runs the result becomes one is among the
[questions for counsel](cra.md#questions-for-counsel).

## Who handles what

| Who | What |
|---|---|
| Cadasto B.V. | The business side of every product: commercial licences, complaints, the decision whether an event is a serious incident or an actively exploited vulnerability, and every report to an authority. |
| The maintainer, Ruben Talstra (`@rubentalstra` on GitHub) | The technical side: code, review, releases, the issue trackers, and private vulnerability reports. The maintainer drafts the advisories and the reports Cadasto B.V. sends. |

## Where a product names its manufacturer

EHDS Art. 30(1)(g) asks for the details "in the EHR system", so a product
that Cadasto B.V. declares as an EHR system shows them when it runs. FerroEHR
prints them on its startup banner and in `ferroehr --version`, and serves them
on `GET /management/info`. FerroFED names them on `GET {base}/`,
`OPTIONS {base}/`, its startup banner and `ferrofed --version`. Each product's
book says where else it shows them.

## Certification

Cadasto B.V. holds ISO 9001, ISO/IEC 27001 and NEN 7510 certification for its
management system. A certificate covers the organisation within its certified
scope. It never makes a product certified, and no page in this book or in a
product's book calls a product certified. Whether the certified scope covers
the development and release of the FerroHEALTH products, and a service
Cadasto B.V. hosts for others, is an
[open point](post-market.md#open-points).
