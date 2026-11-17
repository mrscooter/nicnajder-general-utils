---
name: 3approaches
description: Build one taste decision in a GUI app on any stack (visual design, layout, copy, motion, an interaction flow) as N switchable variants (default 3) behind a temporary development-only switcher, so they are compared live in the running app and one is picked; supports iteration ("keep A, add 2 more"), finalization ("go with B") that leaves zero trace of the experiment, and a handoff mode where an unattended agent delivers all variants plus a manifest for a later session to finalize. One invocation is one decision; several can be live side by side, each with its own switcher. Use when the user or a calling agent invokes /ncn:3approaches or 3designs, or asks for multiple switchable design variants, copy variants or approaches of a UI element, view or text to compare; also for side-by-side drafts of a taste decision outside a running app. Never for APIs, data, program logic or anything with a correct answer.
---

# 3approaches - compare N live variants of one taste decision, pick, leave no trace

One decision whose right answer is a matter of taste becomes N variants built side by side in the app and switched at runtime by a development-only switcher. The user compares them in the real running app (real data, real state, any window size), picks, and finalization removes every trace of the experiment. This replaces mockups, screenshot matrices, copy documents and branch-per-variant.

## Scope guard

In scope: any choice in an app with a GUI that is judged by looking at it or reading it in place - visual design, layout, copy (headline, call to action, section text), motion, the order or shape of an interaction flow. Any stack: web, desktop, mobile. Out of scope: APIs, data, program logic, anything with a correct answer - say so and handle the task normally. A taste decision with nothing to switch at runtime (a name, an email): see "Decisions outside a running app".

## One invocation, one decision

- The caller - a person or an orchestrating agent - names the decision (what is varied) and N. N defaults to 3; any N of 2 or more is fine.
- Do not split the decision into several, merge it with another one, or add decisions of your own. What to vary, in what granularity and in which combination is the caller's job, including whether the results will make sense together.
- An ask that names several decisions ("the page design, the hero copy and the button label") is several invocations: one experiment each, each with its own variants and its own switcher, switched and finalized independently.

## Invocation grammar

Free text; canonical forms:

- "use /ncn:3approaches: <the decision>" - N defaults to 3.
- "... in N variants" - overrides N.
- "keep A [and C], add K more" - iteration round (see Iteration).
- "go with B" / "layout of B with the color of A" - finalization (see Finalization).
- "handoff mode, manifest at <path>" - said by the caller of an unattended run (see Handoff mode).
- "finalize from manifest <path>: <pick>" - finalization of an experiment this session has not seen.

With several experiments live, iteration and finalization requests name the one they mean.

## Variant rules

- Every variant needs a one-line thesis on a distinct axis of difference (e.g. "denser header chrome", "leads with the price"). Distinct theses are what make the comparison worth the user's time.
- Every variant gets a short descriptor (about two words) shown on its switcher button or in its tooltip, e.g. "B - dense header".
- Theses handed in by the caller are binding: build exactly those.
- Copy variants differ in the argument they make (what they lead with, which objection they answer), not in wording alone.
- If the decision only supports K < N genuinely distinct theses, STOP and ask the user: pad to N with near-duplicates anyway, or go with K. Never silently pad, never silently reduce. (Handoff mode decides instead of asking, see there.)
- A change to something that already exists: auto-include an "Original" variant (the untouched current state, key `O`) on top of the N asked-for variants; Original is the default. Something new: no Original; variant A is the default.
- This skill is the comparison protocol, not the craft. For a visual decision load a design skill, for a copy decision a copywriting skill, when the session offers one.

## Copy variants

- Variant texts live with the experiment's code, never in the project's translation files, and only in the project's primary language. The Original variant keeps reading the existing texts from where they are, so tests and other languages see what they saw before.
- At finalization the winning text moves into the project's translation mechanism, in every language the project ships.
- This holds for every text the experiment introduces, including new texts inside a design variant (the labels of a new section).

## The switcher

Placed where the decision is judged:

- A decision judged at one place (the copy of one section, one button): a small inline switcher next to that element.
- A decision that changes a whole view or the whole app: a floating panel.

One button per variant, showing letter + descriptor, the active one highlighted, the thesis in a tooltip or beside it. An inline switcher may show letters only when space is tight.

## Invariants - any implementation must satisfy these

This skill prescribes no mechanism. Find in the project how its stack tells a development run from a release build and from a test run, where a per-machine choice can be persisted, and how the UI is re-rendered on a change; build the smallest thing that satisfies the list below. If the stack cannot satisfy an invariant, say which one and why before building (handoff mode: record it in the manifest).

- The switcher exists only in a development run: not in a release/production build, not under a unit-test runner, not under UI automation. Check each of the three, they are usually detected in different ways.
- The default variant (Original on changes, A on new things) is what tests, release builds and automation see. The existing test suite stays green for the whole life of the experiment, untouched.
- Switching takes effect in the running app, without a rebuild.
- The choice persists over a restart or reload, in local per-machine storage that is never committed, read and written defensively. The experiment's code works when that storage is missing and when no switcher is on screen: components rendered bare in a unit test must not break.
- The persisted choice is validated against the current set of variants; anything stale or unknown falls back to the default. This is what makes iteration rounds safe.
- Automation can select a variant without the switcher, by setting the persisted choice before the app starts.
- The switcher works wherever its subject is rendered, under every state of the app, including inside the variants of another live experiment.
- The switcher is visibly a dev tool and changes nothing it does not control: an inline switcher takes no space in the layout (every real element is exactly where it is without it), and no switcher covers the switcher of another live experiment.
- Technique choice (internal, never user-facing): pick the cheapest technique that expresses the variants. Variants that differ only in styling or text swap names or values on identical structure; only variants that differ in structure swap blocks or components. Their cleanup steps differ, so do not pay for structure-swapping where a name or a value suffices.
- The auxiliary code (the switching, the persistence, the switcher, the variants themselves) gets NO tests - it is throwaway by design. A project rule of "new code needs tests" does not apply to it; state that explicitly in the run if the project has such a rule.
- Everything the experiment adds is traceable for mechanical removal (see next section).

