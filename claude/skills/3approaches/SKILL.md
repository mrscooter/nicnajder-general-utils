---
name: 3approaches
description: Build a taste decision in a web app (visual design, layout, copy, motion, an interaction flow) as N runtime-switchable variants (default 3) behind temporary dev-only switchers, on one or more independent axes, so the user compares them live in the running app and picks; supports iteration ("keep A, add 2 more"), finalization ("go with B", "design B, hero copy C") that leaves zero trace of the experiment, and a handoff mode where an unattended agent delivers all variants plus a manifest for a later session to finalize. Use when the user invokes /ncn:3approaches or 3designs, or asks for multiple switchable design variants, copy variants or approaches of a UI element, view, page or text to compare; also for side-by-side drafts of a taste decision outside a running app (a name, an email). Never for APIs, data, program logic or anything with a correct answer.
---

# 3approaches - compare N live variants of a taste decision, pick, leave no trace

A decision whose right answer is a matter of taste becomes N variants built side by side in the app and switched at runtime by dev-only switchers. The user compares them in the real running app (real data, real state, any viewport), picks, and finalization removes every trace of the experiment. This replaces mockups, screenshot matrices, copy documents and branch-per-variant.

## Scope guard

In scope: any choice in a web app that is judged by looking at it or reading it in place - visual design, layout, copy (headline, call to action, section text), motion, the order or shape of an interaction flow. Out of scope: APIs, data, program logic, anything with a correct answer - say so and handle the task normally. A taste decision with nothing to switch at runtime (a name, an email): see "Decisions outside a running app".

## Invocation grammar

Free text; canonical forms:

- "use /ncn:3approaches: <ask>" - one axis, N defaults to 3.
- "... in N variants" - overrides N, for the run or for the axis it is said about.
- "axes: page design (global), hero copy (local), ..." - several axes in one run (see Axes).
- "keep A [and C], add K more" - iteration round; with several axes the axis is named ("hero copy: keep A, add 2 more").
- "go with B" / "design B, hero copy C" / "layout of B with the color of A" - finalization.
- "handoff mode, manifest at <path>" - said by the caller of an unattended run (see Handoff mode).
- "finalize from manifest <path>: <picks>" - finalization of a run this session has not seen.

## Axes

A run compares one or more axes. An axis is one independent decision ("overall page design", "hero copy") with its own N variants, its own letters and its own default.

- Axes are named, never invented. They come from the user or the issue. Interactive run: you may propose an axis, and build it only after the user agrees. Handoff mode: only the axes the caller handed in.
- An axis is heavy or light. Heavy: it changes markup, structure or the visual system (a page design, a layout, a flow). Light: it swaps text or class strings in one place (the copy of one section, a button label, an accent color).
- At most 2 heavy axes per run: each one multiplies the build cost, and heavy axes interact, so a third makes the combinations impossible to judge. Light axes have no fixed limit.
- Every axis can be judged on its own. If the best variant of one axis depends on the choice in another, they are one axis: merge them (headline, subhead and button of a hero are one "hero copy" axis, not three).
- Light variants hold under every heavy variant: a text must fit each page design it can appear in. Check each heavy variant with the default light variants, and each light variant under the default heavy variant; the full cross product is not checked. If the default heavy variant does not render the element a light axis controls, check that axis under the first heavy variant that does.
- Each axis has a placement. `local`: a small inline switcher rendered next to the element the axis controls (the hero copy switcher sits in the hero section) - for a decision judged at one place on the page. `global`: the floating panel - for an axis that changes a whole page or the whole app.

## Variant rules

- Every variant needs a one-line thesis on a distinct axis of difference (e.g. "denser header chrome", "leads with the time the doctor gets back"). Distinct theses are what make the comparison worth the user's time.
- Every variant gets a short descriptor (about two words) shown on its switcher button or in its tooltip, e.g. "B - dense header".
- Theses handed in by the caller are binding: build exactly those.
- Copy variants differ in the argument they make (what they lead with, which objection they answer), not in wording alone.
- If an axis only supports K < N genuinely distinct theses, STOP and ask the user: pad to N with near-duplicates anyway, or go with K. Never silently pad, never silently reduce. The same stop applies to a third heavy axis and to two axes that turn out to depend on each other. (Handoff mode decides instead of asking, see there.)
- A change to something that already exists: auto-include an "Original" variant (the untouched current state, key `O`) on top of the N asked-for variants of that axis; Original is the default. Something new: no Original; variant A is the default.
- This skill is the comparison protocol, not the craft. For a visual axis load a design skill, for a copy axis a copywriting skill, when the session offers one (for example `frontend-design`, `copywriting`).

## Copy variants

- Variant texts live in the dev module's variant table, never in the project's translation files, and only in the project's primary language. The Original variant of a copy axis keeps reading the existing translation keys, so tests and other languages see what they saw before.
- At finalization the winning text moves into the project's translation mechanism, in every language the project ships.
- This holds for every text the experiment introduces, including texts inside a heavy variant (the labels of a new section).

