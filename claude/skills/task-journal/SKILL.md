---
name: task-journal
description: Set up and maintain a persistent, on-disk task-journal for long, multi-session, methodical work (systematic bug hunts, staged migrations/refactors, audits, combinatorial test campaigns) that outlives a single context window or is resumed across sessions. Splits working notes by role + mutability — an immutable task brief, an evolving reference, a live status tracker, append-only progress log and findings, and an on-request timestamped context-restore snapshot. Use when a task is too big to hold in one context and needs durable notes that survive compaction and handoffs; skip short/one-shot tasks (use TodoWrite instead).
---

# Task Journal

Persistent working memory for a single long task, kept as a small set of plain-markdown files on
disk so the work survives context-window compaction, session restarts, and handoffs.

The point is not "take notes" — it is to **split the notes by temporal role and mutability** so
each file stays short, single-purpose, and trustworthy. A single `NOTES.md` rots into an
unreadable blob; the split below does not.

## When to use

Work that is **long, multi-session, and methodical**:
- systematic bug hunts / root-cause campaigns
- large migrations or refactors carried out in stages
- audits or reviews with many items
- combinatorial test campaigns (a grid of cases)
- anything that will outlive one context window or be resumed across days

## When NOT to use

Skip it for short or one-shot tasks — a quick fix, a single edit, a one-off question. For
ephemeral in-session step tracking use **TodoWrite**, not this. Don't create journal ceremony
where a checklist would do.

Also distinct from the **memory system** (durable facts/preferences that span *many* tasks). The
task-journal is working memory for *one* task; memory is what you carry *between* tasks.

## The principle: separate by role + mutability

| File | Role | Mutability |
|---|---|---|
| `task_brief.md` | **Bedrock** — issue/ticket link(s), problem statement, scope & non-goals, success criteria | **Immutable** — set once at the start; never edit |
| `essential_findings.md` | Orientation/reference you build up — key components/code map, how it runs, where config & state live, commands & recipes, cross-references | Grows as you learn |
| `style_of_work.md` | Method — approach, **verification** (confirm progress without regression), the per-unit working loop, phases | Slow-changing |
| `work_status.md` | Live tracker — work items + each one's status; single source of truth for "what's next" | Mutable (overwrite in place) |
| `progress_log.md` | Dated narrative — what happened each session, decisions, direction changes | Append-only (never edit past entries) |
| `detailed_findings.md` | Deep per-item write-ups — bug / feature-or-chore / decision | Append-only |
| `out_of_scope_followups.md` | Parking lot for things found that belong elsewhere | Append-only |
| `baseline_state.md` | Captured original/pristine state for safe revert (live-system tasks only) | Set once |
| `context_restore-<YYYY-MM-DD-HHMM>.md` | Session handoff snapshot — TL;DR, blockers, end-state, next entry point | **On explicit request only** (see below) |

**Core (start here):** `task_brief.md`, `essential_findings.md`, `style_of_work.md`,
`work_status.md`, `progress_log.md`. The rest are optional — add a file only when the task needs
it. Keep the set lean; too many files re-creates the blob problem in distributed form.

## Where the journal lives

**There is no default — ask the user where the journal should live**, then use that path for the
rest of the task. If the project's CLAUDE.md defines a home for working notes, follow it.

## Setup (scaffold)

When starting a qualifying task, create the journal folder and copy in the **core** templates from
this skill's `templates/` directory (alongside this SKILL.md); add optional templates only as
needed:

```
mkdir -p <journal-dir>
cp <skill-dir>/templates/{task_brief,essential_findings,style_of_work,work_status,progress_log}.md <journal-dir>/
```

Fill `task_brief.md` first — it anchors everything — then add a doc read-order note at the top of
`style_of_work.md`.

**Every journal file opens with a one-line comment stating its purpose** — the `<!-- … -->` header
at the top of each template. Always keep that header in the working file you create from the
template; if you ever add a journal file that is not from a template, give it the same kind of
one-line purpose comment at the very top.

## Working loop

- **On resume / session start:** read `task_brief.md` (what we're here to do) → the latest
  `context_restore-*.md` if one exists (where we left off) → `work_status.md` (what's next) →
  `essential_findings.md` as needed. This reconstructs context after compaction or a gap.
- **While working:** keep `work_status.md` current (overwrite each item's status as it changes);
  append a dated entry to `progress_log.md` per session/milestone; put deep per-item analysis in
  `detailed_findings.md`; park out-of-scope discoveries in `out_of_scope_followups.md`; fold any
  reusable command/location/gotcha into `essential_findings.md` so it isn't re-derived.
- **Never edit `task_brief.md`.** If the mandate genuinely changes, note the change in
  `progress_log.md` rather than rewriting the brief.

## Context restore is on explicit request only

Do **not** write `context_restore-*` as part of the routine loop. Create it **only when the user
explicitly asks** (e.g. "create a context restore file"), typically at session end. Name it
`context_restore-<YYYY-MM-DD-HHMM>.md` (date and time); the newest timestamp is authoritative. It
should let a cold next session reconstruct state fast: TL;DR, blockers/incidents not yet in the
logs, end-of-session runtime state, live constraints, and the next entry point. Keep or prune
prior restore files at the user's discretion.
