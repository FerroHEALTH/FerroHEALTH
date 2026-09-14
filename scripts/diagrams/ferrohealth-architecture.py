#!/usr/bin/env python3
# SPDX-FileCopyrightText: Ruben Talstra
# SPDX-License-Identifier: Apache-2.0
#
# ferrohealth-architecture.py: draw assets/diagrams/ferrohealth-architecture.svg.
#
#   scripts/diagrams/ferrohealth-architecture.py OUT.svg
#
# The diagram is declared below as boxes and edges and drawn from those
# declarations, because a picture of eight components and their calls is where
# a hand-placed label drifts onto a line. Before the script writes, it asserts
# what a reader would otherwise have to catch: no two boxes overlap, every
# product sits inside the frame and every outside party outside it, every edge
# starts and ends on the perimeter of its own box and passes through no other,
# no two edges cross, no label touches a box, a line or another label, and
# every text fits its box. scripts/checks/diagram-generated.sh keeps the
# committed SVG equal to this script's output. Standard library only.
#
# What the picture says is in assets/diagrams/README.md. In short: left to
# right is the order data moves, the four servers are the data path, and the
# four planned services frame it. An arrowhead points at what is called or
# written to. A dashed outline is a planned product, and a dashed edge a call
# into one. Where a line has to cross another it hops over it with a small arc,
# and a crossing is allowed only where a hop is declared.

import sys
from dataclasses import dataclass, field
from typing import Optional

W, H = 1200, 712
Y = 36  # everything below the frame's label line moves down this much

# The frame: what is FerroHEALTH and what is the outside world. One instance
# serves one tenant; that is the setup the family shows. FerroEHR can host
# several isolated tenants in one deployment as its own setting, and an
# organisation that serves several runs several instances instead.
FRAME = (176, 8, 720, 664)  # x, y, w, h
FRAME_LABEL = "ONE FERROHEALTH INSTANCE · ONE TENANT"
INSIDE = {"term", "chart", "ehr", "bridge", "smart", "pix", "fed", "sys"}
STEEL = ("#3f6070", "#8fb6c4")

# assets/brand/tokens.css, as literal values: a standalone SVG cannot read the
# page's custom properties. Light is written as presentation attributes, dark
# as the one <style> block, so a renderer that drops <style> still gets a
# legible light drawing.
HUES = {
    "chart": ("#c2185b", "#e04f84"),
    "ehr": ("#b7431b", "#d97742"),
    "term": ("#0d9488", "#2dd4bf"),
    "bridge": ("#4f46e5", "#a5b4fc"),
    "pix": ("#6b21a8", "#c084fc"),
    "smart": ("#78350f", "#fbbf24"),
    "fed": ("#0369a1", "#7dd3fc"),
    "sys": ("#5b6b16", "#bef264"),
}
GROUND = ("#f5f7fa", "#131a26")
BOX_FILL = ("#ffffff", "#0b1020")
BOX_STROKE = ("#dde3eb", "#243044")
INK = ("#0f172a", "#eef2f7")
MUTED = ("#58616e", "#a4aebc")

SANS = "system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
MONO = "ui-monospace, SFMono-Regular, Menlo, Consolas, monospace"

HEAD = 12  # the line stops this far short of the tip, leaving room for the head
HOP = 7  # radius of the arc a line draws over another where it has to cross


@dataclass
class Box:
    key: str
    x: float
    y: float
    w: float
    h: float
    title: str
    subs: list = field(default_factory=list)
    hue: Optional[str] = None
    planned: bool = False
    title_size: float = 15
    why: str = ""

    @property
    def right(self):
        return self.x + self.w

    @property
    def bottom(self):
        return self.y + self.h

    @property
    def cx(self):
        return self.x + self.w / 2


@dataclass
class Edge:
    src: str
    dst: str
    points: list  # perimeter to perimeter; the last point is the arrow tip
    label: str = ""
    label_at: Optional[tuple] = None  # (x, y, anchor)
    both: bool = False
    planned: bool = False
    hops: list = field(default_factory=list)  # x positions where this line arcs over another
    branch_of: Optional[tuple] = None  # (src, dst) of the edge this one forks from
    around: bool = False  # goes past its target and comes back, on purpose
    why: str = ""


