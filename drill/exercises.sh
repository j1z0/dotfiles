# Exercises for `drill`. Each one asks you to actually perform the keystroke.
#
#   ex <name> <section> "<prompt>" "<keys>" [--setup CMD] [--check CMD] [--cleanup CMD]
#
# With --check the drill polls until it's true and advances the moment you get
# it right. Without one, you perform it and confirm — unverifiable, but your
# hands still did the work, which is the point.
#
# Helpers available to setup/check/cleanup: focused_ws, focused_win, focused_app,
# focused_title, win_ws, win_layout, win_fullscreen, appearance, tpanes,
# twindows, tzoomed, tactive_pane, tsplit_axis, goto_ws.

# ---------------------------------------------------------------- windows ----

ex ws_jump windows \
  "Go to workspace 6" "⌥ 6" \
  --setup  'goto_ws 1' \
  --check  '[[ "$(focused_ws)" == "6" ]]'

ex ws_jump2 windows \
  "Go to workspace 3" "⌥ 3" \
  --setup  'goto_ws 8' \
  --check  '[[ "$(focused_ws)" == "3" ]]'

ex ws_back windows \
  "Jump back to the workspace you were on a moment ago" "⌥ tab" \
  --setup  'goto_ws 2; sleep 0.3; goto_ws 5' \
  --check  '[[ "$(focused_ws)" == "2" ]]'

ex ws_send windows \
  "Send THIS window to workspace 7 (it'll take you with it)" "⌥⇧ 7" \
  --check  '[[ "$(win_ws "$DRILL_WIN")" == "7" ]]' \
  --cleanup '$AS move-node-to-workspace --window-id "$DRILL_WIN" "$HOME_WS" >/dev/null 2>&1'

ex app_mail windows \
  "Bring up your mail" "⌥ m" \
  --setup  'goto_ws 1' \
  --check  '[[ "$(focused_title)" == *Mail* ]]'

ex app_calendar windows \
  "Bring up your calendar" "⌥ c" \
  --setup  'goto_ws 1; goto mail >/dev/null 2>&1' \
  --check  '[[ "$(focused_title)" == *Calendar* ]]'

ex mail_tabs windows \
  "From the calendar, switch to the OTHER tab in that window" "⌘⌥ ←  /  ⌘⌥ →" \
  --setup  'goto calendar >/dev/null 2>&1' \
  --check  '[[ "$(focused_title)" == *Mail* ]]'

ex app_slack windows \
  "Bring up Slack" "⌥ s" \
  --setup  'goto_ws 1' \
  --check  '[[ "$(focused_app)" == "com.tinyspeck.slackmacgap" ]]'

ex app_claude windows \
  "Bring up Claude" "⌥ a" \
  --setup  'goto_ws 1' \
  --check  '[[ "$(focused_app)" == "com.anthropic.claudefordesktop" ]]'

ex app_browser windows \
  "Bring up the browser" "⌥ b" \
  --setup  'goto_ws 1' \
  --check  '[[ "$(focused_app)" == "com.google.Chrome" && "$(focused_title)" == *"Google Chrome"* ]]'

ex app_pycharm windows \
  "Bring up PyCharm" "⌥ p" \
  --setup  'goto_ws 1' \
  --check  '[[ "$(focused_app)" == "com.jetbrains.pycharm" ]]'

ex win_full windows \
  "Make this window fullscreen" "⌥ f" \
  --check  '[[ "$(win_fullscreen "$DRILL_WIN")" == "true" ]]' \
  --cleanup '$AS fullscreen off --window-id "$DRILL_WIN" >/dev/null 2>&1'

ex win_float windows \
  "Float this window, so you could drag and resize it with the mouse" "⌥⇧ f" \
  --check  '[[ "$(win_layout "$DRILL_WIN")" == "floating" ]]' \
  --cleanup '$AS layout tiling --window-id "$DRILL_WIN" >/dev/null 2>&1'

ex win_focus windows \
  "Move focus to a DIFFERENT window on this workspace" "⌥ h  or  ⌥ l" \
  --setup  'ensure_two_windows' \
  --check  '[[ -n "$(focused_win)" && "$(focused_win)" != "$DRILL_WIN" ]]'

ex theme_flip windows \
  "Flip the whole machine to the other appearance" "⌥ t" \
  --setup  'START_MODE=$(appearance)' \
  --check  '[[ "$(appearance)" != "$START_MODE" ]]' \
  --cleanup 'theme "${START_MODE,,}" >/dev/null 2>&1'

# ------------------------------------------------------------------- tmux ----

ex tmux_split_right tmux \
  "Split this terminal to the RIGHT" "C-a |" \
  --setup  'tclean' \
  --check  '[[ "$(tpanes)" -ge 2 && "$(tsplit_axis)" == "h" ]]' \
  --cleanup 'tclean'

ex tmux_split_down tmux \
  "Split this terminal DOWNWARD" "C-a -" \
  --setup  'tclean' \
  --check  '[[ "$(tpanes)" -ge 2 && "$(tsplit_axis)" == "v" ]]' \
  --cleanup 'tclean'

ex tmux_zoom tmux \
  "Zoom this pane to fill the window" "C-a z" \
  --setup  'tclean; tmux split-window -h -t "$DRILL_SESSION" -d 2>/dev/null' \
  --check  '[[ "$(tzoomed)" == "1" ]]' \
  --cleanup 'tmux resize-pane -Z -t "$DRILL_SESSION" 2>/dev/null; tclean'

ex tmux_pane_move tmux \
  "Move to the OTHER pane" "C-a h  or  C-a l" \
  --setup  'tclean; tmux split-window -h -t "$DRILL_SESSION" -d 2>/dev/null; START_PANE=$(tactive_pane)' \
  --check  '[[ "$(tactive_pane)" != "$START_PANE" ]]' \
  --cleanup 'tmux select-pane -t "$DRILL_SESSION.$START_PANE" 2>/dev/null; tclean'

ex tmux_new_window tmux \
  "Open a new tmux window" "C-a c" \
  --setup  'twclean' \
  --check  '[[ "$(twindows)" -ge 2 ]]' \
  --cleanup 'twclean'

ex tmux_agent_layout tmux \
  "Lay out this window for an agent: 65% left, 35% right" "C-a A" \
  --setup  'tclean' \
  --check  '[[ "$(tpanes)" -ge 2 && "$(tsplit_axis)" == "h" ]]' \
  --cleanup 'tclean'

# ------------------------------------------- perform-and-confirm (no check) --
# Ghostty, nvim and readline expose no state to poll. You still do them.

ex ghostty_split ghostty \
  "Split the Ghostty WINDOW itself to the right (not tmux)" "⌘ d"

ex ghostty_quick ghostty \
  "Summon the drop-down quick terminal, then dismiss it again" "⌘ \`"

ex shell_history shell \
  "Search your whole shell history for the word 'git', then press Escape" "C-r"

ex shell_suggest shell \
  "Type 'git st', accept the grey suggestion, then clear the line with C-u" "C-space"

ex shell_fzf_file shell \
  "Fuzzy-find a file into the command line, then Escape out" "C-t"

ex nvim_def nvim \
  "In nvim, jump to the definition of something, then C-o back" "gd  (or space g)"
