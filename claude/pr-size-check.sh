#!/usr/bin/env bash
# PreToolUse hook: deny `gh pr create` when the branch diff is too big to review quickly.
# Override after Jeremy agrees: prefix the command with PR_SIZE_OK=1. Limit: PR_SIZE_LIMIT (default 300).
set -uo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
dir=$(jq -r '.cwd // empty' <<<"$input")

[[ "$cmd" == *"gh pr create"* ]] || exit 0
[[ "$cmd" == *"PR_SIZE_OK=1"* ]] && exit 0

# Honour a leading `cd <dir> &&` so the diff is measured in the repo the PR is opened from.
if [[ "$cmd" =~ ^[[:space:]]*cd[[:space:]]+([^&;[:space:]]+)[[:space:]]*\&\& ]]; then
  target="${BASH_REMATCH[1]/#\~/$HOME}"
  [[ "$target" = /* ]] || target="$dir/$target"
  dir="$target"
fi
cd "$dir" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1 || exit 0

base=$(grep -oE -- '(--base|-B)[= ]+[^ ]+' <<<"$cmd" | head -1 | sed -E 's/^(--base|-B)[= ]+//; s/["'\'']//g')
[[ -n "$base" ]] || base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
[[ -n "$base" ]] || base=main
# Promotions re-ship changes that were already reviewed on main.
case "$base" in qa|prod|stage|staging) exit 0 ;; esac

head_ref=HEAD
h=$(grep -oE -- '(--head|-H)[= ]+[^ ]+' <<<"$cmd" | head -1 | sed -E 's/^(--head|-H)[= ]+//; s/["'\'']//g')
if [[ -n "$h" ]]; then
  git rev-parse --verify -q "$h" >/dev/null && head_ref="$h"
  git rev-parse --verify -q "origin/$h" >/dev/null && head_ref="origin/$h"
fi

git rev-parse --verify -q "origin/$base" >/dev/null || exit 0
mb=$(git merge-base "origin/$base" "$head_ref" 2>/dev/null) || exit 0

lockfiles='(^|/)(uv\.lock|poetry\.lock|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock|go\.sum)$|\.snap$'
tests='(^|/)tests?/|(^|/)test_[^/]*$|_test\.(py|go)$|\.(test|spec)\.[jt]sx?$|(^|/)__tests__/'
read -r code test files < <(git diff --numstat "$mb" "$head_ref" | awk -v lf="$lockfiles" -v ts="$tests" '
  $1 == "-" || $3 ~ lf { next }
  { n = $1 + $2; f++; if ($3 ~ ts) t += n; else c += n }
  END { printf "%d %d %d\n", c, t, f }')

limit=${PR_SIZE_LIMIT:-300}
(( code > limit )) || exit 0

top=$(git diff --numstat "$mb" "$head_ref" | awk -v lf="$lockfiles" -v ts="$tests" '
  $1 == "-" || $3 ~ lf || $3 ~ ts { next } { print $1 + $2, $3 }' | sort -rn | head -8 | awk '{printf "  %5d  %s\n", $1, $2}')

reason="PR too big to review fast: ${code} changed lines of non-test code (+${test} test lines, ${files} files) against origin/${base}; limit is ${limit}.
Small PRs here merge in 0-2h; big ones sit for days in the code-owner queue.
Largest files:
${top}
Propose a split into independently mergeable PRs (each under ${limit} lines, in merge order) and show Jeremy the plan.
Only if Jeremy says it cannot be split, re-run the same command prefixed with PR_SIZE_OK=1."

jq -n --arg r "$reason" --arg m "PR size check: ${code} lines vs limit ${limit} — asking for a split." '{
  systemMessage: $m,
  hookSpecificOutput: { hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r }
}'
