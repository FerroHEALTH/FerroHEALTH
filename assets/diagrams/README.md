<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Diagrams

One file per diagram, self-contained, so a diagram can be used outside this
site: a product README, the books, a slide, an issue.

| File | What it shows |
|---|---|
| `ferrohealth-architecture.svg` | what calls what across the four servers of the data path and the three services around them, with the shared libraries in a band under them |
| `ferrohealth-architecture.png` | the same at 2400x1608, for the rare consumer that renders no SVG at all |

## How it is drawn

The SVG is drawn by `scripts/diagrams/ferrohealth-architecture.py` and is
never edited by hand. Boxes and edges are declared in that script, and before
it writes it asserts what a reader would otherwise have to catch: no two boxes
overlap, every product sits inside the frame and every outside party outside
it, every edge starts and ends on the perimeter of its own box and passes
through no other, no two edges cross except where one declares a hop over the
other, no label touches a box, a line or another label, and every text fits its
box. A change to the picture is a change to the declarations:

```bash
python3 scripts/diagrams/ferrohealth-architecture.py assets/diagrams/ferrohealth-architecture.svg
```

`scripts/checks/diagram-generated.sh` redraws the SVG and fails CI when the
committed file differs, so a hand edit is undone by the next regeneration. The
script uses the standard library only.

## Using it

The landing page loads the SVG with `<img>`, and so can anything else:

```html
<img src="https://ferrohealth.eu/assets/diagrams/ferrohealth-architecture.svg"
     width="1200" height="804" alt="...">
```

In a Markdown file, reference the SVG:

```markdown
![What calls what across the FerroHEALTH family](assets/diagrams/ferrohealth-architecture.svg)
```

That works even where a renderer drops the `<style>` element, because every
colour is also a presentation attribute and the file paints its own ground. Such
a reader gets the light palette on the light surface, which is legible on a dark
page too.

Reach for `ferrohealth-architecture.png` only when the consumer renders no SVG
at all. `scripts/checks/svg-first.sh` fails a page or a document that uses the
raster while the vector is available.

Do not screenshot the page to get the diagram. The file is the diagram.

## What it says

The frame is one FerroHEALTH instance serving one tenant. The seven inside are
the family; clinicians, applications, HL7 FHIR, HL7 Version 2 senders, the OMOP
database and other organisations sit outside it. The family is five products
that reach each other only over published protocols, each in its own lane:
FerroEHR implements no FHIR, OMOP, federation or IHE profile, FHIR, OMOP and
clinical HL7 Version 2 are FerroBRIDGE's, federation is FerroFED's, and identity and
the IHE profiles are FerroPIX's. Every product is single-tenant: one instance serves
one organisation, and an organisation that serves several runs several
instances.

Left to right is the order data moves. The four servers are the data path:
FerroFORMS takes the record down, FerroEHR keeps it, FerroTERM gives its codes
meaning, FerroBRIDGE carries it out. FerroFORMS is paused and still drawn,
greyed out (a grey fill, outline and text, with "paused" in its box), because
it is present and not in use, which is not a server waiting to run.
FerroPIX, FerroFED and FerroTASK frame that path. A server not running yet is
drawn dashed, as is every call into one: FerroTASK is planned. FerroPIX and
FerroFED are released, running servers and are drawn solid, with every edge
into them.

Under the frame, a second band holds the shared libraries: FerroAUTH
(`ferrohealth-smart` and `ferrohealth-authz`, authentication and the policy
decision; renamed from FerroSMART on 2026-10-25), FerroAUDIT (`ihe-atna`,
`ehds-logging`), FerroUI (`ferrohealth-ui`) and FerroSYS (`ferrohealth-secret`,
`-config`, `-telemetry`, `-health`, `-server`, `-usage-report`: the system
plumbing every product shares, never a control plane or a central service). They sit outside the instance because they run inside the
products that compile them in, never on their own, and no edge reaches them
because nothing calls a library over the network. They carry no product hue.
The generator refuses a library box inside the instance frame, a hue or a
dashed outline on one, and an edge into one.

An arrowhead points at what is called or written to. The FHIR side carries one
at both ends, because the bridge reads openEHR out to FHIR and writes FHIR back
in, which is the same rule the FerroBRIDGE mark keeps. Each edge names the
specification it speaks, with a few exceptions worth knowing:

- **`FHIR facade`** names the exchange and no FHIR release. The facade speaks
  the release FHIRconnect's mappings name, and FerroBRIDGE's own site says
  which. FerroTERM's band names code systems for the same reason: the FHIR
  releases it serves are a fact its own site renders, and a list here would
  rot.
