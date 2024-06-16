#!/bin/bash

ANCHOR=$1

# Define the paths to yabai and jq
YABAI="/usr/local/bin/yabai"
JQ="/opt/homebrew/bin/jq"

# Get the current window and display information once
WINDOW_INFO=$($YABAI -m query --windows --window)
DISPLAY_INFO=$($YABAI -m query --displays --display)

# Extract some variables from the JSON objects.
eval $(
  echo "$WINDOW_INFO" | $JQ -r '
    {
      WINDOW_ID: .id,
      WINDOW_X: .frame.x,
      WINDOW_Y: .frame.y,
      WINDOW_WIDTH: .frame.w
    } | to_entries | .[] | "\(.key)=\(.value)"
  '
)
eval $(
  echo "$DISPLAY_INFO" | $JQ -r '
    {
      SCREEN_WIDTH: .frame.w,
      SCREEN_HEIGHT: .frame.h
    } | to_entries | .[] | "\(.key)=\(.value)"
  '
)

# Remove decimals added for high DPI screens.
SCREEN_WIDTH=${SCREEN_WIDTH%%.*}
SCREEN_HEIGHT=${SCREEN_HEIGHT%%.*}
WINDOW_X=${WINDOW_X%%.*}
WINDOW_Y=${WINDOW_Y%%.*}
WINDOW_WIDTH=${WINDOW_WIDTH%%.*}

# Define the target widths using bc for precise calculation and rounding
WIDTH_ONE_THIRD=$((SCREEN_WIDTH / 3))
WIDTH_HALF=$((SCREEN_WIDTH / 2))
WIDTH_TWO_THIRDS=$((2 * SCREEN_WIDTH / 3))

# If we're switching from LTR or RTL, always use the half size.
if [ "$WINDOW_X" -eq 0 ] && [ "$ANCHOR" = "right" ]; then
  NEW_WIDTH=$WIDTH_HALF
elif [ $(($WINDOW_X + $WINDOW_WIDTH)) -eq "$SCREEN_WIDTH" ] && [ "$ANCHOR" = "left" ]; then
  NEW_WIDTH=$WIDTH_HALF

# Cycle through the rest of the sizes.
elif [ "$WINDOW_WIDTH" -eq "$WIDTH_HALF" ]; then
  NEW_WIDTH=$WIDTH_ONE_THIRD
elif [ "$WINDOW_WIDTH" -eq "$WIDTH_ONE_THIRD" ]; then
  NEW_WIDTH=$WIDTH_TWO_THIRDS
elif [ "$WINDOW_WIDTH" -eq "$WIDTH_TWO_THIRDS" ]; then
  NEW_WIDTH=$WIDTH_HALF
else
  NEW_WIDTH=$WIDTH_HALF
fi

# Determine the x-coordinate based on the anchoring direction
if [ "$ANCHOR" == "left" ]; then
  NEW_X=0
else
  NEW_X=$((SCREEN_WIDTH - NEW_WIDTH))
fi

# Move and resize the window to fill the height of the screen and anchor to the specified side
$YABAI -m window $WINDOW_ID --move abs:$NEW_X:0
$YABAI -m window $WINDOW_ID --resize abs:$NEW_WIDTH:$SCREEN_HEIGHT
