# dotfiles

macOS 26 / Apple Silicon. Successor to [j1z0/dotfiles](https://github.com/j1z0/dotfiles),
whose last commit was October 2015.

```sh
git clone <this repo> ~/.dotfiles && ~/.dotfiles/install.sh
```

`install.sh` is idempotent — run it again any time. It backs up anything real
it would overwrite into `~/.dotfiles-backup/<timestamp>/`.

## What carried over from 2015, and what didn't

| Kept | Because |
|---|---|
| `bindkey -v` | vi mode, with a prompt indicator it never had |
| `setopt AUTO_CD` | `code` instead of `cd code` |
| tmux `C-a` prefix, vi pane keys | muscle memory (and the old config bound `k` twice, so "pane right" never worked — fixed) |
| solarized + a light/dark toggle | was `togglebg` on F5 in vim; now flips the whole machine |
| `<leader>` = space, `za` folding, no swapfiles, PEP8 indents | still right |
| `<leader>g` → go to definition | was YouCompleteMe, now the built-in LSP client |

| Dropped | Replaced by |
|---|---|
| Prezto | oh-my-zsh + zsh-autosuggestions, fast-syntax-highlighting, fzf-tab |
| Vundle, YouCompleteMe, syntastic, flake8, Pydiction | lazy.nvim, treesitter, built-in LSP (pyright + ruff) |
| NERDTree, ctrlp | oil.nvim, telescope |
| virtualenvwrapper, rbenv | mise + uv |
| `alias git=/usr/local/bin/hub` | `gh` |
| `/usr/local`, `/usr/X11`, mongodb-2.0.6 in `$PATH` | Intel-era paths; this is an arm64 mac |
| todo.txt + `mit`/`birdseye`/`nav` actions | not ported — say the word and they come back |

## Theming: one palette, every tool

macOS appearance is the single source of truth, the way Omarchy uses one theme
directory. `theme toggle` flips the system, and everything follows:

```
theme            # what mode am I in
theme dark
theme light
theme toggle     # also bound to Caps+T, and cmd+shift+T in Ghostty
theme apply      # re-fan the current mode (idempotent)
```

| Tool | How it follows |
|---|---|
| Ghostty | native — `theme = light:solarized-light,dark:solarized-dark` |
| bat | native — `--theme=auto` reads the terminal background |
| starship, fzf, tmux, eza | configured in **ANSI slots, never hex**, so the terminal palette carries them for free |
| neovim | `auto-dark-mode.nvim`, plus a nudge to already-open instances |
| git / delta | `theme` sets `delta.features` to `solarized-dark` or `solarized-light` |
| **Claude Code** | `~/.claude/themes/solarized-{dark,light}.json` + `"theme": "custom:…"`, which Claude Code hot-reloads — a running session retints without restarting |

One solarized quirk drove several choices: **ANSI slot 8 is base03/base3, which
*is* the background** in each mode. Anything dim must use slot 10 (base01/base1)
or it renders invisible. That's why `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"`.

`appearance-watch` (30 lines of Swift, compiled by `install.sh`) is what makes
flipping appearance in System Settings — or macOS's own sunset schedule — fan out
too. It observes `AppleInterfaceThemeChangedNotification` instead of polling.
It runs as a LaunchAgent, which EDR software may flag as a persistence event;
that's expected. Everything works without it except the automatic trigger.

## Keyboard: AeroSpace + Karabiner

Caps Lock is remapped to `ctrl+alt` (held) / `Escape` (tapped), so every binding
reads as **Caps + key**. Tiling, no SIP disabling.

```
Caps + h j k l          focus window        Caps + 1..9      workspace
Caps + ⇧ + h j k l      move window         Caps + b s m p a  browser/slack/mail/pycharm/agents
Caps + ⏎                new terminal        Caps + ⇧ + 1..5   send window to workspace
Caps + f                fullscreen          Caps + tab        last workspace
Caps + /                tiles h/v           Caps + ⇧ + ;      service mode (esc reloads config)
Caps + ,                accordion           Caps + t          toggle light/dark
```

Slack, Chrome, PyCharm and Claude land on their own workspaces automatically;
System Settings, 1Password and Karabiner float.

## Agentic workflow

The unit of work is **one git worktree per task**, so several Claude Code
sessions edit separate trees of the same repo without fighting over the index.

```sh
wt my-feature          # worktree at ../repo.my-feature, copies .env/.envrc across, cd's in
agent my-feature       # the above + names the tmux window + launches claude
wtrm                   # remove the worktree you're in, and its branch
prj                    # fuzzy-pick a repo under ~/code, attach its tmux session
git recent             # every branch, most recently touched first
```

Claude Code itself gets:

- a **statusline** (`claude/statusline.sh`) — model · dir · branch(dirty) · `⑃ worktree` · session cost.
  The worktree marker matters: it tells you this session is isolated before you
  run something destructive.
- **macOS notifications** (`claude/notify.sh`) on `Stop` and `Notification`, named
  by `dir@branch` — with several agents parked on different workspaces, this is
  how you learn which one is blocked on you.
- `rerere` and `rebase.updateRefs` in git, which pay off when agents rebase stacks.

`install.sh` **merges** into `~/.claude/settings.json` rather than overwriting, so
pre-existing hooks (iTerm2's `cc-status`, for one) survive.

## This machine

`zsh/zshrc` pins `SDKROOT` to `MacOSX26.5.sdk`. The installed Command Line Tools
(26.6) ship `MacOSX27.0.sdk`, which their own clang cannot link against — a bare
`cc hello.c` fails inside `libSystem.tbd`. That breaks every native build
(treesitter parsers, node-gyp, python C extensions), not just this repo. Remove
the pin once CLT ships a compiler matching its default SDK.

## Layout

```
Brewfile                 44 formulae + casks
install.sh               symlinks, plugins, launch agent, claude settings
bin/theme                the light/dark fan-out
bin/appearance-watch     compiled from src/appearance-watch.swift
zsh/{zshrc,aliases,functions}
nvim/                    init.lua + lua/plugins/{theme,editor,lsp}.lua
ghostty/{config,themes/} canonical solarized, both modes
tmux/tmux.conf           C-a, vi keys, resurrect/continuum
aerospace/aerospace.toml
karabiner/karabiner.json copied not linked — Karabiner rewrites it in place
starship/starship.toml   ANSI colors only
claude/                  themes + statusline + notify hook
git/gitconfig            delta, solarized both modes
```

## Not done yet

```sh
brew install --cask karabiner-elements   # wants a password + driver approval
open -a AeroSpace                        # wants Accessibility permission
atuin register                           # optional, for synced history
```
