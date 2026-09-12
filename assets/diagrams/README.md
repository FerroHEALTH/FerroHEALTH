<!-- SPDX-FileCopyrightText: Ruben Talstra -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Diagrams

One file per diagram, self-contained, so a diagram can be used outside this
site: a product README, the books, a slide, an issue.

| File | What it shows |
|---|---|
| `ferrohealth-architecture.svg` | what calls what across FerroCHART, FerroEHR, FerroTERM and FerroBRIDGE |
| `ferrohealth-architecture.png` | the same at 2400x680, for the rare consumer that renders no SVG at all |

## Using it

The landing page loads the SVG with `<img>`, and so can anything else:

```html
<img src="https://ferrohealth.eu/assets/diagrams/ferrohealth-architecture.svg"
     width="1200" height="340" alt="...">
```

In a Markdown file, reference the SVG:

```markdown
![What calls what across the four servers](assets/diagrams/ferrohealth-architecture.svg)
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

An arrowhead points at what is called or written to. The FHIR side carries one
at both ends, because the bridge reads openEHR out to FHIR and writes FHIR back
in, which is the same rule the FerroBRIDGE mark keeps. Each edge names the
specification it speaks, with two exceptions worth knowing:

- **`FHIR facade`** names the exchange and no FHIR release. The facade speaks
  the release FHIRconnect's mappings name, and FerroBRIDGE's own site says
  which. FerroTERM's band names code systems for the same reason: the FHIR
  releases it serves are a fact its own site renders, and a list here would
  rot.
- **`SQL rows`** names no wire specification, because OMOP is a database schema.
  The OMOCL mappings compile to SQL that writes typed rows into the CDM tables.

`$validate-code` is the one operation FerroEHR uses, and the label says so. A
server that does not offer it is configured to `operation = "expand"` per
provider, which replaces `$validate-code` with `$expand` plus a membership test.
FerroEHR never retries one as the other, so drawing both on the edge would say
something the CDR does not do.

The evidence for every edge is in the products' own documents: FerroBRIDGE's
`website/book/src/integrate/fhir-facade.md` and
`operate/deployment-shape.md` for the terminology operations and the CDM write,
and FerroEHR's `website/book/src/installation/config-integrations.md` for
`$validate-code` as the default membership operation.

## Colours and theme

The palette is `assets/brand/tokens.css`, written into the file as literal
values, because a standalone SVG cannot read the page's custom properties. The
media query inside the file swaps every colour on `prefers-color-scheme`, so one
file serves a light and a dark reader, and the background stays transparent so
it sits on any surface.

A product keeps its own hue: FerroCHART rose, FerroEHR rust, FerroTERM teal,
FerroBRIDGE indigo.
Everything else is iron, steel and graphite.

## Regenerating the raster

```bash
rsvg-convert -w 1832 -h 560 \
  assets/diagrams/ferrohealth-architecture.svg \
  -o assets/diagrams/ferrohealth-architecture.png
```

No `-b` flag: the ground stays transparent, like the SVG's.

`scripts/site/assemble.sh` copies this directory to `assets/diagrams/` of the
assembled site, so both files resolve on <https://ferrohealth.eu/>.
