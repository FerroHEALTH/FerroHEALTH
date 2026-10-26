# The EHDS EHR system: instructions for use

Revised 2026-10-26.

These are the instructions for use of the EHR system that FerroEHR and
FerroBRIDGE form together. A copy accompanies each release of either product,
free of charge, as the EHDS (Regulation (EU) 2025/327) asks: "clear and
complete instructions for use" (Art. 30(1)(d)). They say what each product
needs to run, how to set up a deployment in the European Union, what
maintenance it needs and how often (Art. 30(1)(k)), and the limitations of its
interoperability and security features that you should know before you rely
on it (Art. 28(b)). The [information sheet](information-sheet.md) accompanies
them.

Most of what these instructions point to is documented in detail in each
product's own book; this page is the route through it, and the order to take
it in.

<!-- toc -->

> [!NOTE]
> This page holds what stays true from one release to the next. The copy a
> release carries is cut from the revision of this page that the release
> pins, its links to the product's book point at the book of that release,
> and the release lane appends that release's own facts under "This copy":
> the version of each product, the release date and the versions of the
> platforms below. Use the copy of the release you run. The quotations are
> from the Official Journal texts at EUR-Lex: the
> [EHDS](https://eur-lex.europa.eu/eli/reg/2025/327/oj) and the
> [CRA](https://eur-lex.europa.eu/eli/reg/2024/2847/oj). Following these
> instructions does not make a deployment meet any regulation; the duties of
> the controller and the processor stay theirs
> ([shared responsibility](shared-responsibility.md)).

## Who these instructions are for

The EHR system is installed and operated in one of two ways:

- **Self-hosted.** A healthcare provider runs the instances for its own
  records, or has a processor run them on its behalf. The provider's
  operators, or the processor's, follow these instructions. Cadasto B.V. is
  the manufacturer and does not operate the instances.
- **Hosted by Cadasto B.V.** Cadasto B.V. runs the instances as a service for
  a customer, under a GDPR Art. 28 processing contract. Cadasto B.V.'s
  operators follow these instructions, and the customer reads them to know
  what the service is set up to do and what stays with the customer as
  controller.

Either way each instance serves one organisation. The clinical applications
connected to the system are developed against FerroEHR's
[REST API](https://ferroehr.eu/docs/latest/using-the-api/index.html) and [AQL](https://ferroehr.eu/docs/latest/querying-aql.html), and
against FerroBRIDGE's [FHIR face](https://ferrobridge.eu/docs/integrate/fhir-facade.html).

## The two products, and how they meet

FerroEHR is the Clinical Data Repository: it holds the records and the access
log. FerroBRIDGE reads and writes FerroEHR over the openEHR REST API and gives
the records a FHIR face, an OMOP Common Data Model export and an HL7 Version 2 entry
point. FerroEHR's record stays the record: FerroBRIDGE's identity map holds no
clinical content, and its OMOP export is a copy written into a database you
provide. Install FerroEHR
first, then point FerroBRIDGE at it ([how the products fit
together](../architecture.md)). A deployment that needs only the record and
its access log can run FerroEHR alone; the interoperability component of the
EHR system is FerroBRIDGE's.

## What it runs on

### What FerroEHR runs on

- **Platform:** Linux on x86_64 (amd64) or aarch64 (arm64). The published
  container images are distroless and run as a non-root user.
- **Forms:** the container images on Kubernetes through the Helm chart (the
  production path; "This copy" names the oldest Kubernetes release the chart
  accepts), on Docker Compose, or the `ferroehr` binary
  ([installation](https://ferroehr.eu/docs/latest/installation/index.html)).
- **Resources:** the Helm chart's defaults are two replicas, each requesting
  `cpu: 250m` and `memory: 256Mi` with limits of `cpu: "2"` and
  `memory: 1Gi` (`resources` in the chart's `values.yaml`). They are a
  starting point; size them for your load. No minimum hardware specification
  is published. The [performance](https://ferroehr.eu/docs/latest/performance.html) page records the
  hardware each measured run used.
- **Database:** a PostgreSQL cluster that you provide, at the release "This
  copy" names or newer. The Helm chart deploys none. The server installs the
  `btree_gist` extension.
- **Around it:** TLS termination, an OpenID Connect identity provider,
  database protection and a hardened platform, which FerroEHR relies on and
  does not provide
  ([the security environment FerroEHR assumes](https://ferroehr.eu/docs/latest/compliance/intended-purpose.html#the-security-environment-ferroehr-assumes)).

### What FerroBRIDGE runs on

- **Forms:** one distroless container image and the `ferrobridge` binary
  ([the container image](https://ferrobridge.eu/docs/operate/container.html)). FerroEHR's Helm chart
  can run it beside the CDR.
- **State:** the FHIR face keeps its identity map in one file on a persistent
  volume, one process per file ([the identity store](https://ferrobridge.eu/docs/operate/container.html#the-identity-store)).
  The OMOP export writes into a PostgreSQL database you provide.
- **Around it:** the FerroEHR instance it reads, the deployment's authorization
  server, and, when codes are checked, a FHIR terminology server
  ([deployment shape](https://ferrobridge.eu/docs/operate/deployment-shape.html)).

## Installing

### Installing FerroEHR

1. Choose the path and install: [Kubernetes & Helm](https://ferroehr.eu/docs/latest/installation/kubernetes.html)
   for production, [Docker Compose](https://ferroehr.eu/docs/latest/installation/compose.html) for
   evaluation. The quickstart Compose file runs a development user with
   access control off; never put real patient data into it.
2. Check what you pulled before you run it
   ([verifying releases](https://ferroehr.eu/docs/latest/verifying-releases.html)).
3. Pin the image by digest and the chart by version
   ([pin two versions](https://ferroehr.eu/docs/latest/installation/kubernetes.html#pin-two-versions-not-one)).
4. Harden the cluster the chart runs in
   ([cluster hardening](https://ferroehr.eu/docs/latest/installation/kubernetes-hardening.html)).

### Installing FerroBRIDGE

1. Run the image or the binary with its configuration file
   ([configuring the server](https://ferrobridge.eu/docs/operate/configuration.html)), pointed at the
   FerroEHR instance under `[cdr]`.
2. Pin the image by digest, and read which version line you are on
   ([version lines and releases](https://ferrobridge.eu/docs/operate/versions-and-releases.html)).

## Configuring a deployment in the European Union

These are the settings a deployment that holds real patient data in an EU
Member State sets. Each links its reference.

### FerroEHR settings

#### The deployment profile

```toml
deployment_profile = "production"
deployment_accepts = []
```

The shipped default is `sandbox`, which must not hold real personal data.
`production` refuses to start while a separation is open and not accepted by
name in `deployment_accepts`: shared database credentials or clusters, an
undeclared pseudonym namespace, the access log off or failing open, the open
per-EHR access default, migrations on a runtime
credential, authentication off, the role gate off while authentication is
on, a plaintext listener on a routable address
(the separate management port included), change events published to a plain
`amqp://` broker, an audit FHIR feed on an `http://` URL, a multimedia store
with `allow_http = true`. Each refusal names the gap
and what to change
([`deployment_profile`](https://ferroehr.eu/docs/latest/installation/configuration.html#deployment_profile)).
A gap you accept by name is stated on every boot and on
`GET /management/status`. Behind a TLS-terminating ingress you accept
`plaintext_listener` by name. The Helm chart and the Compose files declare
`sandbox`, the binary's default. On Kubernetes, install with the chart's
`values-production.yaml`. It sets `production`, makes the separations a values
file can make, and accepts `plaintext_listener` behind a TLS ingress; separate
database clusters come from the connection strings you give it
([the production overlay](https://ferroehr.eu/docs/latest/installation/kubernetes.html#the-production-overlay)).
Replace its example names with your own.

#### The access log

```toml
[audit]
enabled = true
fail_mode = "closed"
purpose_codes = ["TREAT", "ETREAT"]   # the codes you agree with your callers
emergency_purpose_codes = ["ETREAT"]  # marks an EHDS Art. 11(5) emergency access
legal_basis = "gdpr-art-9-2-h"

[audit.store]
enabled = true
retention_years = 5                   # at or above the floor that applies to you

[audit.syslog]                        # or [audit.fhir_feed] for a FHIR ARR
enabled = true
host = "arr.example.org"              # RFC 5425 TLS on port 6514
```

- **Fail closed.** `fail_mode = "closed"` refuses an operation whose access
  record cannot be taken, with a `503`. The shipped `open` serves it and
  counts the loss.
- **Forward a copy off the box.** The local store shares the database it
  audits. Forward the log to a sink the server's own credentials cannot
  rewrite, over TLS syslog or the FHIR feed
  ([getting the log out](https://ferroehr.eu/docs/latest/audit.html#getting-the-log-out)).
- **Retention.** Set `[audit.store] retention_years` (or `retention_days`).
  In every EU Member State the server refuses a horizon shorter than three
  years (EHDS Art. 9(2)), and five years in the Netherlands, for the
  jurisdictions your `[privacy.identifier_scan]` rules name; `0` keeps every
  record forever
  ([retention, and who chooses it](https://ferroehr.eu/docs/latest/audit.html#retention-and-who-chooses-it),
  [`[audit.store]`](https://ferroehr.eu/docs/latest/installation/config-audit.html#auditstore-the-local-audit-record-repository)).
- **The priority categories.** Declare which of your templates carry which
  EHDS Art. 14(1) category in `[audit.categories]`, so every access record
  names the categories it served (Annex II 3.2(c)). FerroEHR ships no map, and
  without one every access is recorded `unclassified`
  ([`[audit.categories]`](https://ferroehr.eu/docs/latest/installation/config-audit.html#auditcategories)).
  The same map keys retention periods on a category
  ([retention by category](https://ferroehr.eu/docs/latest/compliance/retention.html#keying-a-period-on-a-priority-category)).

#### Authentication and access

- Authenticate through your OpenID Connect provider
  ([enterprise identity providers](https://ferroehr.eu/docs/latest/identity-providers.html)). Basic
  authentication is for service accounts and development.
- Declare the assurance level patient data requires in
  [`[authz.assurance]`](https://ferroehr.eu/docs/latest/installation/config-auth.html#authzassurance-the-assurance-level-patient-data-requires),
  mapping each `acr` value your identity provider emits to an eIDAS level, and
  declare how a token names the natural person in
  [`[authz.professional]`](https://ferroehr.eu/docs/latest/installation/config-auth.html#authzprofessional-the-natural-person-behind-a-token).
  Both are off by default: until you configure them your identity provider
  alone decides the assurance level, and a token issued to a client
  application is recorded as that client, not as a person.
- Set `[authz.rbac] ehr_access_default = "restricted"` and write the per-EHR
  access settings, or accept `open_ehr_access_default` by name with the reason
  ([per-EHR access control](https://ferroehr.eu/docs/latest/security.html#per-ehr-access-control-ehr_access)).

#### The pseudonymisation boundary and identifiers

Give the demographic and linkage domains their own database credentials,
declare your pseudonym namespaces, keep the identifier scanner strict, and
turn on national-identifier sealing if you store national identifiers
([go-live checklist](https://ferroehr.eu/docs/latest/security/go-live-checklist.html),
[privacy and data minimisation](https://ferroehr.eu/docs/latest/installation/config-privacy.html)).

#### The usage report

Every deployment sends a usage report to Cadasto B.V. by default, at each start
and once a day, with no patient data ([usage report](https://ferroehr.eu/docs/latest/usage-report.html)).
Turn it off with `[usage_report] enabled = false`. A server started in a CI run
(`GITHUB_ACTIONS` or `CI` set to `true` or `1`) sends none, whatever the switch
says.

#### Before it holds real patient data

Walk the [go-live checklist](https://ferroehr.eu/docs/latest/security/go-live-checklist.html), and write the
[DPIA](https://ferroehr.eu/docs/latest/security/dpia.html) and the
[records of processing](https://ferroehr.eu/docs/latest/security/records-of-processing.html); they are the
controller's.

### FerroBRIDGE settings

- **Authenticate every caller.** `[auth]` is on by default, and the FHIR face
  refuses to start until it names an issuer and an audience. Setting
  `enabled = false` serves every request that reaches the face, reads and
  writes of patient data included, so do it only on a network that only
  trusted callers reach ([`[auth]`](https://ferrobridge.eu/docs/operate/configuration.html#auth)).
- **Give it its own credential to FerroEHR.** `[cdr.credentials]` holds the
  credential FerroBRIDGE presents to the CDR, as a file secret
  ([`[cdr.credentials]`](https://ferrobridge.eu/docs/operate/configuration.html#cdrcredentials-and-terminologycredentials)).
  FerroEHR's access log records FerroBRIDGE's accesses under it.
- **Pseudonymise the OMOP export** where the research use calls for it
  ([`[cdm.pseudonymisation]`](https://ferrobridge.eu/docs/operate/configuration.html#cdmpseudonymisation)).
- **The usage report.** FerroBRIDGE sends its own usage report, on by default
  and with no patient data; switch it off with
  `FERROBRIDGE__USAGE_REPORT__ENABLED=false` ([the usage report](https://ferrobridge.eu/docs/operate/usage-report.html)).

## Maintenance, and how often

EHDS Art. 30(1)(k) has the manufacturer inform users "of any mandatory
preventive maintenance of the EHR systems and its frequency". Cadasto B.V.
treats the first four rows of FerroEHR's table as mandatory for a deployment
holding patient data.

### FerroEHR maintenance

| Maintenance | How often | How |
|---|---|---|
| Apply security updates | as soon as a release carries one; only the newest release is supported, and Cadasto B.V. publishes security fixes for at least five years after each release, only in the newest release (CRA Art. 13(8) and (10)) | subscribe to the release feed and poll the security advisories ([how long a version is supported](https://ferroehr.eu/docs/latest/operations.html#how-long-the-version-you-pinned-is-supported)), then [upgrade](https://ferroehr.eu/docs/latest/operations.html#upgrades); the server's `support.status` reads `ended` once the end month of the commitment has passed |
| Take and test backups, one per domain | daily backups (the chart's backup jobs run nightly when enabled); a restore test at least once a year and after each upgrade that migrates the schema | [backup and point-in-time recovery](https://ferroehr.eu/docs/latest/operations.html#backup-and-point-in-time-recovery) |
| Act on an access-log chain finding | the server verifies the chain daily by default (`[audit.store] verify_interval_seconds = 86400`); act on every finding | the `audit_chain` readiness indicator and the `atna_audit_chain_findings` metric ([tamper evidence](https://ferroehr.eu/docs/latest/audit.html#tamper-evidence)) |
| Watch the access log's loss counters | continuously, with an alert | the `atna_audit_*` metrics ([observability](https://ferroehr.eu/docs/latest/operations.html#observability)) |
| Review the access log | on the schedule your organisation's policy sets | ITI-81 retrieval or your forwarding sink ([audit trail](https://ferroehr.eu/docs/latest/audit.html)) |
| Sweep for stale decomposition | after a release whose changelog says so | [storage integrity](https://ferroehr.eu/docs/latest/operations-admin-apis.html#storage-integrity) |
| Rotate the national-identifier key | on your key policy, and at once if the key is exposed | [rotating the key](https://ferroehr.eu/docs/latest/operations.html#rotating-the-national-identifier-key) |
| Read the retention due list | on your retention schedule | [reading what is due](https://ferroehr.eu/docs/latest/compliance/retention.html#reading-what-is-due) |

The retention reaper of the access log runs hourly by itself and needs no
action.

### FerroBRIDGE maintenance

| Maintenance | How often | How |
|---|---|---|
| Apply security updates | as soon as a release carries one; the same support rule holds for every FerroHEALTH product ([security](../security.md)) | [version lines and releases](https://ferrobridge.eu/docs/operate/versions-and-releases.html) |
| Back up the identity map with the CDR | with every FerroEHR backup | [the identity store](https://ferrobridge.eu/docs/operate/container.html#the-identity-store) |

## Limitations you should know

EHDS Art. 28(b) prohibits "failing to inform the professional user of likely
limitations related to interoperability or security features of the EHR
system in relation to its intended purpose". These are the ones Cadasto B.V.
knows of for this release.

### FerroEHR: interoperability

- FerroEHR does not provide or receive the European electronic health record
  exchange format. FerroBRIDGE carries it, and its content waits on
  implementing acts under EHDS Art. 15(1) that have not been adopted.
- FerroEHR maps no FHIR resources. FHIR mapping is FerroBRIDGE's; FerroEHR
  uses FHIR for the access log's `AuditEvent` (with the ITI-81 retrieval) and
  for its terminology server only. A configuration that still carries
  `[fhir]` or `[fhir.outbound]` is refused at boot as unknown keys.
- Of the access-log renderings, the DICOM message carries neither the
  accessing organisation, the purpose, the origins nor the categories, because
  DICOM PS3.15 defines no element for them; the FHIR `AuditEvent` carries all
  four.
- Records in the demographic domain carry no priority category, because no
  priority category lives there
  ([audit trail](https://ferroehr.eu/docs/latest/audit.html#the-ehds-logging-elements-mapped)). Every other
  access record carries one, `none` or `unclassified` included.
- The AQL specification FerroEHR implements does not define how many rows a
  path through a repeated node returns, or how a `WHERE` test reads several nodes. FerroEHR returns one row
  per node and evaluates `WHERE` as one assignment of those nodes
  ([querying with AQL](https://ferroehr.eu/docs/latest/querying-aql.html)); another openEHR server may return
  other rows for the same query. A client written against an earlier FerroEHR
  release that expects one row per composition has to group the rows; the
  FerroEHR changelog names the release that changed it.

### FerroEHR: security

- The shipped defaults favour a first boot: the `sandbox` profile, TLS off,
  the open per-EHR access default, the access log failing open. The
  `production` profile refuses them unless accepted by name.
- No authentication assurance level is required, and no natural person is
  asked of a token, until `[authz.assurance]` and
  `[authz.professional]` are configured.
- An emergency access in the vital interest of the patient (EHDS Art. 11(5))
  is marked only when the caller declares one of
  `[audit] emergency_purpose_codes`
  ([the emergency mark](https://ferroehr.eu/docs/latest/audit.html#emergency-access-ehds-art-115)). The
  mark alone lifts no restriction. An EHDS Art. 8 restriction is lifted only
  for a caller holding `authz.rbac.emergency_access_role` that declares an
  emergency purpose
  ([restriction of access](https://ferroehr.eu/docs/latest/security.html#restriction-of-access-by-health-professionals-ehds-art-8)).
- An access record written before FerroEHR extended the digest of its tamper
  chain (the FerroEHR changelog names the release) keeps the original digest,
  which leaves out the purpose, legal basis,
  categories, authentication fields and the emergency mark; for those records
  only the append-only trigger, which the table owner can disable, protects
  those columns ([tamper evidence](https://ferroehr.eu/docs/latest/audit.html#tamper-evidence)).
- Clinical content is not encrypted by the application at rest; encryption at
  rest is the database's and the disk's
  ([the justification](https://ferroehr.eu/docs/latest/compliance/cra-risk-assessment.html#application-level-encryption-at-rest-annex-i-part-i2e)).
- Physical deletion and `ferroehr db erase` remove rows, schemas and blobs;
  they do not reach filesystem blocks, WAL archives, replicas or backups
  ([what the erase does not reach](https://ferroehr.eu/docs/latest/operations-decommissioning.html#what-the-erase-does-not-reach)).
- Anyone with a database connection is past every API control, the access log
  included ([the database](https://ferroehr.eu/docs/latest/threat-model.html#b6--the-database)).
- Structural validation checks structure, invariants and terminology
  bindings, not clinical correctness.

The full list of foreseeable misuse, with what FerroEHR does about each, is in
the [intended purpose](https://ferroehr.eu/docs/latest/compliance/intended-purpose.html#reasonably-foreseeable-use-and-misuse);
the risk that survives each control is in the [threat model](https://ferroehr.eu/docs/latest/threat-model.html).

### FerroBRIDGE limitations

- FerroBRIDGE targets the HL7 Europe implementation guides as the proxy for
  the European electronic health record exchange format, which waits on the
  implementing acts under EHDS Art. 15(1). Which priority category has a
  proven mapping today is on its [EHDS readiness](https://ferrobridge.eu/docs/evaluate/ehds-readiness.html)
  page and in the system's [readiness record](readiness.md).
- How the FHIR face behaves when FerroEHR or the terminology server fails, and
  what a lost identity map does, is on
  [failure and identity behaviour](https://ferrobridge.eu/docs/operate/failure-and-identity.html).

## Taking a deployment out of service

Export what you must keep ([EHR Extract](https://ferroehr.eu/docs/latest/beyond-core/messaging.html),
[dump](https://ferroehr.eu/docs/latest/operations-admin-apis.html#dump-and-load)), then remove all data and
settings with `ferroehr db erase` and remove what it cannot reach (backups, WAL
archives, replicas, the chart's Secrets and claims, the database roles and
the configuration files) under your own procedure. The steps and the retention
duties that come first are on [Decommissioning](https://ferroehr.eu/docs/latest/operations-decommissioning.html).

For FerroBRIDGE, remove the identity map file, the OMOP database and its
configuration files with the CDR; it keeps no other state.

## The CRA user information

Each product carries its own information and instructions to the user under
the Cyber Resilience Act (Annex II), point by point:
[FerroEHR](https://ferroehr.eu/docs/latest/compliance/cra-user-information.html) and
[FerroBRIDGE](https://ferrobridge.eu/docs/evaluate/cra-user-information.html). The notes of each
release link that product's page.

## Contact

Questions, complaints and serious incidents go to Cadasto B.V. at
[info@cadasto.com](mailto:info@cadasto.com). The manufacturer's post-market
procedure, which handles them for every FerroHEALTH product, is on
[post-market](../post-market.md).

## This copy

The release lane appends this section to the copy it attaches: the product
and release the copy accompanies, its release date, the oldest release of the
other product it is tested against, and the platform versions this page
refers to. This page in the book carries no such facts.
