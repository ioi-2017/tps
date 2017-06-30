#!/bin/bash

# A supplimentary command as a tool used in TPS repositories
# Kian Mirjalali
# IOI 2017, Iran


version=1.0



set -e

alias errcho='>&2 echo'

function usage {
	errcho "TPS version ${version}"
	errcho "Usage: tps <command> <arguments>..."
	exit 1
}


[ $# -gt 0 ] || usage
command=$1; shift


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
	errcho "Fatal: Not a TPS repository (${target_file} not found in any of the parent directories)"
	exit 2
fi

export base_dir



scripts="scripts"
internals="${scripts}/internal"
tps_init=${internals}/tps_init.sh

scripts_dir="${base_dir}/${scripts}"
internals_dir="${base_dir}/${internals}"
tps_init_file="${base_dir}/${tps_init}"


if [ ! -d "${scripts_dir}" ] ; then
	errcho "Error: Directory '${scripts}.' not found"
	exit 2
fi

if [ ! -d "${internals_dir}" ] ; then
	errcho "Error: Directory '${internals}' not found."
	exit 2
fi

if [ ! -f "${tps_init_file}" ] ; then
	errcho "Error: File '${tps_init}' not found."
	exit 2
fi

source "${tps_init_file}"

if [ -f "${scripts_dir}/${command}.sh" ]; then
	sh "${scripts_dir}/${command}.sh" "$@"
elif [ -f "${scripts_dir}/${command}.py" ]; then
	python "${scripts_dir}/${command}.py" "$@"
elif [ -f "${scripts_dir}/${command}.exe" ]; then
	"${scripts_dir}/${command}.exe" "$@"
else
	errcho "Error: command '${command}' not found in '${scripts}'".
	errcho "Searched for '${command}.sh', '${command}.py', '${command}.exe'."
	exit 2
fi

