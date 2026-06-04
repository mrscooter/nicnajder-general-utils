---
name: 3designs
description: Implement a web-app GUI/design ask as N runtime-switchable design variants (default 3) behind a temporary floating dev-only switcher, so the user compares them live in the running app and picks one; supports iteration ("keep A, add 2 more") and finalization ("go with B") that leaves zero trace of the experiment. Use when the user invokes /3designs or asks for multiple switchable design variants of a UI element, view, or menu. Design/GUI/styling/layout tasks only - never for APIs, data, or program logic.
---

# 3designs - compare N live design variants, pick one, leave no trace

One design ask becomes N variants implemented side by side in the app, toggled by a floating dev-only button panel. The user compares them in the real running app (real data, real state, any viewport), picks a winner, and finalization removes every trace of the experiment. This replaces mockups, screenshot matrices, and branch-per-design for GUI decisions.

## Scope guard

GUI/design/styling/layout work in web apps only: spacing, typography, color, component layout, whole-view or menu redesigns, new visual elements. If the ask is about functionality, APIs, data, or program logic, this skill does not apply - say so and handle the task normally.

## Invocation grammar

Free text; canonical forms:

- "use /3designs: <design ask>" - N defaults to 3.
- "... in N variants" - overrides N.
- "keep A [and C], add K more" - iteration round (see Iteration).
- "go with B" / "finalize B" - finalization (see Finalization).

## Variant rules

- Every variant needs a one-line design thesis on a distinct design axis (e.g. "denser header chrome", "muted secondary labels"). Distinct theses are what make the comparison worth the user's time.
- Every variant gets a short descriptor (about two words) shown on its switcher button, e.g. "B - dense header".
- If the design space only supports K < N genuinely distinct theses, STOP and ask the user: pad to N with near-duplicates anyway, or go with K. Never silently pad, never silently reduce.
- Redesigns of something that already exists: auto-include an "Original" variant (the untouched current design) on top of the N asked-for variants; Original is the default. New designs (no pre-existing element): no Original; variant A is the default.

## Invariants - any implementation must satisfy these

- The switcher panel renders only in dev builds and never under test automation. `navigator.webdriver` is set by Playwright, Selenium, and Puppeteer in every browser they drive - gate on it.
- The default variant (Original on redesigns, A on new designs) is what tests, prod, and automation see. The existing test suite stays green for the whole life of the experiment.
- The variant store works without the panel mounted and without any provider, and touches nothing but localStorage behind try/catch. Unit tests render components bare and stub globals; the store must survive that.
- The persisted choice is validated against the current variant table; anything stale or unknown falls back to the default. This is what makes iteration rounds safe.
- Technique choice (internal, never user-facing): variants that differ only in styling swap class sets on identical markup (one table keyed by variant letter); variants that differ in markup structure swap markup blocks/subcomponents behind the same store. Pick the cheapest technique that expresses the variants - their cleanup steps differ, so do not pay for structure-swapping where classes suffice.
- The auxiliary code (store, variant table, panel) gets NO tests - it is throwaway by design. A project rule of "new code needs tests" does not apply to it; state that explicitly in the run if the project has such a rule.
- All auxiliary code is isolated for mechanical removal: one dedicated dev module, one mount line, minimal touch points in the real component(s).

## Verified recipe: React + Vite + Tailwind

Proven on AmbulaSurvey issue #49 (Ambulance Details spacing, 3 variants, finalized clean).

- One dev module, two files, e.g. under `src/components/dev/`:
  - `<thing>Variants.js` - the variant table (class strings and/or which subcomponent, plus label/descriptor/thesis per variant), a tiny external store, and a provider-less hook via `useSyncExternalStore`; localStorage persistence with table-validated fallback to the default. Must be a plain `.js` file with no component exports: `eslint-plugin-react-refresh` (`react-refresh/only-export-components`, on by default in Vite React templates) errors when a file mixes component and non-component exports.
  - `<Thing>VariantSwitcher.jsx` - the floating panel, sole export. Gate at the top of render: `if (!import.meta.env.DEV) return null;` and `if (typeof navigator !== 'undefined' && navigator.webdriver) return null;`. Fixed corner, high z-index, visibly styled as a dev tool (amber dashed border works well), one button per variant showing letter + short descriptor, active one highlighted.
- Mount `<...VariantSwitcher />` once at the app root with an AUXILIARY comment naming the driving issue/task and pointing at the dev module.
- The consuming component reads the hook and applies the active variant's class strings (styling variants) or renders the active variant's subcomponent (structural variants).
- Tailwind note: the class table holds Tailwind utility strings; in non-Tailwind React projects the identical mechanism works with ordinary CSS class names.

## Other stacks

Add a section for another stack only after a real, tested run of this skill on that stack grounds it - never write a speculative recipe. Unverified mechanics presented as instructions are worse than an honest gap.

## Iteration

On "keep A, add K more":

- Kept variants keep their letters and descriptors.
- Losing variants' table entries (and subcomponents, if structural) are deleted.
- New variants take the freed letters, with fresh theses and descriptors.
- Original (when present) always survives iteration and stays the default.
- Stale persisted letters fall back to the default via the validation invariant - verify this works after the round.

## Finalization

On "go with X":

1. Promote the winner: inline its class strings into the real component(s), or promote its markup into the real component. If X is Original: full revert - the original was never touched, so deleting the experiment is the whole step.
2. Delete the dev module and the root mount including its AUXILIARY comment.
3. Leftover grep MUST return empty: variant letters/identifiers in names, the switcher component name, the storage key, data attributes, and any "variant" naming the experiment introduced.
4. Lint + existing tests + build, plus a browser look at the final state.
5. Commit.

## Commits

One commit per exploration round (variants + switcher), one commit for finalization; squash at merge if the project prefers. Reference the driving issue throughout, but do not claim "Closes" until finalization - the exploration commit is not the resolution.
