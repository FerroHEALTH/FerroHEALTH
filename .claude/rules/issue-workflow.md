# Issue workflow (the tracker loop)

**The tracker is GitHub Issues: the open issue list is the worklist.** Issue
state is edited only through `gh`; never track work only in chat. The
SessionStart hook prints the open list.

This repository is small, so it runs the FerroTERM loop without the sub-issue
graph and the project board.

## The loop

1. **Orient.** `gh issue list --state open` (the SessionStart hook prints it
   with `<Type/Priority>` after each title). Pick the pinned issue or the one
   the user names; otherwise take the open issue with the highest `Priority`
   field, the oldest first within a priority. Read it with:

   ```sh
   gh issue view <n> --json title,body,comments \
     --jq '.title, .body, (.comments[] | "--- comment ---", .body)'
   ```

   Never read an issue with `gh issue view <n> --comments`: it prints nothing
   and exits 0 for an issue with no comments, so the contract comes back
   empty.
2. **Read the contract.** The body opens with a plain summary of what and why,
   followed by an `## Acceptance criteria` checklist. Work found en route gets
   its own issue, filed with `scripts/gh/fields.sh new` (below).
3. **Do the work.** Assemble the site and look at the page before claiming it is
   right: `scripts/site/assemble.sh _site`, then serve `_site` and check light
   and dark, wide and narrow.
4. **Record progress on the issue.** Tick verified criteria, and post decisions
   as comments. The issue thread is the durable record.
5. **Commit on a conventional-type branch** with a descriptive subject. The PR
   body declares `Closes #<n>` so the merge closes the issue. One `Closes`
   keyword closes one issue, so repeat it per issue.

## Type, priority and labels

**The type, the priority and the effort of an issue are GitHub's own fields,
never labels.** The `FerroHEALTH` organisation defines all three, and
`scripts/gh/fields.sh` sets each by issue number, resolving every node id and
failing loud on a typo:

| Fact | Where it lives | Values | Command |
|---|---|---|---|
| Type | the native issue type of the organisation | `Bug`, `Feature`, `Task` | `scripts/gh/fields.sh type <n> bug\|feature\|task` |
| Priority | the organisation's `Priority` issue field | `Urgent`, `High`, `Medium`, `Low` | `scripts/gh/fields.sh priority <n> urgent\|high\|medium\|low` |
| Effort | the organisation's `Effort` issue field | `High`, `Medium`, `Low` | `scripts/gh/fields.sh effort <n> high\|medium\|low` |

`scripts/gh/fields.sh show <n>` prints all three with the labels and the
milestone. `scripts/gh/fields.sh new <type> <priority> <effort> <gh issue
create args…>` creates an issue that carries all three from the start, so
every issue is filed through it, never through a bare `gh issue create`.

The priorities read: `Urgent` is drop everything, `High` is the current
focus, `Medium` is normal, `Low` is the backlog. Effort is the size of the
work as filed: `Low` is one sitting, `Medium` is one pull request, `High` is
more than one pull request or a design that has to be held in context. Every
open issue carries one; it never changes the order of the worklist, which the
priority and the age of the issue decide.

The type maps to the conventional-commit type of the branch and the commit: a
`Bug` is a `fix`, a `Feature` is a `feat`, and a `Task` names its kind with
exactly one work-kind label. The labels `bug`, `enhancement` and `P0` to `P3`
that carried type and priority before are deleted, and `scripts/gh/labels.sh`
retires them again wherever they reappear. Labels carry what the platform has
no field for:

- **Work kind, on a `Task` only, exactly one:** `documentation`, `chore`,
  `refactor`, `perf`, `test`, `ci`. A `Bug` and a `Feature` carry none.
- **Area:** `site` (the page and its assets), `brand` (the mark and the
  palette), `build` (the assemble script and the checks).
- **Workflow:** `security`, `dependencies` (Dependabot).

## Branches use conventional types

`<type>/<kebab-case-slug>` with `type` in `feat`, `fix`, `chore`, `docs`,
`refactor`, `perf`, `test`, `ci`, `build`, `release`. Pick the type by the
dominant change: a `Bug` is `fix/`, a `Feature` is `feat/`, and a `Task`
takes its work-kind label. Never force-push `main`.

## A change in another repository

The products and the shared libraries are separate repositories. When work here turns up a defect
there, file it there with the evidence from here, and link the issue from the
work in this repository. A local workaround carries a `TODO(#N)` pointing at the
upstream issue and is removed when the fix lands.

## Never add AI or Claude attribution

Commit messages, PR text, issue and comment bodies describe only the change:
no `Co-Authored-By: Claude`, no "Generated with", no bot trailer, ever. This is
absolute and has no exceptions. The `no_attribution_guard.sh` PreToolUse hook
blocks the command before it runs.