## Invariants - any implementation must satisfy these

Each holds per axis.

- The switchers (panel and inline) render only on the dev server: not in a production build, not under a unit-test runner, not under browser automation. `navigator.webdriver` is set by Playwright, Selenium and Puppeteer in every browser they drive - gate on it.
- The default variant (Original on changes, A on new things) is what tests, prod and automation see. The existing test suite stays green for the whole life of the experiment, untouched.
- One store for all axes, keyed by axis, one storage key per axis. It works without any switcher mounted and without any provider, and touches nothing but localStorage behind try/catch. Unit tests render components bare and stub globals; the store must survive that.
- The persisted choice of an axis is validated against that axis's current variant table; anything stale or unknown falls back to the default. This is what makes iteration rounds safe.
- Technique choice (internal, never user-facing): variants that differ only in styling or text swap class strings or texts on identical markup (one table keyed by variant letter); variants that differ in markup structure swap markup blocks/subcomponents behind the same store. Pick the cheapest technique that expresses the variants - their cleanup steps differ, so do not pay for structure-swapping where a table suffices.
- Inline switchers are visibly dev tools (same styling language as the panel) and must not shift the layout they sit in: the page with the switchers shown has every real element exactly where it is with them hidden.
- The auxiliary code (store, variant tables, switchers, variant subcomponents) gets NO tests - it is throwaway by design. A project rule of "new code needs tests" does not apply to it; state that explicitly in the run if the project has such a rule.
- All auxiliary code is isolated for mechanical removal: one dedicated dev folder, one mount line for the panel, minimal touch points in the real component(s). Every file outside the dev folder that imports from it carries one `AUXILIARY` comment at the import, naming the driving issue/task and pointing at the dev module. The repository alone (its files and its diff against the starting commit) must be enough to find and remove the experiment.

## Verified recipe: React + Vite + Tailwind

Proven on AmbulaSurvey: issue #49 (Ambulance Details spacing, one axis, 3 variants, finalized clean) and the landing page run of nicnajder-general-utils issue #21 (one heavy global axis, three light local axes, iteration, handoff, finalized by a session that had only the repository and the manifest).

The dev folder, e.g. `src/components/dev/`:

