#!/bin/bash
# credit to Will Richardson
# https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/
# https://github.com/willhbr/dotfiles/blob/d2d129628cfba248f44e5705f4e0e153193130ca/bin/show-tmux-popup.sh

session="_popup_$(tmux display -p '#S')"

if ! tmux has -t "$session" 2> /dev/null; then
  parent_session="$(tmux display -p '#{session_id}')"
  session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' -e TMUX_PARENT_SESSION="$parent_session")"
  tmux set-option -s -t "$session_id" key-table popup
  tmux set-option -s -t "$session_id" status off
  tmux set-option -s -t "$session_id" prefix None
  session="$session_id"
fi

exec tmux attach -t "$session" > /dev/null
