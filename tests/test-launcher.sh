#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d /tmp/phone-screen-tests.XXXXXX)"
trap 'rm -rf "$WORK"' EXIT
FIXTURES="$ROOT/tests/fixtures"

result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-connected" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_CACHE_DIR="$WORK/cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.10:37123" ]
[ "$(cat "$WORK/cache/last-endpoint")" = "$result" ]
[ "$(cat "$WORK/cache/device-serial")" = "PHONE-ONE" ]
! grep -q '^mdns services$' "$WORK/cache/adb-calls"
! grep -q '^connect ' "$WORK/cache/adb-calls"
printf 'PASS connected device discovery\n'

result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-mixed" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_CACHE_DIR="$WORK/mixed-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.10:37123" ]
printf 'PASS unrelated USB device is ignored\n'

mkdir -p "$WORK/changed-port-cache"
printf 'PHONE-ONE\n' >"$WORK/changed-port-cache/device-serial"
printf '192.0.2.10:37123\n' >"$WORK/changed-port-cache/last-endpoint"
result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-changed-port" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_CACHE_DIR="$WORK/changed-port-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.10:49999" ]
[ "$(cat "$WORK/changed-port-cache/device-serial")" = "PHONE-ONE" ]
printf 'PASS enrolled phone survives endpoint change\n'

if PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-ambiguous" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_DNSSD_BIN="$WORK/missing-dnssd" PHONE_SCREEN_CACHE_DIR="$WORK/ambiguous-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen" >"$WORK/ambiguous-out" 2>"$WORK/ambiguous-err"; then
    printf 'FAIL ambiguous-device path returned success\n' >&2
    exit 1
fi
grep -q 'More than one wireless Android phone was found' "$WORK/ambiguous-err"
printf 'PASS distinct wireless phones are not selected arbitrarily\n'

mkdir -p "$WORK/enrolled-multiple-cache"
printf 'PHONE-TWO\n' >"$WORK/enrolled-multiple-cache/device-serial"
result="$(PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-ambiguous" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy" PHONE_SCREEN_CACHE_DIR="$WORK/enrolled-multiple-cache" PHONE_SCREEN_NO_GUI=1 PHONE_SCREEN_TEST=1 "$ROOT/src/phone-screen")"
[ "$result" = "192.0.2.11:37124" ]
printf 'PASS enrolled identity selects the correct wireless phone\n'

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

if PHONE_SCREEN_ADB_BIN="$FIXTURES/adb-connected" PHONE_SCREEN_SCRCPY_BIN="$FIXTURES/scrcpy-failing" PHONE_SCREEN_CACHE_DIR="$WORK/scrcpy-failure-cache" PHONE_SCREEN_NO_GUI=1 "$ROOT/src/phone-screen" >"$WORK/scrcpy-out" 2>"$WORK/scrcpy-err"; then
    printf 'FAIL scrcpy failure returned success\n' >&2
    exit 1
fi
grep -q 'screen mirroring could not start' "$WORK/scrcpy-err"
grep -q 'device disconnected during startup' "$WORK/scrcpy-err"
grep -q 'device disconnected during startup' "$WORK/scrcpy-failure-cache/last-run.log"
printf 'PASS scrcpy startup failure is reported and logged\n'
