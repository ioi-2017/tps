#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"


if [ $# -eq 0 ]; then
	readonly help_mode="true"
	echo "\
Usage: tps export <exporter> [exporter-options...]
It assumes that test data is already generated.
"
	function help_exit {
		local -r message="$1"; shift
		echo "${message}"
		exit 1
	}
else
	readonly help_mode="false"
	exporter_name="$1"; shift
fi


if ! "${help_mode}" && [ "${exporter_name}" == "--bash-completion" ]; then
	readonly bash_completion_mode="true"
	unset exporter_name
	setup_bash_completion "$@"
	shift "${shifts}"
else
	readonly bash_completion_mode="false"
fi

function error_exit {
	"${bash_completion_mode}" && exit 0
	local -r exit_code="$1"; shift
	local -r message="$1"; shift
	errcho "Error: ${message}"
	exit "${exit_code}"
}


if [ ! -d "${EXPORTERS_DIR}" ]; then
	"${help_mode}" && help_exit "In a repository without directory '${EXPORTERS_DIR_RELATIVE}'."
	error_exit 2 "Directory '${EXPORTERS_DIR_RELATIVE}' not found."
fi


source "${INTERNALS}/run_util.sh"

function list_exporters {
	ls -a -1 "${EXPORTERS_DIR}" 2>/dev/null | filter_files_as_runnable_commands
}


if "${bash_completion_mode}"; then
	if [ ${bc_index} -eq 1 ]; then
		available_exporters="$(list_exporters)"
		readonly available_exporters
		if [ -n "${available_exporters}" ]; then
			compgen -W "${available_exporters}" -- "${bc_current_token_prefix}" | add_space_all || true
		fi
		exit 0
	fi
	# Extracting the export format name
	exporter_name="$1"; shift; decrement bc_index
	# bc_index >= 1
fi

if "${help_mode}"; then
	available_exporters="$(list_exporters)"
	readonly available_exporters
	if [ -z "${available_exporters}" ]; then
		help_exit "No exporters available in '${EXPORTERS_DIR_RELATIVE}'."
	else
		help_exit "\
Available exporters:
$(echo "${available_exporters}" | decorate_lines '  ')

All exporters have these options:
  -h, --help
    Shows the help for the exporter.

  -v, --verbose
    Prints verbose details on values, decisions, and commands being executed.
"
	fi
fi


exporter_file_name="$(find_runnable_file "${exporter_name}" "${EXPORTERS_DIR}")"
readonly exporter_file_name

if [ -z "${exporter_file_name}" ]; then
	error_exit 2 "Exporter '${exporter_name}' not found in '${EXPORTERS_DIR_RELATIVE}'.
Searched for $(searched_runnable_files_str "${exporter_name}" "${EXPORTERS_DIR}")."
fi

readonly exporter_file="${EXPORTERS_DIR}/${exporter_file_name}"

if "${bash_completion_mode}"; then
	run_file "${exporter_file}" "--bash-completion" "${bc_index}" "${bc_cursor_offset}" "$@"
	exit 0
fi

run_file "${exporter_file}" "$@"