- **`SQL rows`** names no wire specification, because OMOP is a database schema.
  The OMOCL mappings compile to SQL that writes typed rows into the CDM tables.
- **No authorisation server is drawn.** Each product is its own SMART App
  Launch 2.x resource server, through FerroAUTH's `ferrohealth-smart`: it checks the
  tokens it is handed against the deployment's own authorization server,
  which sits outside the family. A
  central FerroHEALTH authorisation service would hold the signing key every
  product's access depends on, so there is none (owner, 2026-10-19).
- **FerroFED follows the openEHR federation tier proposal.** It is a
  transparent ITS-REST intermediary: an application sends it an ordinary AQL
  query and never learns it was federated. It asks FerroPIX who the patient
  is, over PIXm, and keeps no identity of its own, then dispatches standard AQL scoped to each
  node's own EHR id, to the local FerroEHR and to other organisations' CDRs
  alike, and merges what comes back with the node named. The line to the other
  organisations is therefore `ITS-REST, AQL` and runs one way; cross-community
  identity (XCPD) is FerroPIX's business, not the gateway's.
- **`PIXm, PDQm` is the CDR's lookup at the index, as a client.** FerroEHR
  implements no IHE profile and runs no identity of its own. It is to look
  the subject of an EHR up at FerroPIX (PIXm ITI-83, PDQm ITI-78), so the
  subject its EHR_STATUS carries can be the pseudonym FerroPIX mints. The
  gateway asks the index over PIXm. An application that opens a record asks
  it the same way. FerroFORMS receives the EHR it is launched with and asks
  nobody, so no line runs from the form to the index.
- **`MLLP` is the bridge's listener.** Clinical HL7 Version 2 messages come
  in on FerroBRIDGE's MLLP listener and are mapped through HL7's Version 2 to
  FHIR guide into the CDR. The HL7 Version 2 identity feed and queries go to
  FerroPIX; the diagram draws no outside sender for them.
- **FerroTASK is a client of the CDR.** openEHR Task Planning and GDL2 both
  read the patient's data by archetype and template path, so FerroTASK reads
  FerroEHR over `ITS-REST, AQL` and commits the state of each plan back, and
  keeps no clinical record of its own. It sits in one row with FerroPIX and
  FerroFED, the services around the data path, at the same size as both, and
  its line climbs into the CDR's lower edge left of the index's lookup.
- **No line crosses another.** The generator allows a crossing only where a
  hop is declared, and the drawing declares none.

`$validate-code` is the one operation FerroEHR uses, and the label says so. A
server that does not offer it is configured to `operation = "expand"` per
provider, which replaces `$validate-code` with `$expand` plus a membership test.
FerroEHR never retries one as the other, so drawing both on the edge would say
something the CDR does not do.

The evidence for every solid edge is in the products' own documents:
FerroBRIDGE's `website/book/src/integrate/fhir-facade.md` and
`operate/deployment-shape.md` for the terminology operations and the CDM write,
and FerroEHR's `website/book/src/installation/config-integrations.md` for
`$validate-code` as the default membership operation. FerroFED's edges are
its architecture, in its own repository, and its tracker is the record of the
build. FerroEHR's lookup at FerroPIX is FerroHEALTH/FerroEHR#3380, and
FerroPIX's README states the profiles it serves. A dashed edge is a design
intent: FerroTASK's read of the CDR.

## Colours and theme

The palette is `assets/brand/tokens.css`, written into the file as literal
values, because a standalone SVG cannot read the page's custom properties. The
media query inside the file swaps every colour on `prefers-color-scheme`, so one
file serves a light and a dark reader.

A product keeps its own hue: FerroFORMS rose, FerroEHR rust, FerroTERM teal,
FerroBRIDGE indigo, and the plum, azure and emerald of FerroPIX, FerroFED and
FerroTASK. FerroFORMS, paused, gives up its rose for grey. The
shared libraries, FerroSYS included, carry no hue. Everything else is iron,
steel and graphite.

## Regenerating the raster

```bash
rsvg-convert -w 2400 -h 1608 \
  assets/diagrams/ferrohealth-architecture.svg \
  -o assets/diagrams/ferrohealth-architecture.png
```

No `-b` flag: the ground is the SVG's own.

`scripts/site/assemble.sh` copies this directory to `assets/diagrams/` of the
assembled site, so both files resolve on <https://ferrohealth.eu/>.

## Licence

The diagram (the SVG and the PNG) is all rights reserved, under the terms in
[`TRADEMARKS.md`](../../TRADEMARKS.md): you may show it unmodified to describe
how the projects fit together. Its generator under `scripts/diagrams/` and
this README are Apache-2.0.
