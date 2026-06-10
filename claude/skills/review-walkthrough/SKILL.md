---
name: review-walkthrough
description: Guide a code-review findings list through a one-at-a-time triage discussion, then implement the agreed outcome. For each finding present Summary, Technical detail, Severity, Type, and a Proposed fix, then STOP and gather the user's accept/reject/defer/won't-fix/discuss decision before moving to the next; after every finding is resolved, show a decision log, get an explicit go-ahead, then implement (apply fixes, add regression tests, file issues for deferred items, verify). Use when the user invokes /review-walkthrough or asks to go through review findings step by step / one by one. Pairs with /code-review (which produces the findings); a process skill, not language-specific.
---

# review-walkthrough - triage review findings one at a time, then implement

A list of review findings becomes a guided, decision-by-decision conversation: each finding is presented in a fixed shape, you stop and collect the user's call, and nothing gets built until every finding has a decision and the user gives an explicit go-ahead. Then you implement exactly what was agreed - fixes, tests, filed issues for deferrals - and verify.

## Scope guard

Use when there is a **list of review findings to work through decision-by-decision** - typically straight after `/code-review`, or from a findings list the user pastes. Not for:
- Producing the findings in the first place - that is `/code-review`'s job.
- A single trivial finding - just propose and fix it inline, no ceremony.

This is a process skill: it is language- and repo-agnostic. It adapts to the project's own conventions (issue templates, labels, test layers, verification gate) rather than assuming any.

## Invocation grammar

- "/review-walkthrough" - triage the findings already in context (most recent `/code-review`).
- "/review-walkthrough <pasted list | path/to/findings.json>" - triage the supplied set.
- "go through these one by one", "let's discuss the findings step by step" - same skill.

## Inputs - where the findings come from

Resolve the findings set, in priority order:
1. **Args** - a pasted list, a JSON array, or a file path the user passed.
2. **Conversation** - the most recent `/code-review` output above.
3. **Neither** - ask the user to run `/code-review` first or paste a findings list. Do not invent findings.

Confirm the set and count back to the user, and **number the findings in the review's ranked order** (most severe first). That numbering is stable for the rest of the session - the user will refer to "Finding 7", "fold into 12", etc.

## Phase 1 - Guided triage (one finding at a time)

Present **exactly one finding**, then stop. Fixed shape:

```
## Finding N - <one-line title>

**Severity:** Critical | High | Medium | Low  ·  **Type:** Bug | Clean-code | Efficiency | Altitude | Test-gap | Enhancement

**Summary:** High-level, plain language - what the problem is and why it matters. No code.

**Technical detail:** Concise. The concrete trigger (inputs/state -> wrong output/crash), with file:line. Skip this line entirely if the summary already conveys it - do not pad.

**Proposed fix:** Concrete. A short code snippet if it clarifies. If there are several real options, recommend one (list it first, mark it "(recommended)") and give the trade-off in a single line.

Accept / reject / discuss?
```

Then **STOP and wait for the user's input.** Do not move to the next finding until the current one has a decision.

Rules while triaging:
- **One at a time.** Never present more than one finding at a time; never pre-dump all findings' details up front. The whole value is focus.
- **Severity + Type on every finding.** If the user asks for them and they're missing, add them.
- **Ground every claim in the actual code.** Read the enclosing file before asserting a finding is real. When the user pushes back or you are uncertain ("is this actually a 500?", "is this even probable?"), verify by reading the code or running a quick repro/test - and if you were wrong, say so plainly and correct it. Never defend a claim you can't ground.
- **Recommend, don't survey.** Give your honest call and the trade-off, not an exhaustive menu. Reassess severity when the user challenges it (a self-recovering, rare edge is Low, not Medium - say so).
- **Support discussion.** The user may ask questions, request an explanation of syntax, ask you to prove the bug, or propose an alternative fix. Engage until a decision is reached. Honest pushback over agreement: if the user's proposed fix is worse, say why.
- **Record a decision** for each finding, from this vocabulary:
  - **accept** - fix as proposed.
  - **accept-with-changes** - capture the exact agreed change.
  - **reject** - leave as is.
  - **defer** - file an issue at implementation time (don't fix now).
  - **won't-fix** - record the rationale (e.g. "correct behavior", "non-scenario").
  - **fold into Finding M** - merge this finding's handling into another.
- **Keep a running decision log** (TodoWrite) so nothing is lost across a long session.

## Phase 2 - Decision log + gate

When every finding has a decision, present a single consolidated table:

| # | Finding | Decision |
|---|---|---|
| 1 | ... | accept / reject / defer (#NN) / won't-fix / fold->M |

State plainly: **"All input gathered - ready to implement."** Then ask for an explicit go-ahead. **Do not start implementing before the user confirms.**

## Phase 3 - Implement (only on confirmation)

First, **discover the project's conventions** (don't assume):
- Issue template(s) in `.github/ISSUE_TEMPLATE/`, and the title-prefix convention.
- The label set (`gh label list`) - create a precise label if the fitting one is missing and the user expects it; apply multiple labels when more than one fits.
- Test layers and the verification gate (CLAUDE.md / Makefile / a `preflight`/CI script).
- Commit-message rules.

Then carry out the agreed decisions:
- **Apply fixes** for accepted / accept-with-changes findings. Group related findings (e.g. several touching one helper) into coherent edits rather than fighting the same code repeatedly. Correctness fixes outrank cleanup if anything has to be sequenced or cut.
- **Add/update tests** per the repo's rules - a regression test for each bug fix, in the right layer (the test should fail before the fix, pass after).
- **File issues** for deferred findings using the matching template + labels. Reference the originating review.
- **(Only if the user asks)** record deferred + won't-fix decisions into a gitignored `REVIEW-REPORT.md` (list only those, with rationale, so a future `/code-review` run does not re-flag them) and add it to `.gitignore`. Do not produce this file by default.
- **Run the verification gate** and report per-step pass/fail (don't claim green without running it).
- **Commit** only when the user asks; **push / create PRs / file issues** are outward-facing - show the exact command (full refspec, full issue body) and wait for an explicit OK before running. No AI-attribution trailers. Defer to the global instructions for all git/remote etiquette.

## Invariants - any run must satisfy these

- One finding at a time; stop and wait for input on each. No bulk dumps.
- Every claim is grounded in the real code; verify on doubt or pushback; self-correct openly when wrong.
- No implementation work happens before the explicit Phase 2 go-ahead.
- Outward-facing operations (issue creation, push, PR) are gated behind showing the exact command and getting an explicit OK.
- Per-project conventions are discovered, never assumed.
- The findings numbering set in Phase 1 stays stable for the whole session.
