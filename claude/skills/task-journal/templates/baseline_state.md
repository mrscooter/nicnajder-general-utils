<!-- baseline_state.md — Captured ORIGINAL/pristine state before mutating a live system, so it can be restored exactly. Set once, at the start of live-system work. Live-system / stateful-mutation tasks only — skip otherwise. -->

# Baseline State

**Snapshot taken:** <YYYY-MM-DD HH:MM> — <how it was captured>
**Under test:** <the system / deployment being changed>
**Purpose:** reference for reverting state after the work.

## State summary
<high-level overview of the captured state — a listing/summary that's quick to scan>

## How to revert
1. <steps / commands to restore the per-item baseline below>

## Per-item captures

### <item name>

    <exact original values / config / dump — enough to restore precisely>
