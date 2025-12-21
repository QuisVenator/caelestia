#!/usr/bin/env zsh

# Usage: ./wsaction.sh [-g] <dispatcher> <workspace>
# Example: ./wsaction.sh workspace 5  (Goes to WS 5 in current group)
# Example: ./wsaction.sh -g workspace 2 (Goes to Group 2, keeping relative WS)

GROUP_MODE=0

# Parse flags
if [[ "$1" == "-g" ]]; then
    GROUP_MODE=1
    shift # Remove the -g flag so $1 becomes the dispatcher
fi

if [[ $# -ne 2 ]]; then
    echo "Wrong number of arguments."
    exit 1
fi

DISPATCHER="$1"
TARGET_ARG="$2"

# Get current active workspace ID using jq
ACTIVE_WS=$(hyprctl activeworkspace -j | jq -r '.id')

if [[ $GROUP_MODE -eq 1 ]]; then
    # --- Move to Group ---
    # Math: (TargetGroup - 1) * 10 + (ActiveWS % 10)
    # Note: If ActiveWS is 10, 20, 30, modulo returns 0. We map 0 -> 10 for logic.
    
    REL_WS=$(( ACTIVE_WS % 10 ))
    if [[ $REL_WS -eq 0 ]]; then REL_WS=10; fi
    
    TARGET_WS=$(( (TARGET_ARG - 1) * 10 + REL_WS ))
    
    hyprctl dispatch "$DISPATCHER" "$TARGET_WS"

else
    # --- Move to Workspace in Current Group ---
    # Math: Floor((ActiveWS - 1) / 10) * 10 + TargetWS
    
    CURRENT_GROUP_BASE=$(( ((ACTIVE_WS - 1) / 10) * 10 ))
    TARGET_WS=$(( CURRENT_GROUP_BASE + TARGET_ARG ))
    
    hyprctl dispatch "$DISPATCHER" "$TARGET_WS"
fi
