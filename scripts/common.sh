# Shared helpers for the build/install scripts. Source it, don't run it.
# Expects the current directory to be the repository root.

metadataFile="$PWD/package/metadata.json"

### Colors
# https://stackoverflow.com/questions/911168/how-can-i-detect-if-my-shell-script-is-running-through-a-pipe
TC_Red='\033[31m'; TC_LightGray='\033[90m'; TC_LightGreen='\033[92m'
TC_Reset='\033[0m'; TC_Bold='\033[1m'
if [ ! -t 1 ]; then
	TC_Red=''; TC_LightGray=''; TC_LightGreen=''; TC_Reset=''; TC_Bold=''
fi
function echoGray { echo -e "${TC_LightGray}$1${TC_Reset}"; }
function echoRed { echo -e "${TC_Red}$1${TC_Reset}"; }
function echoGreen { echo -e "${TC_LightGreen}$1${TC_Reset}"; }

# Print a value from package/metadata.json, eg: metadata KPlugin.Id
function metadata {
	python3 -c '
import json, sys
value = json.load(open(sys.argv[1], encoding="utf-8"))
for key in sys.argv[2].split("."):
	value = value[key]
print(value)
' "$metadataFile" "$1"
}

# Exit with an error if a command is missing.
function requireCommand {
	if ! command -v "$1" &> /dev/null; then
		echoRed "[error] '$1' not found.${2:+ Install it with: ${TC_Bold}$2}"
		exit 1
	fi
}

function restartPlasmashell {
	echoGray "Restarting plasmashell"
	if systemctl --user --quiet is-active plasma-plasmashell.service; then
		systemctl --user restart plasma-plasmashell.service
	else
		kquitapp6 plasmashell
		kstart plasmashell &> /dev/null
	fi
}
