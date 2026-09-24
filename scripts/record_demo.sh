#!/usr/bin/env bash
# Runs the scripted demo tour on an iOS simulator, records the screen to
# docs/demo/my_clinic_demo.mp4 and saves screenshots to docs/screenshots/.
#
# Usage: scripts/record_demo.sh [simulator-udid]
# With no UDID it uses the simulator that is already booted.
set -euo pipefail

cd "$(dirname "$0")/.."

UDID="${1:-$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1)}"
if [[ -z "$UDID" ]]; then
  echo "No booted simulator. Boot one first, e.g.: open -a Simulator" >&2
  exit 1
fi

RAW_VIDEO="$(mktemp -t my_clinic_raw).mp4"
VIDEO="docs/demo/my_clinic_demo.mp4"
LOG="$(mktemp -t my_clinic_demo).log"
mkdir -p docs/demo docs/screenshots

# Clean status bar: 9:41, full battery and signal.
xcrun simctl status_bar "$UDID" override --time "9:41" --batteryState charged \
  --batteryLevel 100 --cellularBars 4 --wifiBars 3 || true

flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/demo_tour_test.dart -d "$UDID" >"$LOG" 2>&1 &
DRIVE_PID=$!

# Start recording when the tour starts, so the build and install are cut.
until grep -q "DEMO_TOUR_START" "$LOG"; do
  if ! kill -0 "$DRIVE_PID" 2>/dev/null; then cat "$LOG"; exit 1; fi
  sleep 0.2
done
xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$RAW_VIDEO" &
REC_PID=$!
echo "Recording…"

until grep -q "DEMO_TOUR_END" "$LOG"; do
  if ! kill -0 "$DRIVE_PID" 2>/dev/null; then break; fi
  sleep 0.2
done
sleep 1
kill -INT "$REC_PID" 2>/dev/null || true
wait "$REC_PID" 2>/dev/null || true

STATUS=0
wait "$DRIVE_PID" || STATUS=$?
xcrun simctl status_bar "$UDID" clear || true

# The raw recording is ~60 MB; shrink it to about 10 MB.
swift scripts/shrink_video.swift "$RAW_VIDEO" "$VIDEO" 420000

tail -5 "$LOG"
echo "Video: $VIDEO"
echo "Screenshots: docs/screenshots/"
exit "$STATUS"
