#!/usr/bin/env bash
# Claude Code statusline. Omarchy puts agent state in the system bar; on macOS
# the equivalent is to put it where you're already looking — the session itself.
#
# Shows: model · directory · git branch (dirty) · worktree marker · session cost.
# Colours are ANSI slots, never hex, so it reads correctly in solarized light
# and dark. Slot 8 is avoided: in solarized that slot IS the background.

input=$(cat)
q() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

model=$(q '.model.display_name')
cwd=$(q '.workspace.current_dir')
project=$(q '.workspace.project_dir')
cost=$(q '.cost.total_cost_usd')
[[ -z "$cwd" ]] && cwd="$PWD"

C_RESET=$'\033[0m'
C_MODEL=$'\033[35m'      # magenta
C_DIR=$'\033[34m'        # blue
C_BRANCH=$'\033[32m'     # green
C_DIRTY=$'\033[33m'      # yellow
C_TREE=$'\033[36m'       # cyan
C_MUTED=$'\033[92m'      # bright green = base01/base1 in solarized
C_COST=$'\033[92m'

out="${C_MODEL}${model}${C_RESET}"
out+=" ${C_MUTED}·${C_RESET} ${C_DIR}$(basename "$cwd")${C_RESET}"

if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  [[ -z "$branch" ]] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  dirty=""
  git -C "$cwd" diff --quiet 2>/dev/null || dirty="*"
  git -C "$cwd" diff --cached --quiet 2>/dev/null || dirty="${dirty}+"
  out+=" ${C_MUTED}·${C_RESET} ${C_BRANCH}${branch}${C_DIRTY}${dirty}${C_RESET}"

  # A worktree that isn't the main one means this session is an isolated agent:
  # worth flagging, because it changes what "git push" and "rm -rf" mean here.
  common=$(git -C "$cwd" rev-parse --git-common-dir 2>/dev/null)
  gitdir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null)
  if [[ -n "$common" && "$common" != "$gitdir" ]]; then
    out+=" ${C_TREE}⑃ worktree${C_RESET}"
  fi

  ahead=$(git -C "$cwd" rev-list --count '@{u}..HEAD' 2>/dev/null)
  [[ -n "$ahead" && "$ahead" != "0" ]] && out+=" ${C_MUTED}↑${ahead}${C_RESET}"
fi

if [[ -n "$cost" && "$cost" != "null" ]]; then
  out+=" ${C_MUTED}·${C_RESET} ${C_COST}$(printf '$%.2f' "$cost")${C_RESET}"
fi

printf '%s' "$out"
