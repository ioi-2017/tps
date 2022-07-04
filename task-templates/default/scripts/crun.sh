#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"


function usage {
	errcho -ne "\
Usage:
  tps crun [options] <solution-path> [ -- solution-run-arguments... ]

Description:
  Compiles and runs a solution.

Options:
\
  -h, --help
\tShows this help.
\
  -w, --warning-sensitive
\tFails when there are warnings.
\
  -p, --public
\tUses the public graders for compiling the solution.
\tThis option is available only if the task has grader.
"
}


compile_args=()
run_args=()
in_run_args="false"
for arg in "$@"; do
	if "${in_run_args}"; then
		run_args+=("${arg}")
	elif [ "${arg}" == "--" ]; then
		in_run_args="true"
	else
		compile_args+=("${arg}")
	fi
done


if "${HAS_GRADER}"; then
	GRADER_TYPE="judge"
fi

WARNING_SENSITIVE_RUN="false"

function handle_option {
	local -r curr_arg="$1"; shift
	case "${curr_arg}" in
		-h|--help)
			usage_exit 0
			;;
		-w|--warning-sensitive)
			WARNING_SENSITIVE_RUN="true"
			;;
		-p|--public)
			if "${HAS_GRADER}"; then
				GRADER_TYPE="public"
			else
				error_usage_exit 2 "Invalid option '${curr_arg}': There is no grader in this task."
			fi
			;;
		*)
			invalid_arg_with_usage "${curr_arg}" "undefined option"
			;;
	esac
}

function handle_positional_arg {
	local -r curr_arg="$1"; shift
	if variable_not_exists "solution" ; then
		solution="${curr_arg}"
		return
	fi
	invalid_arg_with_usage "${curr_arg}" "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "invalid_arg_with_usage" ${compile_args[@]+"${compile_args[@]}"}

variable_exists "solution" ||
	error_usage_exit 2 "Solution is not specified."

sensitive check_file_exists "Solution file" "${solution}"


{
	recreate_dir "${LOGS_DIR}"
	export GRADER_TYPE
	printf "compile"
	sensitive reporting_guard "solution.compile" bash "${INTERNALS}/compile_solution.sh" "${solution}"
	echo
} >&2

bash "${SANDBOX}/run.sh" ${run_args[@]+"${run_args[@]}"}
