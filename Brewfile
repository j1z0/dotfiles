# ~/.dotfiles/Brewfile — jeremy's mac, 2026
# Run: brew bundle --file=~/.dotfiles/Brewfile

tap "nikitabobko/tap"      # aerospace

# --- shell + prompt ---------------------------------------------------------
brew "starship"            # prompt, ANSI-colored so it follows solarized automatically
brew "zsh-completions"

# --- the daily drivers ------------------------------------------------------
brew "fzf"                 # fuzzy everything (ctrl-r, ctrl-t, fzf-tab)
brew "ripgrep"             # rg — also what Claude Code uses under the hood
brew "fd"                  # find
brew "bat"                 # cat, with light/dark theme awareness
brew "eza"                 # ls
brew "zoxide"              # z — frecency cd
brew "atuin"               # shell history: synced, searchable, per-directory
brew "git-delta"           # git diffs worth reading
brew "difftastic"          # syntax-aware diff for when delta isn't enough
brew "jq"
brew "yq"
brew "sd"                  # sed, but the regex works how you expect
brew "tealdeer"            # tldr
brew "tree"
brew "wget"
brew "coreutils"

# --- git / repo work --------------------------------------------------------
brew "gh"
brew "lazygit"             # TUI git — the one that replaces 90% of git CLI
brew "git-absorb"          # auto-fixup staged changes into the right commit
brew "gitui"

# --- TUIs + system ----------------------------------------------------------
brew "tmux"
brew "neovim"
brew "yazi"                # file manager TUI
brew "btop"                # top
brew "dust"                # du
brew "procs"               # ps
brew "hyperfine"           # benchmark CLI commands
brew "fastfetch"
brew "gum"                 # pretty shell prompts/menus — Omarchy leans on this

# --- dev env ----------------------------------------------------------------
brew "mise"                # replaces rbenv/pyenv/nvm/virtualenvwrapper (all of it)
brew "direnv"              # per-project env, works with mise
brew "uv"                  # python packaging, fast
brew "just"                # project task runner
brew "watchexec"           # run a command when files change
brew "xh"                  # httpie, in rust
brew "imagemagick"
brew "pngpaste"            # paste clipboard images to a file — handy for feeding Claude screenshots



# --- apps -------------------------------------------------------------------
cask "ghostty"
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"
cask "nikitabobko/tap/aerospace"    # tiling WM, no SIP disabling
