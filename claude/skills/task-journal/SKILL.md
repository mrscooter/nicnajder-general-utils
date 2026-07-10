---
name: task-journal
description: Set up and maintain a persistent on-disk task-journal for long, multi-session, methodical work (bug hunts, staged migrations/refactors, audits, combinatorial test campaigns) that outlives a single context window or is resumed across sessions. Splits working notes by role + mutability — immutable brief, evolving reference, live status tracker, append-only log and findings, on-request context-restore snapshot — so a task too big for one context survives compaction and handoffs. Skip short/one-shot tasks (use TodoWrite).
---

# Task Journal

Persistent working memory for one long task: plain-markdown files **split by role + mutability** so
each stays short and trustworthy and the work survives context-window compaction, restarts, and
handoffs.

## When to use (and not)

Use for **long, multi-session, methodical** work — bug hunts, staged migrations/refactors, audits,
combinatorial test campaigns, anything that outlives one context window or is resumed across days.
**Skip short/one-shot tasks** (use TodoWrite) — don't journal where a checklist would do. Distinct
from the **memory system**: this is working memory for *one* task; memory is what you carry
*between* tasks.

## The files: separate by role + mutability

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
`work_status.md`, `progress_log.md`. The rest are optional — add one only when needed; keep the set
lean.

## Setup

**No default — ask the user where the journal should live** (follow the project's CLAUDE.md if it
defines a home). Then create the folder and copy the **core** templates from this skill's
`templates/` directory; add optional ones as needed:

```
mkdir -p <journal-dir>
cp <skill-dir>/templates/{task_brief,essential_findings,style_of_work,work_status,progress_log}.md <journal-dir>/
```

Fill `task_brief.md` first — it anchors everything. **Every journal file opens with a one-line
`<!-- purpose -->` comment**: templates have one, keep it; add one to any non-template file.

## Working loop

- **On resume:** read `task_brief.md` → latest `context_restore-*.md` (if any) → `work_status.md`
  → `essential_findings.md` as needed.
- **While working:** just do the work. Do **not** write to the journal after each step — that
  cadence is slow and noisy. Carry new status/findings/decisions in context until asked to journal.
- **Never edit `task_brief.md`** — if the mandate genuinely changes, note it in `progress_log.md`.

## When to journal — on request only

Only when the user asks ("journal") — never automatically mid-session — journal the delta since
the last journaling (or session start).

## Context restore — on explicit request only

Not part of the routine loop. Create only when the user explicitly asks (e.g. "create a context
restore"), usually at session end. Name `context_restore-<YYYY-MM-DD-HHMM>.md` (date + time);
newest is authoritative. It's the fast cold-start snapshot (fields in the template).
