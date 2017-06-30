#!/bin/bash

# A supplimentary command as a tool used in TPS repositories
# Kian Mirjalali, Hamed Saleh
# IOI 2017, Iran


tps_version=1.0



set -e

function errcho {
	>&2 echo "$@"
}

function tps_usage {
	errcho "TPS version ${tps_version}"
	errcho "Usage: tps <command> <arguments>..."
	exit 1
}


[ $# -gt 0 ] || tps_usage
command=$1; shift

function find_base_dir {	
	target_file=problem.json
	
	#looking for ${target_file} in current and parent directories...
	curr=$PWD
	while [ "${curr}" != "${old}" ] ; do
		if [ -f "${curr}/${target_file}" ] ; then
			base_dir="${curr}"
			break
		fi
		old="${curr}"
		curr=$(dirname ${curr})
	done
	
	if [ -z ${base_dir+x} ]; then
		errcho "Error: Not a TPS repository (${target_file} not found in any of the parent directories)"
		exit 2
	fi
	echo ${base_dir}
}

base_dir=$(find_base_dir)
export base_dir


__scripts__="scripts"
__scripts_dir__="${base_dir}/${__scripts__}"

if [ ! -d "${__scripts_dir__}" ] ; then
	errcho "Error: Directory '${__scripts__}.' not found"
	exit 2
fi

__tps_init__="${__scripts__}/internal/tps_init.sh"
__tps_init_file__="${base_dir}/${__tps_init__}"

if [ ! -f "${__tps_init_file__}" ] ; then
	errcho "Error: File '${__tps_init__}' not found."
	exit 2
fi

source "${__tps_init_file__}"

if [ -f "${__scripts_dir__}/${command}.sh" ]; then
	bash "${__scripts_dir__}/${command}.sh" "$@"
elif [ -f "${__scripts_dir__}/${command}.py" ]; then
	python "${__scripts_dir__}/${command}.py" "$@"
elif [ -f "${__scripts_dir__}/${command}.exe" ]; then
	"${__scripts_dir__}/${command}.exe" "$@"
else
	errcho "Error: command '${command}' not found in '${__scripts__}'".
	errcho "Searched for '${command}.sh', '${command}.py', '${command}.exe'."
	exit 2
fi

