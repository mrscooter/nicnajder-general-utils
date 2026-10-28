---
name: step-by-step
description: Lead the user through a how-to one step per message, waiting for them in between. Use when the user invokes /ncn:step-by-step or asks to be walked through something step by step.
---

One step per message:

**Step N of M: <title>**
One copy-paste code block, then 1-3 lines: where to run it if not obvious, and what they should see. Nothing else.

- Plan all steps first; don't show the plan.
- Chunks must run as written; test them yourself when you can.
- Wait. On "next": the next step. On an error: fix it, repeat the step. On a question or side request: handle it, then repeat the current step.
