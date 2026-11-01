# Annex III 4: verification and validation results

Revised 2026-11-01.

EHDS Annex III point 4 ([EUR-Lex](https://eur-lex.europa.eu/eli/reg/2025/327/oj)): "The results and
critical analyses of all verifications and validation tests undertaken to
demonstrate conformity of the EHR system with the requirements laid down in
Chapter III, in particular the applicable essential requirements." EHDS
Art. 37(2) adds "a reference to the results obtained from a European digital
testing environment referred to in Article 40". CRA Annex VII point 6
([EUR-Lex](https://eur-lex.europa.eu/eli/reg/2024/2847/oj)) asks for "reports of the tests carried out to
verify the conformity of the product with digital elements and of the
vulnerability handling processes with the applicable essential cybersecurity
requirements as set out in Parts I and II of Annex I".

## What exists

- **The logging component's controls (Annex II 1.1 and 3).** The
  [hazard log](https://ferroehr.eu/docs/latest/compliance/hazard-log.html) names, for each
  hazard, the tests that show its control holds, by file and test name; the
  Annex II 3.2 elements are asserted field by field in
  `app/ferroehr/tests/it/audit_ehds_mapping.rs`, including the gaps. That the
  tamper chain covers every column of a record is asserted in
  `app/ferroehr/tests/it/audit_chain.rs`
  (`the_current_digest_covers_every_column`,
  `every_hashed_column_is_tamper_evident`), which fails when a migration adds
  a column the current digest version does not cover; that the DICOM and FHIR
  renderings give the client and the server one data-flow role is asserted in
  `app/ferroehr/src/system_log/fhir.rs`
  (`dicom_and_fhir_agree_on_the_data_flow_direction`). The tests run on every
  pull request and their results are the CI runs of the release commit. The
  shared crates `ehds-logging` and `ihe-atna` carry their own tests in
  FerroAUDIT (<https://github.com/FerroHEALTH/FerroAUDIT>): the six category
  codes against the vendored HL7 Europe packages, the written records against
  the vendored BALP patterns and the store-and-forward against the vendored
  ITI-20 text; they run on every FerroAUDIT pull request and before each of
  its releases.
- **Annex II, row by row.** The
  [readiness record](readiness.md) gives
  the status and the evidence for each requirement, read against the text on
  the date it names. It is the critical analysis; it is the manufacturer's,
  and no authority has examined it.
- **The openEHR specifications.** FerroEHR's conformance record under
  `docs/conformance/ferroehr/`: `results.json` and `summary.md`, the run of the
  latest released Veredictum profile, an independent instrument, against a
  composed deployment. It gives the BASE and the OPTIONS result, the badges in
  FerroEHR's README show the same, and FerroEHR publishes it on its
  [conformance page](https://ferroehr.eu/docs/latest/conformance.html). It
  names no conformance tier and no certificate. It shows conformity to the
  openEHR specifications, which is not conformity to Annex II.
- **The CRA Annex I requirements.** The evidence and the status of each point
  of Part I(2) and Part II in the
  [risk assessment](https://ferroehr.eu/docs/latest/compliance/cra-risk-assessment.html),
  and the security tests listed in
  [`cra-annex-vii-2-design-and-vulnerability-handling.md`](https://github.com/FerroHEALTH/FerroEHR/blob/main/docs/technical-documentation/cra-annex-vii-2-design-and-vulnerability-handling.md).

## What is missing

- **The European digital testing environment (EHDS Art. 40).** Art. 40(3) has
  the manufacturer use it before placing an EHR system on the market and put
  the results here. The Commission has not published it, and its common
  specifications under Art. 40(4) have not been adopted. Running it against
  the logging component, and linking its results here, is [FerroEHR#3620](https://github.com/FerroHEALTH/FerroEHR/issues/3620).
- **A test report per release.** The test results exist as CI runs and
  committed records, not as one report bound to each release. CRA Annex VII 6
  applies from 11 December 2027.

State: partial.
