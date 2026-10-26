# Annex III 6: a copy of the EU declaration of conformity

Revised 2026-10-26.

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

State: missing.
