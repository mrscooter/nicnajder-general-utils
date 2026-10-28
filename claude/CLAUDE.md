# Global Instructions

- General rules: @~/.claude/GLOBAL-GENERAL-CLAUDE.md
- This machine's rules, win over general rules on conflict: @~/.claude/LOCAL-CLAUDE.md

Both imports are mandatory and fail silently. If either is absent (LOCAL-CLAUDE.md always has at least its `# Machine-specific rules` heading), or a skill under `~/.claude/skills/` won't load, **STOP and loudly tell the user.**
