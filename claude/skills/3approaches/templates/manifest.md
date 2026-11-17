# Variants manifest: <the decision>

<!-- purpose: written by /ncn:3approaches in handoff mode. Everything a session that has never seen the run needs to judge the variants and to finalize. Fill every <...>, delete nothing. -->

- Experiment id: `<id>`. Driving issue/task: <issue or one line>.
- State: all variants built, NOT final. Branch `<branch>`, variants commit `<sha>`, started from `<base sha>`.
- Dev folder: `<path>` (all auxiliary code). Touch points outside it carry an `AUXILIARY(<id>)` comment: `<file>`, `<file>`.
- Switcher: <floating panel, where | inline, next to which element>.
- Persisted choice: `<key and where it is stored>`. Default: `<letter>`.
- Other experiments live in this repository: <ids, and whether this one's subject is rendered inside their variants | none>.

## Variants

| Letter | Descriptor | Thesis | Look at | Weakness (author's view) |
|---|---|---|---|---|
| `<letter>` | <descriptor> | <thesis> | <where and at which window size the difference shows> | <what its author thinks is weak about it> |

<For structural variants: one line per variant on what it changes that a test or a selector can notice, e.g. "A: the page title is the tagline, the product name is no longer a heading".>

## Decided without asking

- <what the interactive protocol would have asked, what was decided, why. "Nothing" if nothing.>

## Run and switch

- Start: `<command>`, open <where>.
- Switch: <where the switcher is and how to use it>.
- Automation: the switcher is absent under automation. Select a variant by setting the persisted choice before the app starts: `<snippet for the project's automation tool>`.

## Checked

- <which variants were looked at, at which window sizes; lint, tests, build results with their numbers, including the warnings that were there before>.
- Not checked: <combinations with other live experiments, anything else>.

## Finalize

In a session in this repository, with the pick filled in:

> /ncn:3approaches finalize from manifest <path of this file>: <letter>

A mix is given in free text ("layout of B with the color of A").

What finalization will have to touch:

- Leftover grep, must print nothing: `<the diff since <base sha>, added lines only, filtered for every name this experiment introduced>`
- Tests that assert the changed surface: `<file>`, `<file>` (found by searching the whole test tree).
- Texts: <where the winning texts go, the shipped languages, how to see each language in the running app>.
- <anything else the project's rules require of the final code>.
