#!/usr/bin/env zsh

function message() {
    local msg="$1"
    # Calculate byte length of the message
    # Note: jq usually escapes non-ASCII, so character length equals byte length.
    # If using raw UTF-8, $(echo -n "$msg" | wc -c) would be safer.
    local len=${#msg}

    # Write the length as a 32-bit Little Endian integer
    # Native Messaging expects 4 bytes: LSB first
    printf "\\x%02x\\x%02x\\x%02x\\x%02x" \
        $(( len & 0xff )) \
        $(( (len >> 8) & 0xff )) \
        $(( (len >> 16) & 0xff )) \
        $(( (len >> 24) & 0xff ))

    # Write the message itself
    printf '%s' "$msg"
}

# Determine state directory (mimicking the boolean logic from the Fish script)
# ${VAR:-default} uses default if VAR is unset or null
state="${XDG_STATE_HOME:-$HOME/.local/state}"
state_dir="$state/caelestia"
scheme_path="$state_dir/scheme.json"

# Send initial message
message "$(jq -c . "$scheme_path")"

# Watch for file changes
# read -r prevents backslash interpretation
inotifywait -q -e 'close_write,moved_to,create' -m "$state_dir" | while read -r dir events file; do
    if [[ "$dir$file" == "$scheme_path" ]]; then
        message "$(jq -c . "$scheme_path")"
    fi
done