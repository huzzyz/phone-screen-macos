#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Phone Screen.app"
ARCHIVE="$ROOT/dist/Phone-Screen-darwin64.zip"

"$ROOT/scripts/build-app.sh"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ARCHIVE"
(cd "$ROOT/dist" && shasum -a 256 "$(basename "$ARCHIVE")" >"$(basename "$ARCHIVE").sha256")
printf 'Packaged %s\n' "$ARCHIVE"