- `approaches.js` - plain `.js` with no component exports (`eslint-plugin-react-refresh`'s `only-export-components`, on by default in Vite React templates, errors when a file mixes component and non-component exports). It holds:
  - `AXES`: one entry per axis id (camelCase, e.g. `pageDesign`, `heroCopy`) with `label`, `placement` (`'global'` | `'local'`), `default`, and `variants` keyed by letter (`O` for Original). Each variant has `descriptor` and `thesis`, plus its payload where it has one: `classes` (complete Tailwind utility strings, never assembled from fragments, so Tailwind's scan finds them), `text` (primary language) or nothing for a structural variant. Name the fields of a payload after the parts a user would name when mixing (`tagline`, `description`; `button`, `band`), so "tagline of B with the description of A" maps onto the table.
  - The store: `getLetter(axisId)` reads `localStorage` key `approaches:<task>:<axisId>` behind try/catch and returns the stored letter only if it is a key of that axis's `variants`, else the default; `setVariant(axisId, letter)` writes it and notifies subscribers.
  - `useApproach(axisId)`: `useSyncExternalStore(subscribe, () => getLetter(axisId))`, returns the active letter plus its table entry. No provider.
- `ApproachSwitchers.jsx` - exports only components: `ApproachPanel` and `ApproachInline`. Both return null when `!import.meta.env.DEV`, when `import.meta.env.MODE === 'test'` (Vitest runs with `DEV` true and no `navigator.webdriver`, so without this the switchers render inside unit tests) or when `navigator.webdriver` is set.
  - `ApproachPanel`: fixed corner, high z-index, amber dashed border, one row per global axis (label, then one button per variant showing letter + descriptor, active one highlighted, thesis in the `title`).
  - `ApproachInline({ axis })`: the same styling at 10px, letter buttons only, axis label + descriptor + thesis in each button's `title`. `position: absolute` with no offsets and `-translate-y-full`: it sits at its static position just above the element that follows it and takes no space, so no parent needs `relative` and nothing moves. Keep it this small: a wider one covers the content above it and overflows the viewport when its anchor is near the right edge.
- Structural variants: one subcomponent file per variant (`<Thing>DesignA.jsx`, ...), plus any piece several of them share.
- When heavy and light axes meet: one content hook (`use<Thing>Content()`) reads all light axes and returns what the markup needs (`text ?? t('existing.key')` for copy, `classes` for styling). Every structural variant and the original markup consume that one hook and mount `<ApproachInline axis="..." />` right before each controlled element. The Original entry of a class axis holds the original class strings verbatim, so the default rendering is unchanged.

Touch points outside the dev folder:

- `<ApproachPanel />` mounted once at the app root, with an AUXILIARY comment at its import.
- The real component: reads the heavy axis with `useApproach`, returns the active variant's subcomponent, else falls through to its original markup, which reads the content hook and mounts the inline switchers. One AUXILIARY comment at its dev imports.

Driving it from automation:

- Select a variant: set the storage key before the page loads, e.g. Playwright `await page.addInitScript(() => localStorage.setItem('approaches:<task>:heroCopy', 'B'))`.
- See and click the switchers themselves from Playwright: launch Chromium with `args: ['--disable-blink-features=AutomationControlled']`, which leaves `navigator.webdriver` false.
- Layout-shift check: compare the bounding boxes of the real elements between such a browser (switchers shown) and a default one (switchers hidden), per heavy variant. Also check for horizontal overflow at the narrowest supported width.

Tailwind note: in non-Tailwind React projects the identical mechanism works with ordinary CSS class names.

## Other stacks

Add a section for another stack only after a real, tested run of this skill on that stack grounds it - never write a speculative recipe. Unverified mechanics presented as instructions are worse than an honest gap.

## Iteration

On "keep A, add K more" (per axis):

- Kept variants keep their letters and descriptors.
- Losing variants' table entries (and subcomponents, if structural) are deleted.
- New variants take the freed letters, with fresh theses and descriptors.
- Original (when present) always survives iteration and stays the default.
- A persisted letter that no longer exists falls back to the default via the validation invariant - verify this after the round. A persisted letter that was reused shows the new variant.

## Finalization

Works from the repository (and the manifest, when there is one), never from conversation memory. Start by reading the dev module, grepping `AUXILIARY`, and diffing the touched files against the commit the experiment started from: the AUXILIARY comment names the file, the diff shows the lines.

The pick:

- One letter per axis ("design B, hero copy C"). An axis the user did not mention: ask (a finalization from a manifest names every axis).
- A mix inside one axis ("layout of B with the color of A", "headline of C with the subhead of A") is built as the final state. There is no extra comparison round unless the user asks for one.

Steps:

1. Promote each winner into the real code: inline its class strings, promote its markup into the real component, move its text into the translation mechanism in every shipped language (translate from the primary language). A text that replaces an existing one overwrites that key; a new text gets a new key named by the project's convention. Texts inside a winning heavy variant move too.
2. An axis whose pick is Original has nothing to promote only when the code that renders it is the untouched original. Under a winning heavy variant, or wherever the content hook stands in for the original, resolve it by hand: put back the original translation key or the `O` class strings that the hook and the table were supplying.
3. Delete the dev folder, the panel mount and every AUXILIARY touch point.
4. Leftover grep MUST return empty. What must be gone is everything the experiment added, so run it over the lines added since the starting commit (`git diff <base> | grep '^+' | grep -inE '<names>'`) and over the source tree for the names that are unique to it. The names: `AUXILIARY`, the dev folder path, every exported name and file name of the dev folder, every axis id, the storage key prefix, data attributes, and "variant"/"approach" naming the experiment introduced. Ordinary words (an axis called `accent`, the word "variant" in unrelated code, records of earlier runs) are judged in the diff form only.
5. From here on the code is ordinary project code and the project's rules apply to it again: update every test that asserts what the winner replaced (grep the test tree for the surface, not only its own test file), add the tests the project requires for new behavior.
6. Lint + tests + build, plus a browser look at the final state in every shipped language. Where the variants state is still reachable (the variants commit, a stash), compare the final page with the picked combination selected through the storage keys: it must be the page the user judged.
7. Commit.
8. Report: the picks as built, every text you translated (nobody has reviewed those translations), tests changed and why.

## Handoff mode

For a run with no user present; the caller says so and names the manifest path. Differences from the interactive protocol:

- Never ask. Where the interactive protocol stops to ask (fewer than N distinct theses, a third heavy axis, two axes that depend on each other), decide, and record the decision in the manifest.
- Build every variant of every axis, leave the switchers in, stop before finalization.
- Write the manifest at the path the caller names, from `templates/manifest.md` in this skill's directory. Per axis: name, placement, storage key, default, and per variant the letter, descriptor, thesis, what to look at, and the weakness its author sees in it. Then: how to run the app and switch, how automation selects a variant, what finalization will have to touch (the starting commit, the leftover grep line, the tests that assert the changed surface), and the exact finalization request to make.
- Commit the variants, on a non-default branch only, in a commit whose message says the state is not final (e.g. "feat: <summary> (variants, not final)"). That commit stays in the branch history after finalization; squash-merge the branch if the history has to be free of the experiment too.
- Finalization must be possible for a session that has never seen the run: everything it needs is in the repository (the dev folder, the AUXILIARY comments, the variants commit) and the manifest.

## Decisions outside a running app

A taste decision with nothing to switch at runtime (a product name, an email, a paragraph of a document): N drafts side by side in the reply, or in one scratch file when they are long. Same thesis rule, same letters; the user picks or mixes, the rest is discarded. No switcher, no store.

## Commits

Interactive: never commit exploration rounds. Commit once, after finalization: the picked, finished result. Handoff mode: the one "not final" commit described there, then the finalization commit.