@dataclass
class Label:
    x: float
    y: float
    text: str
    anchor: str
    size: float
    mono: bool = False
    owner: Optional[str] = None  # the box whose text this is, exempt from the box test

    def bbox(self):
        per_char = 0.62 if self.mono else 0.54
        w = len(self.text) * self.size * per_char
        if self.anchor == "middle":
            x0 = self.x - w / 2
        elif self.anchor == "end":
            x0 = self.x - w
        else:
            x0 = self.x
        return (x0, self.y - self.size * 0.75, x0 + w, self.y + self.size * 0.25)


# --- the declarations ---------------------------------------------------------

BOXES = [
    Box("term", 206, 12, 660, 76, "FerroTERM", hue="term",
        subs=["SNOMED CT, LOINC, ICD-10, ICD-11, RxNorm, UCUM · the FHIR terminology API"],
        why="FerroTERM spans the three servers that call it, because all three reach a\n"
            "terminology server over the same FHIR API and none of them is a more\n"
            "important caller than the others. Drawn as a band rather than a peer box, so\n"
            "the shared seam is the shape of the thing. It names code systems and no FHIR\n"
            "release: which releases it serves is a fact its own site renders."),
    Box("clinicians", 8, 174, 128, 60, "Clinicians", subs=["doctors and nurses"],
        why="The person the whole family exists for."),
    Box("chart", 206, 160, 160, 88, "FerroCHART", hue="chart",
        subs=["templates to forms", "forms to compositions"]),
    Box("ehr", 452, 160, 160, 88, "FerroEHR", hue="ehr",
        subs=["openEHR CDR, AQL", "PostgreSQL"]),
    Box("bridge", 698, 160, 168, 88, "FerroBRIDGE", hue="bridge",
        subs=["FHIRconnect, OMOCL", "mapping-driven"]),
    Box("apps", 8, 260, 128, 60, "Applications", title_size=14,
        subs=["any ITS-REST client"],
        why="Anything else that speaks the API. On the outside with the clinician, on\n"
            "its own lane, so it never reads as something FerroCHART sits in front of."),
    Box("fhir", 1000, 116, 190, 56, "HL7 FHIR", subs=["a facade, stores nothing"]),
    Box("omop", 1000, 224, 190, 56, "OMOP CDM", subs=["a batch load, for research"]),
    Box("smart", 206, 400, 160, 88, "FerroSMART", hue="smart", planned=True,
        subs=["authorisation server", "OAuth 2.0, OIDC, SMART"],
        why="The SMART on openEHR layer FerroEHR carries today (the discovery document,\n"
            "the launch context, the scope grammar and its gate), pulled out into a\n"
            "server of its own so one place owns authorisation for the family. Two\n"
            "edges: the application obtains its token and launch context here, and the\n"
            "CDR asks here whether the token it is handed may do what it asks."),
    Box("pix", 452, 400, 160, 88, "FerroPIX", hue="pix", planned=True,
        subs=["Master Patient Index", "IHE PIX and PDQ"],
        why="Under the CDR whose records it locates. The CDR feeds it when an EHR is\n"
            "created or its subject changes, the gateway asks it where a record is; an\n"
            "application that opens a record asks it the same way, and FerroCHART\n"
            "receives the EHR it is launched with and asks nobody."),
    Box("fed", 698, 400, 168, 88, "FerroFED", hue="fed", planned=True,
        subs=["federation gateway", "one query, every node"],
        why="Under FerroBRIDGE, on the side where data leaves, and level with the other\n"
            "organisations it talks to. The federation tier of the openEHR federation\n"
            "proposal: a transparent ITS-REST intermediary that resolves the patient\n"
            "first, then dispatches ordinary AQL to each node's own EHR id."),
    Box("others", 1000, 416, 190, 56, "Other organisations", planned=True,
        subs=["federation nodes"],
        why="Dashed like the gateway that reaches them, because without FerroFED there is\n"
            "no path to them at all."),
    Box("sys", 206, 548, 660, 76, "FerroSYS", hue="sys", planned=True,
        subs=["health, telemetry, event log, notifications, configuration · every server reports to it"],
        why="The mirror of the FerroTERM band: meaning above the servers, operations\n"
            "below them. No edges, because every one of the seven boxes above would carry\n"
            "one and the band already says so."),
]

