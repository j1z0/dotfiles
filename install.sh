#!/usr/bin/env bash
# ~/.dotfiles/install.sh — idempotent. Run it again any time.
set -uo pipefail

DOT="$HOME/.dotfiles"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
say()  { printf '\033[34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  ! \033[0m%s\n' "$*"; }
ok()   { printf '\033[32m  ✓ \033[0m%s\n' "$*"; }

# link <target> <link-path> — back up anything real that's in the way
link() {
  local src="$1" dst="$2"
  [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && { ok "$dst"; return; }
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP$(dirname "${dst#$HOME}")"
    mv "$dst" "$BACKUP${dst#$HOME}" && warn "backed up $dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst" && ok "$dst -> $src"
}

# --- packages ---------------------------------------------------------------
say "homebrew packages"
if command -v brew >/dev/null; then
  brew bundle --file="$DOT/Brewfile" || warn "brew bundle had failures"
else
  warn "no homebrew — install it first: https://brew.sh"
fi

# --- oh-my-zsh --------------------------------------------------------------
say "oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi
ZC="$HOME/.oh-my-zsh/custom"
clone_plugin() {
  local repo="$1" name="${1##*/}"
  [[ -d "$ZC/plugins/$name" ]] || git clone --quiet --depth 1 "https://github.com/$repo" "$ZC/plugins/$name"
  ok "plugin $name"
}
clone_plugin zsh-users/zsh-autosuggestions
clone_plugin zdharma-continuum/fast-syntax-highlighting
clone_plugin Aloxaf/fzf-tab
clone_plugin zsh-users/zsh-completions

# --- symlinks ---------------------------------------------------------------
say "linking configs"
link "$DOT/zsh/zshrc"              "$HOME/.zshrc"
link "$DOT/git/gitconfig"          "$HOME/.gitconfig"
link "$DOT/tmux/tmux.conf"         "$HOME/.tmux.conf"
link "$DOT/ghostty"                "$HOME/.config/ghostty"
link "$DOT/nvim"                   "$HOME/.config/nvim"
link "$DOT/starship/starship.toml" "$HOME/.config/starship.toml"
link "$DOT/aerospace/aerospace.toml" "$HOME/.aerospace.toml"

# Karabiner rewrites karabiner.json in place whenever you change a setting in
# its UI, which would clobber a symlink. Copy, and re-copy on demand.
say "karabiner"
mkdir -p "$HOME/.config/karabiner"
if [[ -f "$HOME/.config/karabiner/karabiner.json" ]] && \
   ! diff -q "$DOT/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json" >/dev/null; then
  mkdir -p "$BACKUP/.config/karabiner"
  cp "$HOME/.config/karabiner/karabiner.json" "$BACKUP/.config/karabiner/karabiner.json"
  warn "backed up existing karabiner.json"
fi
cp "$DOT/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
ok "karabiner.json (copied, not linked — Karabiner rewrites this file)"

# --- tmux plugin manager ----------------------------------------------------
say "tmux plugins"
TPM="$HOME/.tmux/plugins/tpm"
[[ -d "$TPM" ]] || git clone --quiet --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
"$TPM/bin/install_plugins" >/dev/null 2>&1 && ok "tpm plugins installed" || warn "run prefix+I inside tmux to finish"

# --- appearance watcher -----------------------------------------------------
say "appearance watcher"
compile_watcher() {
  swiftc -O -o "$DOT/bin/appearance-watch" "$DOT/src/appearance-watch.swift" 2>/dev/null && return 0
  # The Command Line Tools compiler can be older than the installed SDK, which
  # makes the default SDK unbuildable. Fall back to the newest SDK it accepts.
  local sdk
  for sdk in /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk \
             /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk \
             /Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk; do
    [[ -d "$sdk" ]] || continue
    swiftc -O -sdk "$sdk" -target arm64-apple-macos26.0 \
      -o "$DOT/bin/appearance-watch" "$DOT/src/appearance-watch.swift" 2>/dev/null && return 0
  done
  return 1
}
if compile_watcher; then
  ok "appearance-watch compiled"
  AGENT="$HOME/Library/LaunchAgents/com.jeremy.appearance-watch.plist"
  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$DOT/launchd/com.jeremy.appearance-watch.plist" "$AGENT"
  launchctl bootout "gui/$(id -u)/com.jeremy.appearance-watch" 2>/dev/null
  launchctl bootstrap "gui/$(id -u)" "$AGENT" 2>/dev/null && ok "launch agent loaded" \
    || warn "launchctl bootstrap failed — run: launchctl bootstrap gui/$(id -u) $AGENT"
else
  warn "couldn't compile appearance-watch; \`theme toggle\` still works, but"
  warn "flipping appearance from System Settings won't fan out automatically"
fi

# --- claude code ------------------------------------------------------------
say "claude code"
mkdir -p "$HOME/.claude/themes"
cp "$DOT/claude/themes/"*.json "$HOME/.claude/themes/"
ok "solarized themes installed to ~/.claude/themes"

SETTINGS="$HOME/.claude/settings.json"
if command -v jq >/dev/null; then
  [[ -f "$SETTINGS" ]] || echo '{}' > "$SETTINGS"
  mkdir -p "$BACKUP/.claude"
  cp "$SETTINGS" "$BACKUP/.claude/settings.json" 2>/dev/null
  TMP=$(mktemp)
  # Merge, never overwrite: existing hooks (iTerm2's cc-status, for one) stay.
  jq --arg sl "$DOT/claude/statusline.sh" --arg nf "$DOT/claude/notify.sh" '
    .statusLine = { "type": "command", "command": $sl, "padding": 0 }
    | .hooks //= {}
    | .hooks.Notification //= []
    | .hooks.Stop //= []
    | (.hooks.Notification |= (map(select([.hooks[]?.command] | index($nf) | not))
        + [{ "hooks": [{ "type": "command", "command": $nf }] }]))
    | (.hooks.Stop |= (map(select([.hooks[]?.command] | index($nf) | not))
        + [{ "hooks": [{ "type": "command", "command": $nf }] }]))
  ' "$SETTINGS" > "$TMP" && mv "$TMP" "$SETTINGS" && ok "statusline + notifications wired" \
    || { rm -f "$TMP"; warn "couldn't patch settings.json"; }
else
  warn "no jq — skipping claude settings"
fi

# --- theme ------------------------------------------------------------------
say "theme"
"$DOT/bin/theme" apply && ok "solarized applied ($("$DOT/bin/theme" status | head -1))"

# --- done -------------------------------------------------------------------
echo
say "done"
[[ -d "$BACKUP" ]] && echo "   backups: $BACKUP"
cat <<'NEXT'

   Still needs you (each wants a password or a system prompt):
     brew install --cask karabiner-elements   # then approve the driver in
                                              # System Settings > Privacy & Security
     open -a AeroSpace                        # grant Accessibility permission
     atuin import auto && atuin register      # optional: synced shell history
     chsh -s /bin/zsh                         # already the default on this mac

   Then: exec zsh
NEXT
