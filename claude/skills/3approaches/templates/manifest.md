# Variants manifest: <task>

<!-- purpose: written by /ncn:3approaches in handoff mode. Everything a session that has never seen the run needs to judge the variants and to finalize. Fill every <...>, delete nothing. -->

- State: all variants built, NOT final. Branch `<branch>`, variants commit `<sha>`, started from `<base sha>`.
- Dev folder: `<path>` (all auxiliary code). Touch points outside it carry an `AUXILIARY` comment: `<file>`, `<file>`.
- Driving issue/task: <issue or one line>.

## Axes

### <axis name> (`<axisId>`)

- Weight: <heavy | light>. Placement: <global: floating panel | local: inline switcher at <element>>.
- Storage key: `<key>`. Default: `<letter>`.

| Letter | Descriptor | Thesis | Look at | Weakness (author's view) |
|---|---|---|---|---|
| `<letter>` | <descriptor> | <thesis> | <where and at which width the difference shows> | <what its author thinks is weak about it> |

<For a heavy axis: one line per variant on what it changes that a test or a selector can notice, e.g. "A: the h1 is the tagline, the product name is no longer a heading".>

## Decided without asking

- <what the interactive protocol would have asked, what was decided, why. "Nothing" if nothing.>

## Run and switch

- Start: `<command>`, open `<url>`.
- Switch: <where the floating panel is; where each inline switcher is>.
- Automation: the switchers are hidden under browser automation. Select a variant by setting its storage key before the page loads, e.g. `<snippet for the project's e2e tool>`.

## Checked

- <which combinations were looked at, at which widths; lint, tests, build results with their numbers, including the warnings that were there before>.
- Not checked: <the rest of the cross product, anything else>.

## Finalize

In a session in this repository, with one letter per axis filled in:

> /ncn:3approaches finalize from manifest <path of this file>: <axis name> <letter>, <axis name> <letter>, ...

A mix inside one axis is given in free text ("<axis name>: layout of B with the color of A").

What finalization will have to touch:

- Leftover grep, must print nothing: `git diff <base sha> | grep '^+' | grep -inE '<every name the experiment introduced, joined by |>'`
- Tests that assert the changed surface: `<file>`, `<file>` (found by grepping the whole test tree).
- Texts: <where the winning texts go, the shipped languages, how to see each language in the running app>.
- <anything else the project's rules require of the final code>.