EDGES = [
    Edge("clinicians", "chart", [(136, 204), (206, 204)]),
    Edge("chart", "term", [(286, 160), (286, 88)], "$expand", (278, 130, "end"),
         why="FerroCHART expands the value set behind a coded field, so the form can\n"
             "offer exactly the codes the template admits."),
    Edge("chart", "ehr", [(366, 204), (452, 204)], "ITS-REST", (409, 195, "middle")),
    Edge("ehr", "term", [(532, 160), (532, 88)], "$validate-code", (524, 130, "end"),
         why="FerroEHR validates a coded value at commit time."),
    Edge("apps", "ehr", [(136, 290), (430, 290), (430, 236), (452, 236)], "ITS-REST", (380, 281, "middle"),
         hops=[286],
         why="The one line that has to cross another: FerroCHART's calls run down from\n"
             "it, and any client on the outside has to pass under it to reach the CDR.\n"
             "It hops, and the generator allows a crossing only where a hop is drawn."),
    Edge("bridge", "ehr", [(698, 204), (612, 204)], "ITS-REST", (655, 195, "middle"),
         why="The bridge reads the CDR, so the arrow points at the CDR."),
    Edge("bridge", "term", [(782, 160), (782, 88)], "$lookup, $translate", (774, 130, "end"),
         why="The bridge resolves and translates codes for the FHIR side."),
    Edge("bridge", "fhir", [(866, 186), (950, 186), (950, 144), (1000, 144)], "FHIR facade",
         (910, 174, "middle"), both=True,
         why="FHIR is an exchange, so this edge carries a head at both ends."),
    Edge("bridge", "omop", [(866, 226), (950, 226), (950, 252), (1000, 252)], "SQL rows",
         (908, 214, "middle"),
         why="OMOP is a database schema, so this edge names no wire specification."),
    Edge("chart", "smart", [(286, 248), (286, 400)], "OIDC, SMART launch", (278, 330, "end"),
         planned=True,
         why="FerroCHART is a SMART application: it reads the CDR's discovery document,\n"
             "sends the clinician to the authorization server, and comes back with a\n"
             "token that carries the launch context."),
    Edge("ehr", "smart", [(470, 248), (470, 340), (330, 340), (330, 400)], "token introspection",
         (462, 320, "end"), planned=True,
         why="The scope gate FerroEHR runs in its own request path today becomes a\n"
             "question to this server: is this token good, and does it cover this\n"
             "operation on this record. FerroTERM and FerroBRIDGE ask the same; the\n"
             "caption carries those two lines."),
    Edge("fed", "ehr", [(698, 420), (650, 420), (650, 236), (612, 236)], "ITS-REST, AQL",
         (658, 330, "start"), planned=True,
         why="The gateway queries the local record like any client, below the bridge's\n"
             "own read of it and into the CDR's right side, so the two never meet."),
    Edge("ehr", "pix", [(560, 248), (560, 400)], "PIXm feed", (568, 330, "start"), planned=True,
         why="The index has to learn where records are, and the CDR is the one component\n"
             "that knows the moment an EHR is created or its subject changes. IHE names\n"
             "the transaction: the PIXm Patient Identity Feed."),
    Edge("fed", "pix", [(698, 460), (612, 460)], "PIXm", (655, 451, "middle"), planned=True,
         why="Where is the record: the gateway asks the index before it fans out."),
    Edge("fed", "others", [(866, 444), (1000, 444)], "ITS-REST, AQL", (933, 435, "middle"),
         planned=True,
         why="A remote CDR is a node like the local one: the gateway sends it standard\n"
             "AQL scoped to that node's own EHR id and merges what comes back, with the\n"
             "node named in the result."),
    Edge("apps", "fed", [(72, 320), (72, 516), (782, 516), (782, 488)], "ITS-REST, AQL",
         (600, 507, "middle"), planned=True, around=True,
         why="The application tier: a client sends the gateway an ordinary AQL query and\n"
             "never learns it was federated. The line runs under the planned row, the one\n"
             "corridor where it crosses nothing."),
]

LEGEND = (206, 656, "A dashed outline is a planned product, and a dashed line a call into one.")


for _b in BOXES:
    _b.y += Y
for _e in EDGES:
    _e.points = [(x, y + Y) for x, y in _e.points]
    if _e.label_at:
        _e.label_at = (_e.label_at[0], _e.label_at[1] + Y, _e.label_at[2])
LEGEND = (LEGEND[0], LEGEND[1] + Y, LEGEND[2])


