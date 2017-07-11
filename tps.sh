#!/bin/bash

# A supplimentary command as a tool used in TPS repositories
# Kian Mirjalali, Hamed Saleh
# IOI 2017, Iran


tps_version=1.0



set -e

function errcho {
	>&2 echo "$@"
}



__tps_target_file__="problem.json"

#looking for ${__tps_target_file__} in current and parent directories...
__tps_curr__="$PWD"
while [ "${__tps_curr__}" != "${__tps_prev__}" ] ; do
	if [ -f "${__tps_curr__}/${__tps_target_file__}" ] ; then
		base_dir="${__tps_curr__}"
		break
	fi
	__tps_prev__="${__tps_curr__}"
	__tps_curr__="$(dirname "${__tps_curr__}")"
done



__tps_scripts__="scripts"
__tps_scripts_dir__="${base_dir}/${__tps_scripts__}"


function __tps_list_commands__ {
	ls -a -1 "${__tps_scripts_dir__}" 2>/dev/null | grep -E ".\\.(sh|py|exe)$" | while read f; do echo ${f%.*} ; done
}

function __tps_unify_elements__ {
	_sort=$(which -a "sort" | grep -iv "windows" | head -1)
	if [ -z "${_sort}" ] ; then
		_sort="cat"
	fi
	${_sort} | uniq
}

function __tps_help__ {
	echo "TPS version ${tps_version}"
	echo ""
	echo "Usage: tps <command> <arguments>..."
	echo ""
	if [ -z "${base_dir+x}" ]; then
		echo "Currently not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)."
	elif [ ! -d "${__tps_scripts_dir__}" ] ; then
		echo "Directory '${__tps_scripts__}' is not available."
	elif [ -z "$(__tps_list_commands__)" ] ; then
		echo "No commands available in '${__tps_scripts__}'."
	else
		echo "Available commands:"
		__tps_list_commands__ | __tps_unify_elements__
	fi
	exit 1
}


[ $# -gt 0 ] || __tps_help__
__tps_command__="$1"; shift

if [ "${__tps_command__}" == "--bash-completion" ] ; then
	[ $# -gt 0 ] || exit 0
	[ ! -z "${base_dir+x}" -a -d "${__tps_scripts_dir__}" ] || exit 0
	
	index=$1
	
	[ $index -gt 0 ] || exit 0

	# removing index
	shift
	
	# removing 'tps'
	shift

	cur="${!index}"

	if [ $index -eq 1 ]; then
		opts="$(__tps_list_commands__)"
		compgen -W "${opts}" -- "${cur}" | {
			while read -r tmp; do
				printf '%s \n' "$tmp"
			done
		}
		exit 0
	fi

	command="$1"; shift
	
	command_bc_options_file="${__tps_scripts_dir__}/bash_completion/${command}.options"

	if [ -f "${command_bc_options_file}" ] && [[ ${cur} == --*  ]]; then
		if ! [[ ${cur} == --?*=* ]]; then
			compgen -W "$(cat "${command_bc_options_file}")" -- "${cur}" | {
				while read -r tmp; do
					if [[ ${tmp} != *= ]]; then
						printf '%s \n' "$tmp"
					else
						printf '%s\n' "$tmp"
					fi
				done
			}
			exit 0
		else
			value="${cur#*=}"
			compgen -f -- "${value}"
			exit 0
		fi
	fi

	compgen -f -- "${cur}"
	exit 0
fi


if [ -z "${base_dir+x}" ]; then
	errcho "Error: Not in a TPS repository ('${__tps_target_file__}' not found in any of the parent directories)"
	exit 2
fi

export base_dir



if [ ! -d "${__tps_scripts_dir__}" ] ; then
	errcho "Error: Directory '${__tps_scripts__}' not found."
	exit 2
fi

__tps_init__="${__tps_scripts__}/internal/tps_init.sh"
__tps_init_file__="${base_dir}/${__tps_init__}"

if [ ! -f "${__tps_init_file__}" ] ; then
	errcho "Error: File '${__tps_init__}' not found."
	exit 2
fi

source "${__tps_init_file__}"

if [ -f "${__tps_scripts_dir__}/${__tps_command__}.sh" ]; then
	bash "${__tps_scripts_dir__}/${__tps_command__}.sh" "$@"
elif [ -f "${__tps_scripts_dir__}/${__tps_command__}.py" ]; then
	python "${__tps_scripts_dir__}/${__tps_command__}.py" "$@"
elif [ -f "${__tps_scripts_dir__}/${__tps_command__}.exe" ]; then
	"${__tps_scripts_dir__}/${__tps_command__}.exe" "$@"
else
	errcho "Error: command '${__tps_command__}' not found in '${__tps_scripts__}'".
	errcho "Searched for '${__tps_command__}.sh', '${__tps_command__}.py', '${__tps_command__}.exe'."
	exit 2
fi

