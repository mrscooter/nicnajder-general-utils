#!/usr/bin/env bash
# SessionStart hook of the ncn plugin: check that the shared Claude config from this checkout is
# installed (install.sh --check). Silent when it is; otherwise warns the user and tells Claude.
set -uo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
out=$("$HERE/../install.sh" --check 2>&1) && exit 0

msg="Shared Claude config is not fully installed:
$out
Fix: $(dirname "$(dirname "$HERE")")/install.sh claude"
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\n'/\\n}; s=${s//$'\t'/\\t}; printf '"%s"' "$s"; }
printf '{"systemMessage": %s, "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": %s}}\n' \
    "$(json "$msg")" "$(json "$msg
Some of your instructions or skills may be missing. Tell the user before anything else.")"
