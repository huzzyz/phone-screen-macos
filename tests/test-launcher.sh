#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d /tmp/phone-screen-tests.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
FIXTURES="$ROOT/tests/fixtures"

result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-connected" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_CACHE_DIR="$WORK/cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.10:37123" ]
[ "$(cat "$WORK/cache/last-endpoint")" = "$result" ]
printf 'PASS connected device discovery\n'

result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-mdns" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_CACHE_DIR="$WORK/mdns-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.15:39111" ]
printf 'PASS ADB mDNS discovery\n'

result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-dnssd" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_DNSSD_BIN="$FIXTURES/dns-sd" PHONE_SCREEN_HOST_LOOKUP_BIN="$FIXTURES/dscacheutil" PHONE_SCREEN_DISCOVERY_SECONDS=1 PHONE_SCREEN_CACHE_DIR="$WORK/dnssd-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.20:43210" ]
printf 'PASS native macOS DNS-SD fallback\n'

if PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-missing" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_DNSSD_BIN="$WORK/missing-dnssd" PHONE_SCREEN_CACHE_DIR="$WORK/empty-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen" >"$WORK/out" 2>"$WORK/err"; then
    printf 'FAIL missing-device path returned success\n' >&2
    exit 1
fi
grep -q 'No Android device was found' "$WORK/err"
printf 'PASS visible failure path\n'