## Implementation form and traceability

- How the variants are written is decided per task, by what is varied and by how the codebase is written: variant-suffixed names in the existing files (`btn-A`, `btn-B`, `btn-C`), entries in an existing stylesheet or table, a small table of texts, separate blocks or components where the structure differs. Use the lightest form that expresses the variants; do not create files or folders the variants do not need.
- Whatever the form, the experiment must be removable by someone who has never seen it. Before building, fix its trace: the search pattern(s) that find everything the experiment adds and nothing else (a naming scheme, a marker, a path). Then keep to it.
- The trace is unique to this experiment. Grep `AUXILIARY` to see which experiments are already live, and choose names that cannot be confused with theirs or with ordinary code: a bare `-A` suffix is fine for one experiment in a stylesheet, not when a second experiment uses letters there too.
- One anchor comment, `AUXILIARY(<id>)`, where the switcher is mounted: the decision and the trace pattern(s). `<id>` is a short slug of the decision (`hero-copy`, `dashboard-layout`). It is the entry point for finalization.
- Experiments do not depend on each other's code: finalizing one leaves the others working.

## Iteration

On "keep A, add K more":

- Kept variants keep their letters and descriptors.
- Losing variants are deleted, in whatever form they were written.
- New variants take the freed letters, with fresh theses and descriptors.
- Original (when present) always survives iteration and stays the default.
- A persisted letter that no longer exists falls back to the default via the validation invariant - verify this after the round. A persisted letter that was reused shows the new variant.

## Finalization

Works from the repository (and the manifest, when there is one), never from conversation memory. Start at the anchor comment (`AUXILIARY(<id>)`), run its trace pattern(s), and diff the touched files against the commit the experiment started from.

The pick:

- One letter ("go with B"), or a mix ("layout of B with the color of A", "headline of C with the subhead of A"). A mix is built as the final state; there is no extra comparison round unless the user asks for one.

Steps:

1. Promote the winner into the real code under its final, variant-free names (`btn-B` becomes `btn`): inline its values, promote its structure into the real component, move its text into the translation mechanism in every shipped language (translate from the primary language). A text that replaces an existing one overwrites that entry; a new text gets a new entry named by the project's convention.
2. If the pick is Original: put back whatever the experiment took out of the real code (original values or names that became a variant, the original text lookup). Where the original was never touched, deleting the experiment is the whole step.
3. Delete everything else the trace finds: the losing variants, the switching, the persistence, the switcher, the anchor comment. Other live experiments stay as they are, also where this experiment's code sat inside their variants or theirs inside this one's.
4. Leftover grep MUST return empty: the trace pattern(s), `AUXILIARY(<id>)` and the persistence key over the source tree. Then read the lines added since the starting commit (the diff, filtered to added lines) for what slipped outside the trace: variant letters in names, "variant"/"approach" naming the experiment introduced. Ordinary words, other live experiments and records of earlier runs do not count.
5. From here on the code is ordinary project code and the project's rules apply to it again: update every test that asserts what the winner replaced (search the whole test tree for the surface, not only its own test file), add the tests the project requires for new behavior.
6. The project's lint, tests and build, plus a look at the final state in the running app, in every shipped language. Where the variants state is still reachable (the variants commit, a stash), compare the final state with the picked variant selected through the persisted choice: it must be what the user judged.
7. Commit.
8. Report: the pick as built, every text you translated (nobody has reviewed those translations), tests changed and why.

## Handoff mode

For a run with no user present; the caller says so and names the manifest path. Differences from the interactive protocol:

- Never ask. Where the interactive protocol stops to ask (fewer than N distinct theses, an invariant the stack cannot satisfy), decide, and record the decision in the manifest.
- Build every variant, leave the switcher in, stop before finalization.
- Write the manifest at the path the caller names, from `templates/manifest.md` in this skill's directory: the experiment id, where the variants live and their trace, placement of the switcher, persistence key, default, per variant the letter, descriptor, thesis, what to look at and the weakness its author sees in it; how to run the app and switch; how automation selects a variant; what finalization will have to touch; the exact finalization request to make.
- Commit the variants, on a non-default branch only, in a commit whose message says the state is not final (e.g. "feat: <summary> (variants, not final)"). That commit stays in the branch history after finalization; squash-merge the branch if the history has to be free of the experiment too.
- Finalization must be possible for a session that has never seen the run: everything it needs is in the repository (the anchor comment, the trace, the variants commit) and the manifest.

## Decisions outside a running app

A taste decision with nothing to switch at runtime (a product name, an email, a paragraph of a document): N drafts side by side in the reply, or in one scratch file when they are long. Same thesis rule, same letters; the user picks or mixes, the rest is discarded. No switcher, no persistence.

## Commits

Interactive: never commit exploration rounds. Commit once, after finalization: the picked, finished result. Handoff mode: the one "not final" commit described there, then the finalization commit.
