<!-- SPDX-FileCopyrightText: Ruben Talstra -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Diagrams

One file per diagram, self-contained, so a diagram can be used outside this
site: a product README, the books, a slide, an issue.

| File | What it shows |
|---|---|
| `ferrohealth-architecture.svg` | what calls what across the four servers and the four planned services around them |
| `ferrohealth-architecture.png` | the same at 2400x1296, for the rare consumer that renders no SVG at all |

## How it is drawn

The SVG is drawn by `scripts/diagrams/ferrohealth-architecture.py` and is
never edited by hand. Boxes and edges are declared in that script, and before
it writes it asserts what a reader would otherwise have to catch: no two boxes
overlap, every edge starts and ends on the perimeter of its own box and passes
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
     width="1200" height="648" alt="...">
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

Left to right is the order data moves. The four servers are the data path:
FerroCHART takes the record down, FerroEHR keeps it, FerroTERM gives its codes
meaning, FerroBRIDGE carries it out. The four planned services frame that path
and are drawn dashed, as is every call into one of them.

An arrowhead points at what is called or written to. The FHIR side carries one
at both ends, because the bridge reads openEHR out to FHIR and writes FHIR back
in, which is the same rule the FerroBRIDGE mark keeps. Federation carries one at
both ends for the same reason: this gateway queries the other organisations'
gateways and they query it. Each edge names the specification it speaks, with
a few exceptions worth knowing:

- **`FHIR facade`** names the exchange and no FHIR release. The facade speaks
  the release FHIRconnect's mappings name, and FerroBRIDGE's own site says
  which. FerroTERM's band names code systems for the same reason: the FHIR
  releases it serves are a fact its own site renders, and a list here would
  rot.
- **`SQL rows`** names no wire specification, because OMOP is a database schema.
  The OMOCL mappings compile to SQL that writes typed rows into the CDM tables.
- **`OIDC, SMART launch`** is the one call drawn into FerroSMART: the
  clinician's sign-in through the form. Every server also checks the token it is
  handed against the same server. Those edges would run from every box and
  cross the whole picture, so the caption carries them.
- **FerroSYS has no edges at all.** Every server reports health, telemetry and
  events to it and is configured from it, so it is drawn as a band under
  everything, the mirror of the FerroTERM band above. A line from each box
  would say nothing the band does not.
- **One line hops another.** Clinicians and Applications both sit on the
  outside, left of FerroCHART, and FerroCHART's own calls run down from it to
  FerroSMART and FerroPIX. A client on the outside has to pass under
  FerroCHART to reach the CDR, so that crossing cannot be drawn away.
  FerroCHART sends one line down that forks, the Applications line hops it
  with a small arc, and the generator allows a crossing only where a hop is
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
`$validate-code` as the default membership operation. A dashed edge is a design
intent, and the planned product's own repository will carry its evidence once
it exists.

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
rsvg-convert -w 2400 -h 1296 \
  assets/diagrams/ferrohealth-architecture.svg \
  -o assets/diagrams/ferrohealth-architecture.png
```

No `-b` flag: the ground is the SVG's own.

`scripts/site/assemble.sh` copies this directory to `assets/diagrams/` of the
assembled site, so both files resolve on <https://ferrohealth.eu/>.
