# Cheatsheet

`keys` shows this. `keys <word>` greps it — e.g. `keys workspace`, `keys worktree`.

## Windows — AeroSpace (modifier is ⌥ Option)

Tiling means windows never overlap and never get dragged. The screen is split,
and you change the split. Two keys matter more than the rest: **⌥⇧F** floats one
window when tiling is wrong for it, and **⌥⇧E** turns tiling off entirely.

```
⌥ h j k l          focus the window left / down / up / right
⌥⇧ h j k l         move the focused window in that direction
⌥ -   ⌥ =          shrink / grow the focused window
⌥⇧ 0               reset all sizes to equal
⌥ /                toggle split direction (horizontal <-> vertical)
⌥ ,                accordion layout (stack, one visible)
⌥ f                fullscreen the focused window
⌥⇧ f               float this window  ->  now you can drag and resize it
⌥⇧ e               TILING OFF / ON  ->  macOS window behaviour comes back
⌥⇧ w               close window
⌥⇧ q               close every window except this one
⌥ ⏎                new Ghostty window
⌥ t                flip the machine light <-> dark
```

Workspaces are separate screens you switch between, not overlapping windows.

```
⌥ 1..9             go to workspace 1-9
⌥⇧ 1..5            send this window to workspace 1-5
⌥ tab              back to the previous workspace
⌥⇧ tab             move this workspace to the other monitor
⌥ b                Browser      (Chrome and Safari land here by themselves)
⌥ s                Slack
⌥ m                Mail
⌥ p                PyCharm
⌥ a                Agents       (Claude lands here)
⌥⇧ b s a p         send this window to that workspace
```

Service mode, for the things you do rarely: **⌥⇧ ;** then

```
esc                reload the config
r                  flatten the layout (fix a tree that got weird)
f                  toggle floating
backspace          close all but current
⌥ h j k l          join this window with its neighbour in that direction
```

System Settings, 1Password and Karabiner float automatically — they're the wrong
shape for tiling.

## Terminal — Ghostty

```
⌘ d       split right              ⌘ j / ⌘ k    next / previous split
⌘⇧ d      split down               ⌘⇧ ⏎         zoom this split
⌘⇧ t      flip light <-> dark      ⌘ `          drop-down quick terminal (global)
```

Ghostty has no session persistence — if it crashes, its splits are gone. Anything
that must survive belongs in tmux.

## tmux — prefix is C-a

```
C-a |      split right                C-a h j k l   move between panes
C-a -      split down                 C-a H J K L   resize (hold to repeat)
C-a c      new window                 C-a z         zoom this pane
C-a A      agent layout: 65% / 35% split, cursor left
C-a g      lazygit in a popup         C-a e         shell in a popup
C-a C-j    fuzzy session switcher     C-a S         session tree
C-a ⏎      promote pane to window     C-a r         reload config
C-a [      copy mode (then v to select, y to copy)
```

Sessions and pane contents are saved every 5 minutes and restored after a
reboot — that's `tmux-resurrect` + `tmux-continuum`.

## Shell

```
TAB              fuzzy completion with a preview pane
C-space          accept the greyed-out suggestion
C-r              search all shell history (atuin)
C-t              fuzzy-find a file into the current command
⌥ c              fuzzy-find a directory and cd there
C-p / C-n        history entries starting with what you typed
ESC              vi normal mode; v there opens the line in nvim
..  ...  ....    up one, two, three directories
<dirname>        just the name cd's there (AUTO_CD)
j <part-of-path> jump to a directory you've used before (zoxide)
```

```
f                fuzzy-find a file, open it in nvim
fcd              fuzzy-find a directory, cd there
rgf <pattern>    grep the repo, open the hit at the right line
prj              pick a repo under ~/code, attach its tmux session
mkcd <dir>       mkdir + cd
extract <file>   any archive format
shot             clipboard image -> file, prints the path (to feed an agent)
unstick <port>   kill whatever is holding a port
```

## Agentic work

One worktree per task. Separate directories, same repo, so parallel Claude
sessions never fight over the index or each other's uncommitted files.

```
wt my-feature        worktree at ../repo.my-feature, copies .env/.envrc, cd's in
agent my-feature     the above + names the tmux window + launches claude
agent fix-x "prompt" same, with an opening prompt
wtrm                 remove the worktree you're standing in, and its branch
wtrm other-branch    remove a named one
git trees            list worktrees
git recent           every branch, most recently touched first
```

Claude Code's statusline reads `model · dir · branch(dirty) · ⑃ worktree · $cost`.
The **⑃ worktree** marker means this session is isolated — check for it before
running anything destructive. Notifications fire on finish and on "needs you",
labelled `dir@branch`, so with agents on several workspaces you know which one
is waiting.

```
cc       claude                 ccr    claude --resume
ccc      claude --continue      ccp    claude -p   (one-shot, prints, exits)
ccy      claude --dangerously-skip-permissions   (worktrees only)
```

## Theme

```
theme            which mode am I in
theme toggle     flip everything   (also ⌥t, and ⌘⇧T in Ghostty)
theme dark
theme light
```

Flips macOS appearance, and Ghostty, bat, delta, tmux, neovim and Claude Code's
TUI all follow — Claude retints without restarting.

## Git

```
lg               lazygit (the one that replaces most git CLI)
gs gd gl         status / diff / log --graph
gap              add -p, hunk by hunk
gab              absorb staged fixes into the commits they belong to
gcan             amend, keep the message
gpf              push --force-with-lease
prs prc prv      gh pr list / create --fill / view --web
dft              difftastic — syntax-aware diff
```

## Neovim

```
space             leader              -        file browser (oil)
space ff / fg     find file / grep    space fb buffers
space g  or  gd   go to definition    gr       references
K                 hover docs          space rn rename
space ca          code actions        space e  show diagnostic
space fm          format              ]c / [c  next / previous git hunk
space bg          light <-> dark      space    toggle fold
```

## Maintenance

```
brewup           update and upgrade everything, then clean up
dotup            pull the dotfiles and re-run brew bundle
reload           exec zsh
~/.dotfiles/install.sh   re-run any time; backs up what it would overwrite
```
