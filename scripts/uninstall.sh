#!/bin/bash
set -euo pipefail

APP="/Applications/Phone Screen.app"

if [ ! -e "$APP" ]; then
    printf 'Phone Screen is not installed.\n'
    exit 0
fi

destination="$HOME/.Trash/Phone Screen.$(date +%Y%m%d-%H%M%S).app"
mv "$APP" "$destination"
printf 'Moved Phone Screen to %s\n' "$destination"
printf 'Pairing keys and the cached endpoint were preserved.\n'
