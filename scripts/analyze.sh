#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"

problem_code=$(sensitive "${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "code")
tps_web_url=$(sensitive "${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "tps_web_url")

commit=$(git log --pretty=format:'%H' -n 1)

analysis_url="${tps_web_url}/problem/${problem_code}/${commit}/analysis"

echo "Openning address: '${analysis_url}'"

function try_open {
	if which "$1" >/dev/null 2>&1 ; then
		"$@"
		exit
	fi
}

try_open "xdg-open" "${analysis_url}"
try_open "gnome-open" "${analysis_url}"
try_open "open" "${analysis_url}"
try_open "start" "${analysis_url}"
try_open "cygstart" "${analysis_url}"
try_open ""${PYTHON}"" "-mwebbrowser" "${analysis_url}"

errcho "Could not open the browser"
exit 1
