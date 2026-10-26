# Annex III 2: the system in place to evaluate performance

Revised 2026-10-26.

EHDS Annex III point 2 ([EUR-Lex](https://eur-lex.europa.eu/eli/reg/2025/327/oj)): "A detailed
description of the system in place to evaluate the EHR system performance,
where applicable."

EHDS Annex II 1.1 measures the harmonised components against "the performance
intended by its manufacturer". The Regulation names no method, so the system
below is FerroEHR's own design.

## Throughput and latency

FerroEHR's performance is measured by Veredictum, an independent instrument
outside its repository, in open-loop runs on a closed ladder of deployment classes, each
with an offered-load floor, a p99 latency budget and a zero error budget. A
class is earned only by a measured run, and every run records the hardware it
ran on. The records are committed under FerroEHR's `docs/conformance/ferroehr/` and the
published figures are generated from them, so no number is typed:
[`performance.md`](https://ferroehr.eu/docs/latest/performance.html).

## Functional performance of the logging component

What the logging component is intended to do is stated per hazard in the
[hazard log](https://ferroehr.eu/docs/latest/compliance/hazard-log.html), each hazard with
the control and the tests that show the control holds. Those tests run on
every pull request (`cargo nextest run --workspace`), and the hazard log is
re-read against FerroEHR's code in every release that changes the component
(`.claude/rules/changelog.md`).

## In a running deployment

The server reports its own state: the readiness indicators on
`GET /health/readiness` (the audit chain verification among them), the
`atna_audit_*` metrics for every loss path of the access log, and the
deployment posture on the authenticated `GET /management/status`
([`operations.md`](https://ferroehr.eu/docs/latest/operations.html#observability)).

State: available. The performance a deployment reaches depends on the hardware
and the database the deploying organisation provides.
