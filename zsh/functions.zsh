# ~/.dotfiles/zsh/functions.zsh

# `theme` needs to be a function, not just the script: the script can't change
# the environment of the shell you typed it in, so re-source what it wrote.
theme() {
  command theme "$@" || return $?
  [[ -r "$HOME/.local/state/dotfiles/env.zsh" ]] && source "$HOME/.local/state/dotfiles/env.zsh"
}

# --- git worktrees ----------------------------------------------------------
# The unit of agentic work: one worktree per task, so N agents edit N trees of
# the same repo without fighting over the index or each other's uncommitted work.

# wt <branch> [base]  — new worktree at ../<repo>.<branch>, cd into it
wt() {
  local branch="${1:?usage: wt <branch> [base-ref]}"
  local base="${2:-HEAD}"
  local root name dir
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repo" >&2; return 1; }
  name=$(basename "$root")
  dir="$(dirname "$root")/${name}.${branch//\//-}"

  if [[ -d "$dir" ]]; then
    echo "worktree exists, switching: $dir"
  elif git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch" || return 1
  else
    git worktree add -b "$branch" "$dir" "$base" || return 1
  fi

  # Carry over the things git deliberately doesn't: env files, local settings.
  for f in .env .env.local .envrc .claude/settings.local.json; do
    [[ -f "$root/$f" && ! -e "$dir/$f" ]] && mkdir -p "$(dirname "$dir/$f")" && cp "$root/$f" "$dir/$f"
  done
  cd "$dir"
}

# wtrm [branch]  — remove the worktree you're in (or a named one) and its branch
wtrm() {
  local root dir branch
  if [[ -n "${1:-}" ]]; then
    dir=$(git worktree list --porcelain | awk -v b="refs/heads/$1" '/^worktree /{w=$2} /^branch /{if ($2==b) print w}')
    [[ -z "$dir" ]] && { echo "no worktree for branch $1" >&2; return 1; }
    branch="$1"
  else
    dir=$(git rev-parse --show-toplevel) || return 1
    branch=$(git branch --show-current)
    root=$(git worktree list --porcelain | head -1 | awk '{print $2}')
    [[ "$dir" == "$root" ]] && { echo "refusing to remove the main worktree" >&2; return 1; }
    cd "$root"
  fi
  git worktree remove "$dir" --force && git branch -D "$branch" 2>/dev/null
  echo "removed $dir"
}

# agent <branch>  — worktree + tmux window + claude, in one keystroke
agent() {
  local branch="${1:?usage: agent <branch> [prompt...]}"; shift
  wt "$branch" || return 1
  if [[ -n "$TMUX" ]]; then
    tmux rename-window "$branch"
  fi
  if (( $# )); then
    claude "$*"
  else
    claude
  fi
}

# --- fzf helpers ------------------------------------------------------------
# f — fuzzy-find a file and open it
f() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always --line-range :300 {}') || return
  ${EDITOR:-nvim} "$file"
}

# fcd — fuzzy-find a directory and cd
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf --preview 'eza --tree --level=2 --color=always {}') || return
  cd "$dir"
}

# rgf — ripgrep, then open the hit at the right line
rgf() {
  local hit file line
  hit=$(rg --line-number --no-heading --color=always --smart-case "${*:-}" \
    | fzf --ansi --delimiter : \
          --preview 'bat --color=always --highlight-line {2} --line-range $(( {2} > 10 ? {2} - 10 : 1 )): {1}') || return
  file=${hit%%:*}; line=$(echo "$hit" | cut -d: -f2)
  ${EDITOR:-nvim} "+$line" "$file"
}

# prj — fuzzy-pick a repo under ~/code and attach a tmux session for it
prj() {
  local dir name
  dir=$(fd --type d --max-depth 3 --hidden '^\.git$' ~/code | xargs -n1 dirname | sort -u \
    | fzf --preview 'eza -lh --color=always --git {}') || return
  name=$(basename "$dir" | tr . _)
  if tmux has-session -t "$name" 2>/dev/null; then
    [[ -n "$TMUX" ]] && tmux switch-client -t "$name" || tmux attach -t "$name"
  else
    tmux new-session -d -s "$name" -c "$dir"
    [[ -n "$TMUX" ]] && tmux switch-client -t "$name" || tmux attach -t "$name"
  fi
}

# --- misc -------------------------------------------------------------------
# mkcd — make a directory and enter it
mkcd() { mkdir -p "$1" && cd "$1"; }

# extract — one command for every archive format
extract() {
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf  "$1" ;;
    *.zip)            unzip   "$1" ;;
    *.gz)             gunzip  "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.7z)             7z x    "$1" ;;
    *) echo "don't know how to extract $1" >&2; return 1 ;;
  esac
}

# shot — paste the clipboard image to a file, print the path for feeding an agent
shot() {
  local out="${1:-/tmp/shot-$(date +%s).png}"
  pngpaste "$out" 2>/dev/null && echo "$out" || { echo "no image on the clipboard" >&2; return 1; }
}

# ports-kill — free a port that something is squatting on
unstick() {
  local port="${1:?usage: unstick <port>}"
  lsof -ti:"$port" | xargs -r kill -9 && echo "freed :$port"
}