# --- geometry assertions ------------------------------------------------------

def rect_overlap(a, b, pad=0):
    return not (a[2] + pad <= b[0] or b[2] + pad <= a[0] or a[3] + pad <= b[1] or b[3] + pad <= a[1])


def box_rect(b):
    return (b.x, b.y, b.right, b.bottom)


def seg_hits_rect(p, q, r):
    """Does the closed segment p-q enter the open rectangle r."""
    (x1, y1), (x2, y2) = p, q
    x0, y0, x3, y3 = r
    if x1 == x2:
        return x0 < x1 < x3 and min(y1, y2) < y3 and max(y1, y2) > y0
    if y1 == y2:
        return y0 < y1 < y3 and min(x1, x2) < x3 and max(x1, x2) > x0
    raise AssertionError(f"edge segment {p}-{q} is not orthogonal")


def segs_cross(a, b):
    """Do two orthogonal segments share a point."""
    (ax1, ay1), (ax2, ay2) = a
    (bx1, by1), (bx2, by2) = b
    ax_lo, ax_hi = sorted((ax1, ax2))
    ay_lo, ay_hi = sorted((ay1, ay2))
    bx_lo, bx_hi = sorted((bx1, bx2))
    by_lo, by_hi = sorted((by1, by2))
    return ax_lo <= bx_hi and bx_lo <= ax_hi and ay_lo <= by_hi and by_lo <= ay_hi


def on_perimeter(pt, b):
    x, y = pt
    on_vertical = x in (b.x, b.right) and b.y <= y <= b.bottom
    on_horizontal = y in (b.y, b.bottom) and b.x <= x <= b.right
    return on_vertical or on_horizontal


def box_labels(b):
    """The text a box carries, as labels, so it is checked like any other."""
    out = []
    n = len(b.subs)
    if n == 0:
        ty = b.y + b.h / 2 + 5
    elif n == 1:
        ty = b.y + b.h / 2 - 3
    else:
        ty = b.y + 30
    out.append(Label(b.cx, ty, b.title, "middle", b.title_size, owner=b.key))
    for i, s in enumerate(b.subs):
        out.append(Label(b.cx, ty + 22 + 18 * i, s, "middle", 11.5, owner=b.key))
    return out


