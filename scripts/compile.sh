#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"


function usage {
	errcho -ne "\
Usage:
  tps compile [options] <solution-path>

Description:
  Compiles a solution in the sandbox.

Options:
\
  -h, --help
\tShows this help.
\
  -v, --verbose
\tPrints verbose details on values, decisions, and commands being executed.
\
  -w, --warning-sensitive
\tFails when there are warnings.
\
  -p, --public
\tUses the public graders for compiling the solution.
\tThis option is available only if the task has grader.
"
}

if "${HAS_GRADER}"; then
	GRADER_TYPE="judge"
fi

VERBOSE="false"
WARNING_SENSITIVE_RUN="false"

function handle_option {
	local -r curr_arg="$1"; shift
	case "${curr_arg}" in
		-h|--help)
			usage_exit 0
			;;
		-v|--verbose)
			VERBOSE=true
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
	if variable_not_exists "SOLUTION" ; then
		SOLUTION="${curr_arg}"
		return
	fi
	invalid_arg_with_usage "${curr_arg}" "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "invalid_arg_with_usage" "$@"

variable_exists "SOLUTION" ||
	error_usage_exit 2 "Solution is not specified."

WARN_FILE="${SANDBOX}/compile.warn"

export VERBOSE GRADER_TYPE WARN_FILE
ret=0
bash "${INTERNALS}/compile_solution.sh" "${SOLUTION}" || ret=$?


if [ ${ret} -eq 0 ]; then
	if [ -s "${WARN_FILE}" ] ; then
		if is_warning_sensitive; then
			ret="${warn_status}"
			cecho fail "FAILED, due to sensitivity to warnings"
		else
			cecho warn "OK, but with warnings"
		fi
	else
		cecho success "OK"
	fi
else
	cecho fail "FAILED."
fi

exit ${ret}
