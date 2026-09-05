<!-- SPDX-FileCopyrightText: Ruben Talstra -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# FerroHEALTH brand

FerroHEALTH is the family name for three servers that are built and released
separately: [FerroEHR](https://ferroehr.eu/), an openEHR® Clinical Data
Repository; [FerroTERM](https://ferroterm.eu/), an HL7® FHIR® terminology
server; and [FerroBRIDGE](https://ferrobridge.eu/), a bridge from openEHR to
FHIR and to the OMOP Common Data Model. Ferro is *ferrum*, iron, which is what
Rust is an oxide of.

The parent follows the same file set, naming, variant list, and raster pipeline
as the three products. What it does differently is colour: each product owns a
hue, so the parent owns none of them.

## The mark

The mark is a single pulse drawn as three strokes, one per product, in each
product's own hue: rust for FerroEHR, teal for FerroTERM, indigo for
FerroBRIDGE. The strokes meet rather than sit apart, because a record reaching
a clinician, the terminology that gives it meaning, and the bridge that carries
it onward are one signal path, not three products in a bundle.

The stroke order is always FerroEHR, then FerroTERM, then FerroBRIDGE, left to
right. That is the order data moves, and it is the order the products are named
in every list on the site.

## Palette, "Iron & Steel"

| Token | Hex | Use |
|---|---|---|
| iron | `#0F172A` | ink on light, ground on dark |
| tile | `#0B1020` | dark tile background |
| steel | `#3F6070` | links, primary action, secondary UI |
| steel-deep | `#2E4A57` | hover, pressed |
| steel-light | `#8FB6C4` | the same voice on a dark ground |
| graphite | `#64748B` | muted text |
| mist | `#F1F5F9` | text on dark |
| surface | `#F8FAFC` | light surface background |

The product hues are carried in the same file, taken verbatim from each
product's own `tokens.css`, so a product name and its colour never drift apart
between this site and the product's own:

| Product | Light ground | Dark ground |
|---|---|---|
| FerroEHR | `#B7431B` | `#D97742` |
| FerroTERM | `#0D9488` | `#2DD4BF` |
| FerroBRIDGE | `#4F46E5` | `#A5B4FC` |

The values live in `tokens.css` as `--ferrohealth-*` custom properties. The
landing page reads them through its own `--fh-*` tokens in
`website/landing/style.css`, so the site and the mark agree.

## Files

| File | What it is |
|---|---|
| `ferrohealth-icon.svg` | primary icon, full colour, transparent background |
| `ferrohealth-icon-mono.svg` | one-colour icon, inherits `currentColor` |
| `ferrohealth-icon-dark.svg` | the icon on a dark rounded tile |
| `ferrohealth-lockup-light.svg` | icon and "FerroHEALTH" wordmark for light backgrounds |
| `ferrohealth-lockup-dark.svg` | the lockup for dark backgrounds |
| `ferrohealth-lockup-auto.svg` | the lockup that follows `prefers-color-scheme` |
| `favicon.svg` | the mark on an iron tile, drawn heavier, for browser tabs |
| `favicon-32.png`, `favicon-16.png`, `favicon.ico` | raster favicons |
| `apple-touch-icon.png` | the 180x180 home-screen icon |
| `ferrohealth-social.svg`, `ferrohealth-social.png` | 1200x630 social card |
| `tokens.css` | the palette as CSS custom properties |

## Intrinsic size

Every icon declares `width` and `height` of **512** beside its
`viewBox="0 0 64 64"`. The viewBox is what the artwork is drawn in; the two
attributes are what a consumer that rasterizes the file takes as its natural
size. With `width="64" height="64"` a listing header that wants several hundred
pixels renders a 64-pixel bitmap blurry. The artwork is vector and loses
nothing at any size, so the cap was only those two attributes.

`favicon.svg` stays at 64, because a favicon wants a small natural size. The
lockups keep their own natural width, since they are drawn to a fixed aspect
rather than a square.

## Typography

The wordmark is set in Bricolage Grotesque (700) with a system-sans fallback
stack, which is what FerroTERM and FerroBRIDGE already use. Outline the
wordmark to paths before any print use, so the artwork carries no font
dependency. The rest of the FerroHEALTH surfaces use the system font stack in
`website/landing/style.css`.

## Usage

- Wordmark: "Ferro" in iron (mist on dark), "HEALTH" in steel (steel-light on
  dark), always set together, never stacked.
- Keep clear space around the mark equal to the height of the pulse's tallest
  peak.
- The three-colour mark reads down to 24 px. Below that use `favicon.svg`,
  which draws the strokes heavier on the iron tile and reads at 16 px.
- Put the colour mark on light or quiet surfaces, and
  `ferrohealth-icon-dark.svg` on busy or light-photographic backgrounds.
- Use `ferrohealth-icon-mono.svg` where one colour is required; it takes the
  surrounding text colour.
- Do not recolour a stroke outside its product's palette, reorder the strokes,
  stretch the mark, add effects, or rebuild the wordmark in another typeface.
- Do not give FerroHEALTH a hue of its own. If the parent ever needs to be
  loud, it borrows the three, in order.
- FerroHEALTH is a family name, not a product. Never write it as the name of
  software somebody can install.

## Regenerating the rasters

The PNG and ICO files derive from the SVGs. Run these from the repository root
after any change to `favicon.svg` or `ferrohealth-social.svg`:

```bash
rsvg-convert -w 32 -h 32 assets/brand/favicon.svg -o assets/brand/favicon-32.png
rsvg-convert -w 16 -h 16 assets/brand/favicon.svg -o assets/brand/favicon-16.png
rsvg-convert -w 48 -h 48 assets/brand/favicon.svg -o /tmp/favicon-48.png
magick /tmp/favicon-48.png assets/brand/favicon-32.png assets/brand/favicon-16.png assets/brand/favicon.ico
rsvg-convert -w 180 -h 180 assets/brand/favicon.svg -o assets/brand/apple-touch-icon.png
rsvg-convert -w 1200 -h 630 assets/brand/ferrohealth-social.svg -o assets/brand/ferrohealth-social.png
```

`scripts/site/assemble.sh` copies this directory to `assets/brand/` of the
assembled site, so the landing page, the social card, and the favicons resolve
on <https://ferrohealth.eu/>.

## Trademarks

openEHR® is a registered trademark of the openEHR Foundation. HL7® and FHIR®
are registered trademarks of Health Level Seven International. SNOMED CT® is a
registered trademark of SNOMED International. OMOP and the OHDSI vocabulary are
maintained by the OHDSI community. None of these organisations endorse
FerroHEALTH.
