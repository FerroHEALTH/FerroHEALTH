<!-- SPDX-FileCopyrightText: Cadasto B.V. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Diagrams

One file per diagram, self-contained, so a diagram can be used outside this
site: a product README, the books, a slide, an issue.

| File | What it shows |
|---|---|
| `ferrohealth-architecture.svg` | what calls what across the four servers of the data path and the four services around them |
| `ferrohealth-architecture.png` | the same at 2400x1512, for the rare consumer that renders no SVG at all |

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
     width="1200" height="756" alt="...">
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

The frame is one FerroHEALTH instance serving one tenant. The eight inside are
the family; clinicians, applications, HL7 FHIR, the OMOP database and other
organisations sit outside it. FerroEHR can host several isolated tenants in one
deployment as its own setting; the family shows the single-tenant setup, and an
organisation that serves several runs several instances.

Left to right is the order data moves. The four servers are the data path:
FerroCHART takes the record down, FerroEHR keeps it, FerroTERM gives its codes
meaning, FerroBRIDGE carries it out. FerroPIX, FerroSMART, FerroFED and
FerroSYS frame that path. The three still planned are drawn dashed, as is
every call into one of them; FerroFED has released and is drawn solid.

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
- **`OIDC, SMART launch` and `token introspection`** are the two sides of
  FerroSMART. FerroEHR carries the SMART on openEHR layer today: the discovery
  document, the launch context, the scope grammar and the gate that enforces
  it on every request. FerroSMART is that layer pulled out into a server of
  its own. FerroCHART is the application: it obtains its token and launch
  context there. FerroEHR asks it whether the token it is handed may do what
  it asks, and FerroTERM and FerroBRIDGE ask the same; those two lines are
  left to the caption.
- **FerroFED follows the openEHR federation tier proposal.** It is a
  transparent ITS-REST intermediary: an application sends it an ordinary AQL
  query and never learns it was federated. It resolves the patient first,
  through FerroPIX over PIXm, then dispatches standard AQL scoped to each
  node's own EHR id, to the local FerroEHR and to other organisations' CDRs
  alike, and merges what comes back with the node named. The line to the other
  organisations is therefore `ITS-REST, AQL` and runs one way; cross-community
  identity (XCPD) is FerroPIX's business, not the gateway's.
- **`PIXm feed` is how the index learns where records are.** The CDR is the one
  component that knows the moment an EHR is created or its subject changes, so
  FerroEHR feeds FerroPIX; IHE names the transaction the PIXm Patient Identity
  Feed. The gateway then asks the index over PIXm. An application that opens a
  record asks it the same way. FerroCHART receives the EHR it is launched with
  and asks nobody, so no line runs from the form to the index.
- **FerroSYS has no edges at all.** Every server reports health, telemetry and
  events to it and is configured from it, so it is drawn as a band under
  everything, the mirror of the FerroTERM band above. A line from each box
  would say nothing the band does not.
- **One line hops another.** Clinicians and Applications both sit on the
  outside, left of FerroCHART, and FerroCHART's own call to FerroSMART runs
  down from it. A client on the outside has to pass under FerroCHART to reach
  the CDR, so that crossing cannot be drawn away. The Applications line hops
  it with a small arc, and the generator allows a crossing only where a hop is
  declared.

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
build. A dashed edge is a design intent, and the planned product's own
repository will carry its evidence once it exists.

## Colours and theme

The palette is `assets/brand/tokens.css`, written into the file as literal
values, because a standalone SVG cannot read the page's custom properties. The
media query inside the file swaps every colour on `prefers-color-scheme`, so one
file serves a light and a dark reader.

A product keeps its own hue: FerroCHART rose, FerroEHR rust, FerroTERM teal,
FerroBRIDGE indigo, and the provisional plum, bronze, azure and olive of
FerroPIX, FerroSMART, FerroFED and FerroSYS. Everything else is iron, steel and
graphite.

## Regenerating the raster

```bash
rsvg-convert -w 2400 -h 1512 \
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