def check(boxes, edges):
    by_key = {b.key: b for b in boxes}
    problems = []

    for i, a in enumerate(boxes):
        for b in boxes[i + 1:]:
            if rect_overlap(box_rect(a), box_rect(b), pad=8):
                problems.append(f"boxes {a.key} and {b.key} overlap or sit closer than 8px")
        if a.right > W or a.bottom > H or a.x < 0 or a.y < 0:
            problems.append(f"box {a.key} leaves the canvas")

    fx, fy, fw, fh = FRAME
    frame = (fx, fy, fx + fw, fy + fh)
    for b in boxes:
        r = box_rect(b)
        inside = r[0] >= frame[0] and r[1] >= frame[1] and r[2] <= frame[2] and r[3] <= frame[3]
        outside = not rect_overlap(r, frame, pad=8)
        if b.key in INSIDE and not inside:
            problems.append(f"box {b.key} is not wholly inside the frame")
        if b.key not in INSIDE and not outside:
            problems.append(f"box {b.key} is not wholly outside the frame")

    for lab in (l for b in boxes for l in box_labels(b)):
        b = by_key[lab.owner]
        x0, y0, x1, y1 = lab.bbox()
        if x0 < b.x + 4 or x1 > b.right - 4 or y0 < b.y or y1 > b.bottom:
            problems.append(f"text '{lab.text}' does not fit box {lab.owner}")

    by_pair = {(e.src, e.dst): e for e in edges}

    def on_segment(pt, p, q):
        return min(p[0], q[0]) <= pt[0] <= max(p[0], q[0]) and min(p[1], q[1]) <= pt[1] <= max(p[1], q[1])

    segments = []
    for e in edges:
        pts = e.points
        if e.branch_of:
            trunk = by_pair[e.branch_of]
            if not any(on_segment(pts[0], p, q) for p, q in zip(trunk.points, trunk.points[1:])):
                problems.append(f"edge {e.src}->{e.dst} forks off nothing")
        elif not on_perimeter(pts[0], by_key[e.src]):
            problems.append(f"edge {e.src}->{e.dst} starts off {e.src}")
        if not on_perimeter(pts[-1], by_key[e.dst]):
            problems.append(f"edge {e.src}->{e.dst} ends off {e.dst}")
        for k in range(len(pts) - 1):
            p, q = pts[k], pts[k + 1]
            if p == q:
                problems.append(f"edge {e.src}->{e.dst} has a zero-length segment")
            segments.append((e, p, q))
            for b in boxes:
                if seg_hits_rect(p, q, box_rect(b)):
                    problems.append(f"edge {e.src}->{e.dst} passes through {b.key}")
        # No waypoint doubles back: each axis moves in one direction only,
        # unless the edge says it goes around something on purpose.
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        for series, axis in ((xs, "x"), (ys, "y")):
            steps = [b - a for a, b in zip(series, series[1:]) if b != a]
            if not e.around and any(s > 0 for s in steps) and any(s < 0 for s in steps):
                problems.append(f"edge {e.src}->{e.dst} doubles back along {axis}")

    hops_used = set()
    for i, (ea, pa, qa) in enumerate(segments):
        for eb, pb, qb in segments[i + 1:]:
            if ea is eb or (ea.src, ea.dst) == eb.branch_of or (eb.src, eb.dst) == ea.branch_of:
                continue
            if not segs_cross((pa, qa), (pb, qb)):
                continue
            # A crossing is allowed where the horizontal line declares a hop at
            # the vertical line's x, and each hop covers exactly one crossing.
            hopped = False
            for horiz, hp, hq, vp in ((ea, pa, qa, pb), (eb, pb, qb, pa)):
                if hp[1] == hq[1] and vp[0] in horiz.hops and (id(horiz), vp[0]) not in hops_used:
                    hops_used.add((id(horiz), vp[0]))
                    hopped = True
                    break
            if not hopped:
                problems.append(f"edges {ea.src}->{ea.dst} and {eb.src}->{eb.dst} cross")
    for e in edges:
        for x in e.hops:
            if (id(e), x) not in hops_used:
                problems.append(f"edge {e.src}->{e.dst} hops at x={x} over nothing")

    labels = [Label(e.label_at[0], e.label_at[1], e.label, e.label_at[2], 10.5, mono=True)
              for e in edges if e.label]
    labels.append(Label(LEGEND[0] + 30, LEGEND[1] + 4, LEGEND[2], "start", 11))
    labels.append(Label(FRAME[0] + 18, FRAME[1] + 24, FRAME_LABEL, "start", 11))
    for lab in labels:
        r = lab.bbox()
        for b in boxes:
            if rect_overlap(r, box_rect(b), pad=2):
                problems.append(f"label '{lab.text}' touches box {b.key}")
        for e, p, q in segments:
            if seg_hits_rect(p, q, (r[0] - 3, r[1] - 3, r[2] + 3, r[3] + 3)):
                problems.append(f"label '{lab.text}' touches edge {e.src}->{e.dst}")
    for i, a in enumerate(labels):
        for b in labels[i + 1:]:
            if rect_overlap(a.bbox(), b.bbox(), pad=4):
                problems.append(f"labels '{a.text}' and '{b.text}' overlap")

    if problems:
        sys.exit("ferrohealth-architecture: refusing to draw:\n  " + "\n  ".join(problems))


# --- drawing ------------------------------------------------------------------

def comment(text, indent="    "):
    lines = text.split("\n")
    assert len(lines) <= 8, f"comment over budget: {lines[0]}"
    if len(lines) == 1:
        return f"{indent}<!-- {lines[0]} -->\n"
    body = ("\n" + indent + "     ").join(lines)
    return f"{indent}<!-- {body} -->\n"


def head(tip, frm):
    """The arrowhead at tip, arriving from frm."""
    x, y = tip
    if frm[0] < x:
        return f"M{x} {y} l-9 -5.5 v11 z"
    if frm[0] > x:
        return f"M{x} {y} l9 -5.5 v11 z"
    if frm[1] > y:
        return f"M{x} {y} l-5.5 9 h11 z"
    return f"M{x} {y} l-5.5 -9 h11 z"


def shorten(p, q, by):
    """The point `by` before q on the segment p-q."""
    if p[0] == q[0]:
        return (q[0], q[1] - by if q[1] > p[1] else q[1] + by)
    return (q[0] - by if q[0] > p[0] else q[0] + by, q[1])


