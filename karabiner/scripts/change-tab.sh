#!/bin/sh

# Define the paths to yabai and jq
YABAI="/usr/local/bin/yabai"
JQ="/opt/homebrew/bin/jq"

# Get the currently focused window.
CURRENT_WINDOW_ID=$($YABAI -m query --windows --window | $JQ '.id')

# If CURRENT_WINDOW_ID is empty, set it to null
if [ -z "$CURRENT_WINDOW_ID" ]; then
  CURRENT_WINDOW_ID="null"
fi

# Get all the windows in the space and sort by something that makes sense visually.
FORBIDDEN_APPS="Jumpcloud"
WINDOWS_IN_SPACE=$($YABAI -m query --windows --space | $JQ -re --arg forbidden_app "$FORBIDDEN_APPS" '[ .[] | select(.app != $forbidden_app and .["is-minimized"] == false) ]')

# Get the next window to tab to.
SORTED_WINDOW_IDS_IN_SPACE=$(echo $WINDOWS_IN_SPACE | $JQ -re "sort_by(.frame) | map(.id)")
NEXT_WINDOW=$(echo $SORTED_WINDOW_IDS_IN_SPACE | $JQ -re "nth(1 + index($CURRENT_WINDOW_ID)) // first")

$YABAI -m window --focus "$NEXT_WINDOW"
