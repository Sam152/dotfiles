#!/bin/bash

# Define the paths to yabai and jq
YABAI="/usr/local/bin/yabai"
JQ="/opt/homebrew/bin/jq"

# Get the list of visible, non-floating windows on the current space, sorted by app and then by id
WINDOWS=($($YABAI -m query --windows --space | $JQ -r '
  .[]
  | select(.["is-visible"] == true and .["is-floating"] == false)
  | {id: .id, app: .app}
' | $JQ -s 'sort_by(.app, .id) | .[].id'))

# Total number of windows
TOTAL_WINDOWS=${#WINDOWS[@]}

# Initial coordinates and size
GRID_SIZE=30
BASE_X=1
BASE_Y=1
WIDTH=28
HEIGHT=28

# Calculate offset
OFFSET=$((TOTAL_WINDOWS - 1))

# Adjust size for more than one window
if [ "$TOTAL_WINDOWS" -gt 1 ]; then
  WIDTH=$((WIDTH - OFFSET))
  HEIGHT=$((HEIGHT - OFFSET))
fi

# Arrange windows
for I in "${!WINDOWS[@]}"; do
  WIN_ID=${WINDOWS[$I]}
  X=$((BASE_X + I))
  Y=$((BASE_Y + I))
  $YABAI -m window "$WIN_ID" --grid $GRID_SIZE:$GRID_SIZE:$X:$Y:$WIDTH:$HEIGHT
done
