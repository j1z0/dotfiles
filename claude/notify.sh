#!/usr/bin/env bash
# Claude Code -> macOS Notification Center.
#
# The reason this matters for parallel agent work: with several sessions parked
# on different AeroSpace workspaces, you can't see which one is blocked on you.
# This tells you, and names the directory so you know where to look.

input=$(cat)
event="${CLAUDE_HOOK_EVENT:-}"
msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[[ -z "$cwd" ]] && cwd="$PWD"
where=$(basename "$cwd")
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[[ -n "$branch" ]] && where="$where@$branch"

case "$event" in
  Stop)         title="Claude finished"; body="$where" ;;
  Notification) title="Claude needs you"; body="${msg:-$where}" ;;
  *)            title="Claude"; body="${msg:-$where}" ;;
esac

osascript -e "display notification \"${body//\"/\\\"}\" with title \"${title//\"/\\\"}\" sound name \"Tink\"" >/dev/null 2>&1
exit 0
