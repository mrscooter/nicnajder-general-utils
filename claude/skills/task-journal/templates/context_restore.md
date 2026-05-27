<!-- context_restore.md — TEMPLATE for a session handoff snapshot. Create an INSTANCE only on explicit request (usually session end), named context_restore-<YYYY-MM-DD-HHMM>.md. Do NOT update continuously. Newest timestamp is authoritative; keep or prune older ones at the user's discretion. Goal: let a cold next session reconstruct state fast. -->

# Context Restore — <YYYY-MM-DD HH:MM>

## TL;DR
<2-4 sentences: where things stand right now>

## What was accomplished / shipped so far
<the substantive progress to date — what's done, committed, merged, deployed>

## Blockers / incidents not yet in the logs
<anything in-flight that progress_log / detailed_findings don't yet capture>

## End-of-session runtime state
<what's running/stopped, deployed, dirty working trees, open branches/MRs, etc.>

## Live constraints
<things that must hold / must not be done by the resuming session>

## Open / out-of-scope
<known-open items and things deliberately not addressed>

## Next entry point
<the very next concrete action to take on resume>
