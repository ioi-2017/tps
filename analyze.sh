#!/bin/bash

source "${internals}/util.sh"
source "${internals}/tps_variables.sh"

set -e

check_variable tps_url

commit=$(git log --pretty=format:'%H' -n 1)

analysis_url="${tps_url}/problem/${problem_name}/${commit}/analysis"

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
python -mwebbrowser "${analysis_url}"

