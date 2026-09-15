#!/usr/bin/env bash
# Claude Code -> macOS Notification Center, and clicking it takes you back.
#
# The reason this matters for parallel agent work: with several sessions parked
# on different AeroSpace workspaces, you can't see which one is blocked on you.
# This tells you, names the directory, and puts you in that exact terminal.
#
# Posted through terminal-notifier rather than osascript. An osascript
# notification is owned by Script Editor, so clicking it opens Script Editor —
# there is no way to change that, the click target is whichever app posted it.
# terminal-notifier's -execute runs a command on click instead.

input=$(cat)
event="${CLAUDE_HOOK_EVENT:-}"
msg=$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[[ -z "$cwd" ]] && cwd="$PWD"
where=$(basename "$cwd")
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[[ -n "$branch" ]] && where="$where@$branch"

case "$event" in
  Stop)         title="Claude finished";  body="$where" ;;
  Notification) title="Claude needs you"; body="${msg:-$where}" ;;
  *)            title="Claude";           body="${msg:-$where}" ;;
esac

# Work out which terminal this session is in, so the click can return to it.
# The uuid half of ITERM_SESSION_ID is iTerm2's own session id.
sid="${ITERM_SESSION_ID#*:}"
pane="${TMUX_PANE:-}"

# A hook has no controlling terminal of its own, so walk up to the Claude Code
# process, which does. Used when ITERM_SESSION_ID isn't in the environment.
tty_path=""
pid=$$
for _ in 1 2 3 4 5 6; do
  t=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
  if [[ -n "$t" && "$t" != "??" ]]; then tty_path="/dev/$t"; break; fi
  pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  [[ -z "$pid" || "$pid" == "1" ]] && break
done

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "$title" \
    -message "$body" \
    -sound Tink \
    -group "claude-$where" \
    -execute "$HOME/.dotfiles/bin/focus-claude '$sid' '$tty_path' '$pane'" \
    >/dev/null 2>&1
else
  # Fallback: still notifies, but clicking it opens Script Editor.
  osascript -e "display notification \"${body//\"/\\\"}\" with title \"${title//\"/\\\"}\" sound name \"Tink\"" >/dev/null 2>&1
fi
exit 0
