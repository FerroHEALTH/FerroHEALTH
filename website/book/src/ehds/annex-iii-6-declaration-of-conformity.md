# Annex III 6: a copy of the EU declaration of conformity

Revised 2026-10-28.

EHDS Annex III point 6 ([EUR-Lex](https://eur-lex.europa.eu/eli/reg/2025/327/oj)): "A copy of the EU
declaration of conformity." CRA Annex VII point 7 ([EUR-Lex](https://eur-lex.europa.eu/eli/reg/2024/2847/oj))
asks for the same.

**No EU declaration of conformity has been drawn up.** EHDS Art. 39(1) has it
state that the manufacturer "has demonstrated that the essential requirements
laid down in Annex II have been fulfilled", and Annex IV points 4 and 6 have
it carry the result of the Art. 40 testing environment and the common
specifications applied. Neither exists: no Art. 36 common specification has
been adopted ([`annex-iii-3-common-specifications.md`](annex-iii-3-common-specifications.md)),
the testing environment is not published ([FerroEHR#3620](https://github.com/FerroHEALTH/FerroEHR/issues/3620)), and the exchange format of
Annex II 2.1 to 2.3 waits on implementing acts under Art. 15(1). Chapter III
applies to EHR systems from 26 March 2029 (EHDS Art. 105).

## When one is drawn up

- **One declaration for both acts.** EHDS Art. 39(2) and CRA Art. 28(3) ask
  for a single declaration where a product is subject to more than one Union
  act requiring one. It names the EHR system, FerroEHR and FerroBRIDGE, with
  the version of each and the version of the shared logging crate
  `ehds-logging` that FerroEHR's logging component is built on, and carries
  the content of EHDS Annex IV and CRA Annex V.
- **Where it is published.** EHDS Art. 39(4): a declaration drawn up in a
  digital format "shall be made accessible online for the expected lifetime of
  the EHR system and, in any event, for at least 10 years from the placing on
  the market or the putting into service of the EHR system". It is published
  as an asset of each GitHub release it covers, which is immutable, and as a
  page of the book frozen for that release; this file then links it, and CRA
  Annex II point 6 has the user information give its internet address.
- **How long it is kept.** For 10 years after the system it covers is placed
  on the market (EHDS Art. 30(3)), or for the support period if that is longer
  (CRA Art. 13(13)), in the places [`README.md`](https://github.com/FerroHEALTH/FerroEHR/blob/main/docs/technical-documentation/README.md) lists.
- **Languages.** Translated into the official Union languages the Member
  States where the system is made available require (EHDS Art. 39(3)).

## The draft

The draft below lays out what one declaration for both acts holds (EHDS
Annex IV, CRA Annex V), so the facts that exist are ready and the statements
that do not are named. **It is not a declaration of conformity.** Nobody has
signed it, no conformity assessment has been carried out, and points that
only the manufacturer can state after an assessment read "not made". It is
kept here, and not attached to any release, until Cadasto B.V., with counsel,
decides the release it first covers, settles the conformity-assessment route
([the CRA page](../cra.md#default-product-or-important-product) lists the open
question) and signs it ([FerroEHR#3696](https://github.com/FerroHEALTH/FerroEHR/issues/3696)).

> [!WARNING]
> DRAFT, NOT A DECLARATION. This text declares nothing. A product carries no
> CE marking on the strength of it, and no part of it may be quoted as a
> statement of conformity.

| Point | EHDS Annex IV | CRA Annex V | Draft content |
|---|---|---|---|
| Identification | 1. name of the EHR system, version, unambiguous reference | 1. name, type, unique identification; 4. object of the declaration, allowing traceability | The FerroHEALTH EHR system: FerroEHR, an openEHR clinical data repository with the European logging software component, and FerroBRIDGE, with the European interoperability software component (EHDS Art. 2(2)(n) and (o)). Each product by the release tag of the version covered, its container image digest and its signed release artefacts, and the version of the shared logging crate `ehds-logging` FerroEHR is built with. Filled from the release it first covers. |
| Manufacturer | 2. name and address | 2. name and address | Cadasto B.V., Comeniusstraat 2d, 1817 MS Alkmaar, The Netherlands ([the manufacturer](../manufacturer.md)). |
| Responsibility | 3. issued under the sole responsibility of the manufacturer | 3. issued under the sole responsibility of the provider | "This EU declaration of conformity is issued under the sole responsibility of Cadasto B.V." Not made until signed. |
| Conformity | 4. in conformity with Chapter III, complemented by the result from the testing environment of Art. 40 | 5. in conformity with the relevant Union harmonisation legislation | Not made. Annex II has not been shown fulfilled ([readiness](readiness.md) lists each requirement), the Art. 40 testing environment is not published, and no conformity assessment has examined the system. The acts it would name: Regulation (EU) 2025/327 and Regulation (EU) 2024/2847, in one declaration (EHDS Art. 39(2), CRA Art. 28(3)). |
| Standards | 5. harmonised standards used | 6. harmonised standards, common specifications or certification | Not made. No harmonised standard is cited for either act, and none is relied on. |
| Common specifications | 6. common specifications used | 6, as above | Not made. No common specification under EHDS Art. 36 has been adopted ([Annex III 3](annex-iii-3-common-specifications.md)). |
| Procedure | (the procedure of Chapter III) | 7. notified body, procedure performed, certificate | Not made. The route is the EHDS Chapter III procedure (CRA Art. 32(5a)); whether CRA Annex III class I applies, and so whether a notified body is involved, is a question for counsel ([the CRA page](../cra.md)). |
| Signature | 7. place and date, signature, name and function | 8. signed for and on behalf of, place and date, name, function, signature | Not made. |
| Additional information | 8. where applicable | 8. additional information | The internet address the declaration is published at, which the CRA user information gives (CRA Annex II point 6), and the translations Member States require (EHDS Art. 39(3)). |

State: missing. A draft exists; no declaration does.
