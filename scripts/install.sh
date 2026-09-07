#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Phone Screen.app"
DEST="/Applications/Phone Screen.app"

"$ROOT/scripts/build-app.sh"

if [ -e "$DEST" ]; then
    backup="$HOME/Desktop/Phone Screen.backup.$(date +%Y%m%d-%H%M%S).app"
    mv "$DEST" "$backup"
    printf 'Existing app moved to %s\n' "$backup"
fi

cp -R "$APP" "$DEST"
printf 'Installed %s\n' "$DEST"
