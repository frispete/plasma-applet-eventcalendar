#!/bin/bash
# Load the widget from this checkout in plasmoidviewer without showing a window
# and print its log, eg: scripts/viewer-log.sh 8 [extra plasmoidviewer args]
cd "$(dirname "$0")/.."
seconds="${1:-8}"; shift
QT_FORCE_STDERR_LOGGING=1 QT_QPA_PLATFORM=offscreen QML_DISABLE_DISK_CACHE=1 QT_LOGGING_RULES="qml.debug=true" \
	timeout "$seconds" plasmoidviewer -a "$PWD/package" "$@" 2>&1 \
	| grep -v "^QML debugging is enabled"
exit 0
