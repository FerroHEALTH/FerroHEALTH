# Issue workflow (the tracker loop)

**The tracker is GitHub Issues: the open issue list is the worklist.** Issue
state is edited only through `gh`; never track work only in chat. The
SessionStart hook prints the open list.

This repository is small, so it runs the FerroTERM loop without the sub-issue
graph and the project board.

## The loop

1. **Orient.** `gh issue list --state open`. Pick the pinned issue or the one
   the user names, and read it with `gh issue view <n> --comments`.
2. **Read the contract.** The body opens with a plain summary of what and why,
   followed by an `## Acceptance criteria` checklist. Work found en route gets
   its own issue.
3. **Do the work.** Assemble the site and look at the page before claiming it is
   right: `scripts/site/assemble.sh _site`, then serve `_site` and check light
   and dark, wide and narrow.
4. **Record progress on the issue.** Tick verified criteria, and post decisions
   as comments. The issue thread is the durable record.
5. **Commit on a conventional-type branch** with a descriptive subject. The PR
   body declares `Closes #<n>` so the merge closes the issue. One `Closes`
   keyword closes one issue, so repeat it per issue.

## Labels

- **Type:** exactly one per issue, mapped to the conventional-commit types:
  `bug`, `enhancement`, `documentation`, `chore`, `refactor`, `ci`.
- **Priority:** `P0` to `P3`.
- **Area:** `site` (the page and its assets), `brand` (the mark and the
  palette), `build` (the assemble script and the checks).

## Branches use conventional types

`<type>/<kebab-case-slug>` with `type` in `feat`, `fix`, `chore`, `docs`,
`refactor`, `perf`, `test`, `ci`, `build`, `release`. Pick the type by the
dominant change. Never force-push `main`.

## A change in another repository

The three products are separate repositories. When work here turns up a defect
there, file it there with the evidence from here, and link the issue from the
work in this repository. A local workaround carries a `TODO(#N)` pointing at the
upstream issue and is removed when the fix lands.

## Never add AI or Claude attribution

Commit messages, PR text, issue and comment bodies describe only the change:
no `Co-Authored-By: Claude`, no "Generated with", no bot trailer, ever. This is
absolute and has no exceptions. The `no_attribution_guard.sh` PreToolUse hook
blocks the command before it runs.