def fmt(v):
    return f"{v:g}"


def draw_edge(e):
    pts = list(e.points)
    heads = [head(pts[-1], pts[-2])]
    pts[-1] = shorten(pts[-2], pts[-1], HEAD)
    if e.both:
        heads.append(head(pts[0], pts[1]))
        pts[0] = shorten(pts[1], pts[0], HEAD)
    d = f"M{fmt(pts[0][0])} {fmt(pts[0][1])}"
    for (px, py), (qx, qy) in zip(pts, pts[1:]):
        if py != qy:
            d += f" V{fmt(qy)}"
            continue
        step = 1 if qx > px else -1
        for x in sorted((h for h in e.hops if min(px, qx) < h < max(px, qx)), reverse=step < 0):
            d += f" H{fmt(x - HOP * step)} A{HOP} {HOP} 0 0 1 {fmt(x + HOP * step)} {fmt(py)}"
        d += f" H{fmt(qx)}"
    dash = ' stroke-dasharray="5 4"' if e.planned else ""
    out = ""
    if e.why:
        out += comment(e.why)
    out += f'    <path class="edge" d="{d}" fill="none" stroke="{MUTED[0]}" stroke-width="1.6"{dash}/>\n'
    for hd in heads:
        out += f'    <path class="edge-head" d="{hd}" fill="{MUTED[0]}"/>\n'
    if e.label:
        x, y, anchor = e.label_at
        out += (f'    <text class="edge-label" x="{fmt(x)}" y="{fmt(y)}" text-anchor="{anchor}" '
                f'font-family="{MONO}" font-size="10.5" fill="{MUTED[0]}">{e.label}</text>\n')
    return out


def draw_box(b):
    out = ""
    if b.why:
        out += comment(b.why)
    cls = "box" + (f" box-{b.hue}" if b.hue else "")
    stroke = HUES[b.hue][0] if b.hue else BOX_STROKE[0]
    dash = ' stroke-dasharray="6 4"' if b.planned else ""
    out += (f'    <rect class="{cls}" x="{fmt(b.x)}" y="{fmt(b.y)}" width="{fmt(b.w)}" height="{fmt(b.h)}" '
            f'rx="10" fill="{BOX_FILL[0]}" stroke="{stroke}" stroke-width="1.5"{dash}/>\n')
    labels = box_labels(b)
    title, subs = labels[0], labels[1:]
    tag = f" tag-{b.hue}" if b.hue else ""
    fill = HUES[b.hue][0] if b.hue else INK[0]
    out += (f'    <text class="label{tag}" x="{fmt(title.x)}" y="{fmt(title.y)}" text-anchor="middle" '
            f'font-size="{fmt(b.title_size)}" font-weight="700" fill="{fill}">{b.title}</text>\n')
    for s in subs:
        out += (f'    <text class="sub" x="{fmt(s.x)}" y="{fmt(s.y)}" text-anchor="middle" '
                f'font-size="11.5" font-weight="600" fill="{MUTED[0]}">{s.text}</text>\n')
    return out


def dark_style():
    rules = [
        f".ground {{ fill: {GROUND[1]} }}",
        f".box {{ fill: {BOX_FILL[1]}; stroke: {BOX_STROKE[1]} }}",
    ]
    rules += [f".box-{k} {{ stroke: {v[1]} }}" for k, v in HUES.items()]
    rules += [
        f".label {{ fill: {INK[1]} }}",
        f".sub, .edge-label, .legend {{ fill: {MUTED[1]} }}",
        f".edge, .legend-sample {{ stroke: {MUTED[1]} }}",
        f".edge-head {{ fill: {MUTED[1]} }}",
        f".frame {{ stroke: {STEEL[1]} }}",
        f".frame-label {{ fill: {STEEL[1]} }}",
    ]
    rules += [f".tag-{k} {{ fill: {v[1]} }}" for k, v in HUES.items()]
    body = "\n".join(f"      {r}" for r in rules)
    return f"  <style>\n    @media (prefers-color-scheme: dark) {{\n{body}\n    }}\n  </style>\n"


