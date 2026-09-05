<!-- SPDX-FileCopyrightText: Ruben Talstra -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Diagrams

One file per diagram, self-contained, so a diagram can be used outside this
site: a product README, the books, a slide, an issue.

| File | What it shows |
|---|---|
| `ferrohealth-architecture.svg` | what calls what across FerroEHR, FerroTERM and FerroBRIDGE |
| `ferrohealth-architecture.png` | the same at 1832x560, transparent ground, for a consumer that cannot render SVG |

## Using it

The landing page loads the SVG with `<img>`, and so can anything else:

```html
<img src="https://ferrohealth.eu/assets/diagrams/ferrohealth-architecture.svg"
     width="916" height="280" alt="...">
```

In a GitHub README, link the raw file. GitHub strips the `<style>` element from
an SVG rendered in Markdown, so the theme query does not survive there and the
light palette is what shows. The PNG is the same artwork for a consumer that
cannot render SVG at all. Both grounds are transparent, and both carry the light
palette when the theme query cannot run, so place them on a light surface:

```markdown
![What calls what across the three servers](https://raw.githubusercontent.com/rubentalstra/FerroHEALTH/main/assets/diagrams/ferrohealth-architecture.png)
```

Do not screenshot the page to get the diagram. The file is the diagram.

## What it says

An arrowhead points at what is called or written to. The FHIR side carries one
at both ends, because the bridge reads openEHR out to FHIR and writes FHIR back
in, which is the same rule the FerroBRIDGE mark keeps. Each edge names the
specification it speaks, with two exceptions worth knowing:

- **`R4 facade`** is FerroBRIDGE's FHIR version, and only its. FHIRconnect's
  schemas admit no other value for `spec.version`, so the bridge claims R4 and
  nothing else. FerroTERM serves R4, R4B, R5 and the R6 ballot, which is why its
  box carries the list.
- **`SQL rows`** names no wire specification, because OMOP is a database schema.
  The OMOCL mappings compile to SQL that writes typed rows into the CDM v5.4
  tables.

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

A product keeps its own hue: FerroEHR rust, FerroTERM teal, FerroBRIDGE indigo.
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
