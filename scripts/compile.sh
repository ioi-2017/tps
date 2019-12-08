#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"


function usage {
	errcho "Usage: <compile> [options] <solution-path>"
	errcho "Options:"

	errcho -e "  -h, --help"
	errcho -e "\tShows this help."

	errcho -e "  -v, --verbose"
	errcho -e "\tPrints verbose details on values, decisions, and commands being executed."

	errcho -e "  -w, --warning-sensitive"
	errcho -e "\tFails when there are warnings."

	errcho -e "  -p, --public"
	errcho -e "\tUses the public graders for compiling the solution."
}

if "${HAS_GRADER}"; then
	GRADER_TYPE="judge"
fi

VERBOSE="false"
WARNING_SENSITIVE_RUN="false"

function handle_option {
	shifts=0
	case "${curr}" in
		-h|--help)
			usage
			exit 0
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
				errcho "Invalid option: There is no grader in this task."
				exit 2
			fi
			;;
		*)
			invalid_arg "undefined option"
			;;
	esac
}

function handle_positional_arg {
	if variable_not_exists "SOLUTION" ; then
		SOLUTION="${curr}"
		return
	fi
	invalid_arg "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "$@"

if variable_not_exists "SOLUTION" ; then
	errcho "Solution is not specified."
	usage
	exit 2
fi

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
