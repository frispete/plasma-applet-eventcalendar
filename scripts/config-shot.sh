#!/bin/bash
# Open the settings dialog on one page in plasmoidviewer (Xvfb) and save a
# screenshot plus log. Works on a temporary copy of the package.
# Eg: scripts/config-shot.sh config/ConfigGeneral.qml out.png
cd "$(dirname "$0")/.."
page="$1"; out="${2:-config.png}"; seconds="${3:-15}"
tmp="$(mktemp -d)"
cp -r package "$tmp/"
python3 - "$tmp/package" "$page" <<'PY'
import re, sys
pkg, page = sys.argv[1], sys.argv[2]
cfg = pkg + '/contents/config/config.qml'
s = open(cfg).read()
cats = list(re.finditer(r'\tConfigCategory \{\n.*?\n\t\}\n', s, re.S))
target = next(m for m in cats if '"' + page + '"' in m.group(0))
block = target.group(0).replace('\t\tvisible: Plasmoid.configuration.debugging\n', '')
s = s[:target.start()] + s[target.end():]
first = cats[0].start()
s = s[:first] + block + s[first:]
open(cfg, 'w').write(s)
main = pkg + '/contents/ui/main.qml'
m = open(main).read()
m = m.replace('\t\tDigitalClock.ClipboardMenu.setupMenu(clipboardAction)\n',
	'\t\tDigitalClock.ClipboardMenu.setupMenu(clipboardAction)\n\t\tPlasmoid.internalAction("configure").trigger()\n')
open(main, 'w').write(m)
PY
display=":$((90 + RANDOM % 9))"
Xvfb "$display" -screen 0 1400x1000x24 -nolisten tcp &> /dev/null &
xvfbPid=$!
sleep 1
DISPLAY="$display" QT_QPA_PLATFORM=xcb QT_FORCE_STDERR_LOGGING=1 QML_DISABLE_DISK_CACHE=1 \
	plasmoidviewer -a "$tmp/package" -l floating -f planar -s 300x200 -x 1100 -y 800 &> "${out%.png}.log" &
viewerPid=$!
sleep "$seconds"
DISPLAY="$display" import -window root "$out"
kill "$viewerPid" "$xvfbPid" 2> /dev/null
wait 2> /dev/null
sed -i "s|$tmp/package|package|g" "${out%.png}.log"
rm -rf "$tmp"
exit 0
