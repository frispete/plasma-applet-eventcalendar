#!/bin/bash
# Run the widget from this checkout in plasmoidviewer on a private Xvfb display
# and save a screenshot, eg: scripts/viewer-shot.sh out.png 12 [plasmoidviewer args]
cd "$(dirname "$0")/.."
out="${1:-viewer.png}"; seconds="${2:-12}"; shift 2
display=":$((90 + RANDOM % 9))"
Xvfb "$display" -screen 0 1400x1000x24 -nolisten tcp &> /dev/null &
xvfbPid=$!
sleep 1
DISPLAY="$display" QT_QPA_PLATFORM=xcb QT_FORCE_STDERR_LOGGING=1 QML_DISABLE_DISK_CACHE=1 \
	plasmoidviewer -a "$PWD/package" "$@" &> "${out%.png}.log" &
viewerPid=$!
sleep "$seconds"
DISPLAY="$display" import -window root "$out"
kill "$viewerPid" "$xvfbPid" 2> /dev/null
wait 2> /dev/null
exit 0
