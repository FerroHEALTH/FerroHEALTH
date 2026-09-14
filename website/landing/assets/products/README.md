<!-- SPDX-FileCopyrightText: Ruben Talstra -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Product marks

Verbatim copies of each product's primary icon, taken from that product's own
`assets/brand/` directory:

| File | Source |
|---|---|
| `ferrochart-icon.svg` | <https://github.com/rubentalstra/FerroCHART> `assets/brand/ferrochart-icon.svg` |
| `ferroehr-icon.svg` | <https://github.com/rubentalstra/FerroEHR> `assets/brand/ferroehr-icon.svg` |
| `ferroterm-icon.svg` | <https://github.com/rubentalstra/FerroTERM> `assets/brand/ferroterm-icon.svg` |
| `ferrobridge-icon.svg` | <https://github.com/rubentalstra/FerroBRIDGE> `assets/brand/ferrobridge-icon.svg` |

The landing page's Content Security Policy is `default-src 'self'`, so the page
loads no image from another origin. That is why these are copies. Refresh a file
from its source when that product changes its mark, and never edit one here.
Each mark belongs to its own project and keeps that project's licence.

## Provisional marks

Four products have a name and a domain and no repository yet, so there is no
source to copy from. Their marks were drawn here, in the grammar the four above
share (a 64-unit viewBox, a 512 intrinsic size, strokes of 4.6, two tones from
the product's own pair in `assets/brand/tokens.css`), and are Apache-2.0 like
the rest of this repository:

| File | What it shows |
|---|---|
| `ferropix-icon.svg` | one person, two identifiers linked beneath them |
| `ferrosmart-icon.svg` | a key |
| `ferrofed-icon.svg` | two nodes joined over an organisation boundary |
| `ferrosys-icon.svg` | a gauge |

When a product's repository opens, its mark moves there as
`assets/brand/<product>-icon.svg` and becomes the source; the file here becomes
a copy, joins the table above, and is edited there and never here again.