TITLE = "What calls what across the FerroHEALTH family"
DESC = (
    "A clinician uses FerroCHART in a browser. FerroCHART expands value sets against FerroTERM "
    "and commits compositions to FerroEHR over the openEHR ITS-REST API, which any other "
    "application can call directly. FerroEHR validates coded values against FerroTERM. FerroBRIDGE "
    "reads FerroEHR over ITS-REST, calls FerroTERM to look up and translate codes, exchanges "
    "resources with HL7 FHIR over its FHIR facade in both directions, and writes typed rows into an "
    "OMOP Common Data Model database over SQL. Four planned services, drawn dashed, frame the four "
    "servers: FerroCHART obtains its token and launch context from FerroSMART, the SMART on openEHR "
    "server, and FerroEHR asks FerroSMART whether each token it is handed may do what it asks; "
    "FerroEHR feeds FerroPIX, the Master Patient Index, each EHR it creates; applications send "
    "FerroFED, the federation gateway, an ordinary AQL query, and it asks FerroPIX where the record is, then dispatches the query to FerroEHR and to other "
    "organisations' openEHR CDRs as federation nodes; and FerroSYS, the control plane, "
    "spans everything as the band every server reports to. A frame around the eight marks one "
    "FerroHEALTH instance serving one tenant; clinicians, applications, FHIR, OMOP and other organisations sit outside it."
)

HEADER = (
    "<!-- SPDX-FileCopyrightText: Ruben Talstra -->\n"
    "<!-- SPDX-License-Identifier: Apache-2.0 -->\n"
    "<!-- Drawn by scripts/diagrams/ferrohealth-architecture.py; edit that file, not\n"
    "     this one, and regenerate. Every colour is a presentation attribute, so a\n"
    "     renderer that drops the <style> element still draws the light palette; the\n"
    "     <style> holds only the dark override, because a CSS rule outranks a\n"
    "     presentation attribute. The ground is the page's surface colour, so the\n"
    "     file blends into the section it sits in. Left to right is the order data\n"
    "     moves, the four servers are the data path, and the four planned services\n"
    "     frame it. An arrowhead points at what is called or written to. -->\n"
)


def render():
    check(BOXES, EDGES)
    out = HEADER
    out += (f'<svg xmlns="http://www.w3.org/2000/svg" width="{2 * W}" height="{2 * H}" '
            f'viewBox="0 0 {W} {H}" role="img" aria-labelledby="title desc">\n')
    out += f"  <title id=\"title\">{TITLE}</title>\n"
    out += f"  <desc id=\"desc\">{DESC}</desc>\n"
    out += dark_style()
    out += f'\n  <rect class="ground" width="{W}" height="{H}" rx="12" fill="{GROUND[0]}"/>\n\n'
    out += f'  <g font-family="{SANS}">\n\n'
    fx, fy, fw, fh = FRAME
    out += comment("The frame is one instance serving one tenant. Everything inside is\n"
                   "FerroHEALTH; everything outside is a caller, a target, or another\n"
                   "organisation. An organisation serving several tenants runs several.")
    out += (f'    <rect class="frame" x="{fmt(fx)}" y="{fmt(fy)}" width="{fmt(fw)}" height="{fmt(fh)}" rx="16" '
            f'fill="none" stroke="{STEEL[0]}" stroke-width="1.8"/>\n')
    out += (f'    <text class="frame-label" x="{fmt(fx + 18)}" y="{fmt(fy + 24)}" font-size="11" font-weight="700" '
            f'letter-spacing="0.06em" fill="{STEEL[0]}">{FRAME_LABEL}</text>\n\n')
    for b in BOXES:
        out += draw_box(b) + "\n"
    for e in EDGES:
        out += draw_edge(e) + "\n"
    lx, ly, text = LEGEND
    out += ('    <rect class="legend-sample" x="%s" y="%s" width="22" height="12" rx="3" '
            'fill="none" stroke="%s" stroke-width="1.5" stroke-dasharray="6 4"/>\n'
            % (fmt(lx), fmt(ly - 8), MUTED[0]))
    out += ('    <text class="legend" x="%s" y="%s" font-size="11" font-weight="600" fill="%s">%s</text>\n'
            % (fmt(lx + 30), fmt(ly + 4), MUTED[0], text))
    out += "\n  </g>\n</svg>\n"
    return out


def main(argv):
    if len(argv) != 2:
        sys.exit(f"usage: {argv[0]} OUT.svg")
    svg = render()
    with open(argv[1], "w", encoding="utf-8") as fh:
        fh.write(svg)


if __name__ == "__main__":
    main(sys.argv)
