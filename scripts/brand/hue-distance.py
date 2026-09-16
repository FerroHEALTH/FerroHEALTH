#!/usr/bin/env python3
# SPDX-FileCopyrightText: Vernum Projecten B.V.
# SPDX-License-Identifier: Apache-2.0
#
# hue-distance.py: score a product hue by its worst-case perceptual distance
# from the hues the family already owns.
#
#   scripts/brand/hue-distance.py            score the palette in tokens.css
#   scripts/brand/hue-distance.py '#b45309' '#fbbf24' [NAME]
#                                             score one candidate pair
#
# The family's rule is that every product owns a hue and a reader tells the
# products apart by it, so a new hue is chosen by measurement and never by eye.
# The measure is CIEDE2000 between the candidate and each existing hue, on the
# light ground and on the dark ground, as seen with normal vision and as seen
# with protanopia and deuteranopia (Machado, Oliveira and Fernandes 2009,
# severity 1.0). The score is the minimum over all of that, and the palette's
# score is the minimum over every pair. assets/brand/README.md records the
# result and the bar the family accepts. Standard library only.

import re
import sys
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TOKENS = ROOT / "assets/brand/tokens.css"

# Machado et al. 2009, severity 1.0, applied to linear RGB.
PROTAN = (
    (0.152286, 1.052583, -0.204868),
    (0.114503, 0.786281, 0.099216),
    (-0.003882, -0.048116, 1.051998),
)
DEUTAN = (
    (0.367322, 0.860646, -0.227968),
    (0.280085, 0.672501, 0.047413),
    (-0.011820, 0.042940, 0.968881),
)


def hex_to_rgb(value):
    value = value.strip().lstrip("#")
    return tuple(int(value[i : i + 2], 16) / 255 for i in (0, 2, 4))


def to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def simulate(rgb_linear, matrix):
    out = []
    for row in matrix:
        v = sum(m * c for m, c in zip(row, rgb_linear))
        out.append(min(1.0, max(0.0, v)))
    return tuple(out)


def to_lab(rgb_linear):
    r, g, b = rgb_linear
    x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
    y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
    z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041
    xn, yn, zn = 0.95047, 1.0, 1.08883

    def f(t):
        return t ** (1 / 3) if t > 216 / 24389 else t * (841 / 108) + 4 / 29

    fx, fy, fz = f(x / xn), f(y / yn), f(z / zn)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def ciede2000(lab1, lab2):
    from math import atan2, cos, degrees, exp, hypot, radians, sin, sqrt

    l1, a1, b1 = lab1
    l2, a2, b2 = lab2
    c1, c2 = hypot(a1, b1), hypot(a2, b2)
    cm = (c1 + c2) / 2
    g = 0.5 * (1 - sqrt(cm**7 / (cm**7 + 25**7)))
    a1p, a2p = a1 * (1 + g), a2 * (1 + g)
    c1p, c2p = hypot(a1p, b1), hypot(a2p, b2)

    def hue(a, b):
        if a == 0 and b == 0:
            return 0.0
        h = degrees(atan2(b, a))
        return h + 360 if h < 0 else h

    h1p, h2p = hue(a1p, b1), hue(a2p, b2)
    dl = l2 - l1
    dc = c2p - c1p
    if c1p * c2p == 0:
        dh = 0.0
    else:
        dh = h2p - h1p
        if dh > 180:
            dh -= 360
        elif dh < -180:
            dh += 360
    dH = 2 * sqrt(c1p * c2p) * sin(radians(dh / 2))
    lm = (l1 + l2) / 2
    cmp_ = (c1p + c2p) / 2
    if c1p * c2p == 0:
        hm = h1p + h2p
    else:
        hm = (h1p + h2p) / 2
        if abs(h1p - h2p) > 180:
            hm += 180 if hm < 180 else -180
    t = (
        1
        - 0.17 * cos(radians(hm - 30))
        + 0.24 * cos(radians(2 * hm))
        + 0.32 * cos(radians(3 * hm + 6))
        - 0.20 * cos(radians(4 * hm - 63))
    )
    sl = 1 + 0.015 * (lm - 50) ** 2 / sqrt(20 + (lm - 50) ** 2)
    sc = 1 + 0.045 * cmp_
    sh = 1 + 0.015 * cmp_ * t
    rt = -2 * sqrt(cmp_**7 / (cmp_**7 + 25**7)) * sin(radians(60 * exp(-(((hm - 275) / 25) ** 2))))
    return sqrt((dl / sl) ** 2 + (dc / sc) ** 2 + (dH / sh) ** 2 + rt * (dc / sc) * (dH / sh))


def views(hex_value):
    """The colour as the three kinds of reader see it, in Lab."""
    lin = tuple(to_linear(c) for c in hex_to_rgb(hex_value))
    return {
        "normal": to_lab(lin),
        "protan": to_lab(simulate(lin, PROTAN)),
        "deutan": to_lab(simulate(lin, DEUTAN)),
    }


def pair_distance(a, b):
    """Worst case over the two grounds and the three kinds of vision.

    a and b are (light, dark) hex pairs. Returns (score, where)."""
    worst = (float("inf"), "")
    for ground, ia in (("light", 0), ("dark", 1)):
        va, vb = views(a[ia]), views(b[ia])
        for vision in ("normal", "protan", "deutan"):
            d = ciede2000(va[vision], vb[vision])
            if d < worst[0]:
                worst = (d, f"{ground} ground, {vision}")
    return worst


def contrast(hex_value, against):
    def lum(h):
        r, g, b = (to_linear(c) for c in hex_to_rgb(h))
        return 0.2126 * r + 0.7152 * g + 0.0722 * b

    l1, l2 = lum(hex_value), lum(against)
    hi, lo = max(l1, l2), min(l1, l2)
    return (hi + 0.05) / (lo + 0.05)


def read_palette():
    """Every --ferrohealth-<product> / --ferrohealth-<product>-light pair."""
    text = TOKENS.read_text()
    found = dict(re.findall(r"--ferrohealth-([a-z]+(?:-light)?):\s*(#[0-9A-Fa-f]{6})", text))
    palette = {}
    for name, value in found.items():
        # steel is the parent's voice and owns no product, so it is not scored.
        if name == "steel" or name.endswith("-light") or f"{name}-light" not in found:
            continue
        palette[name] = (value, found[f"{name}-light"])
    return palette


def report(palette):
    names = list(palette)
    width = max(len(n) for n in names)
    print("contrast of each value against its ground (WCAG 2.2 asks 4.5 for text)")
    for n in names:
        light, dark = palette[n]
        print(f"  {n:<{width}}  {light} on white {contrast(light, '#ffffff'):4.2f}   {dark} on tile {contrast(dark, '#0b1020'):4.2f}")
    print()
    print("worst-case CIEDE2000 per pair (both grounds; normal, protan, deutan)")
    floor = (float("inf"), "", "")
    for a, b in combinations(names, 2):
        d, where = pair_distance(palette[a], palette[b])
        print(f"  {a:<{width}}  {b:<{width}}  {d:5.1f}  ({where})")
        if d < floor[0]:
            floor = (d, a, b)
    print()
    print(f"palette floor: {floor[0]:.1f} between {floor[1]} and {floor[2]}")


def main(argv):
    palette = read_palette()
    if len(argv) >= 3:
        name = argv[3] if len(argv) > 3 else "candidate"
        palette[name] = (argv[1], argv[2])
    report(palette)


if __name__ == "__main__":
    main(sys.argv)
