---
name: step-by-step
description: Lead the user through a how-to or tutorial one actionable step per message - a short heading, one copy-paste chunk to run, what they should see - then wait for "next" or a question before the following step. Use when the user invokes /ncn:step-by-step or asks to be walked through something step by step / one chunk at a time instead of a long write-up. Not for answers that fit in one command.
---

# step-by-step - one actionable chunk per message

## Before step 1
- Work out the whole sequence, but don't show it unless asked.
- Check the starting state (read-only) instead of assuming it. Ask first if the answer would change the steps.

## Each step: one message
**Step N of M: <title>**

One code block the user can paste and run as is, then 1-4 lines: what they should see, and what to do if they don't. Nothing else: no preview of later steps, no recap.

- One purpose per step. Several commands are fine if they belong together. A step that breaks something on purpose carries its own undo.
- Say where to run it when it isn't the obvious shell (new terminal, inside the app, as root).
- Real paths, no placeholders unless unavoidable (then say what to fill in). Run or dry-run a chunk yourself first when you can; never hand over something destructive untested.
- Prefer a step that proves something works (a check, a canary) over prose claiming it does.

## Between steps
- "next", "works", "ok": the next step.
- An error or unexpected output: find the cause, fix it (code, step or environment), and re-issue the corrected step under the same number.
- A question or side request: handle it, then resume with "Back to the tutorial: Step N is still next" and repeat that step.
- Keep M honest; renumber if the plan changes.

## After the last step
A two-line wrap-up: what is in place now, and where to look things up later (README, `--help`).
