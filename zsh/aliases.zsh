# ~/.dotfiles/zsh/aliases.zsh

# --- modern replacements ----------------------------------------------------
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first --git'
alias la='eza -lha --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons --group-directories-first'
alias ltt='eza --tree --level=4 --icons --group-directories-first'
alias cat='bat'
alias catp='bat -p'          # plain, no decorations — for piping
alias rcat='command cat'
alias top='btop'
alias du='dust'
alias ps='procs'
alias find='fd'
alias grep='rg'
alias help='tldr'
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# --- navigation -------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='cd ~/code'
alias dot='cd ~/.dotfiles'
alias zrc='nvim ~/.dotfiles/zsh/zshrc'
alias reload='exec zsh'

# --- git --------------------------------------------------------------------
alias g='git'
alias lg='lazygit'
alias gs='git status -sb'
alias gd='git diff'
alias gdc='git diff --cached'
alias gds='git diff --stat'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --oneline --graph --decorate --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias ga='git add'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gst='git stash'
alias gstp='git stash pop'
alias gab='git absorb --and-rebase'      # stage fixes, absorb into the right commits
alias gwl='git worktree list'
alias dft='difft'                        # syntax-aware diff

# --- github -----------------------------------------------------------------
alias prs='gh pr list'
alias prc='gh pr create --fill'
alias prv='gh pr view --web'
alias prco='gh pr checkout'
alias runs='gh run list -L 10'
alias watchrun='gh run watch'

# --- claude code / agentic ---------------------------------------------------
alias cc='claude'
alias ccr='claude --resume'
alias ccc='claude --continue'
alias ccp='claude -p'                    # one-shot, prints and exits
alias ccy='claude --dangerously-skip-permissions'   # only in a worktree/container
alias ccost='claude usage'
alias ccl='cd ~/.claude && ls'
alias ccmd='nvim ~/.claude/CLAUDE.md'

# --- tmux -------------------------------------------------------------------
alias t='tmux'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# --- misc -------------------------------------------------------------------
alias ip='ipconfig getifaddr en0'
alias myip='curl -s ifconfig.me; echo'
alias ports='lsof -iTCP -sTCP:LISTEN -P -n'
alias path='echo -e ${PATH//:/\\n}'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias serve='python3 -m http.server'
alias week='date +%V'
alias brewup='brew update && brew upgrade && brew cleanup'
alias dotup='cd ~/.dotfiles && git pull && brew bundle --file=Brewfile && cd -'
