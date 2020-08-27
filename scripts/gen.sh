#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"


function usage {
	errcho "Usage: <gen> [options]"
	errcho "Options:"

	errcho -e "  -h, --help"
	errcho -e "\tShows this help."

	errcho -e "  -s, --sensitive"
	errcho -e "\tTerminates on the first error and shows the error details."

	errcho -e "  -w, --warning-sensitive"
	errcho -e "\tTerminates on the first warning or error and shows the details."

	errcho -e "  -u, --update"
	errcho -e "\tUpdates the existing set of tests."
	errcho -e "\tPrevents the initial cleanup of the tests directory."
	errcho -e "\tUsed when a subset of test data needs to be generated again."
	errcho -e "\tWarning: Use this feature only when the other tests are not needed or already generated correctly."

	errcho -e "  -t, --test=<test-name-pattern>"
	errcho -e "\tGenerates only tests matching the given pattern. Examples: 1-01, '1-*', '1-0?'"
	errcho -e "\tMultiple patterns can be given using commas or pipes. Examples: '1-01, 2-*', '?-01|*2|0-*'"
	errcho -e "\tNote: Use quotation marks or escaping (with '\\') when using wildcards in the pattern to prevent shell expansion."
	errcho -e "\t      Also, use escaping (with '\\') when separating multiple patterns using pipes."

	errcho -e "  -m, --model-solution=<model-solution-path>"
	errcho -e "\tGenerates test outputs using the given solution."

	errcho -e "  -d, --gen-data=<gen-data-file>"
	errcho -e "\tOverrides the location of meta-data file used for test generation."

	errcho -e "      --tests-dir=<tests-directory-path>"
	errcho -e "\tOverrides the location of the tests directory."

	errcho -e "      --no-gen"
	errcho -e "\tSkips running the generators for generating test inputs."
	errcho -e "\tPrevents the initial cleanup of the tests directory."
	errcho -e "\tUsed when test inputs are already thoroughly generated and only test outputs need to be generated."

	errcho -e "      --no-sol"
	errcho -e "\tSkips running the model solution for generating test outputs."

	errcho -e "      --no-val"
	errcho -e "\tSkips validating test inputs."

	errcho -e "      --no-sol-compile"
	errcho -e "\tSkips compiling the model solution."
	errcho -e "\tUses the solution already compiled and available in the sandbox."
}


model_solution=""
tests_dir="${TESTS_DIR}"
gen_data_file="${GEN_DIR}/data"
SENSITIVE_RUN="false"
WARNING_SENSITIVE_RUN="false"
UPDATE_MODE="false"
SPECIFIC_TESTS="false"
SPECIFIED_TESTS_PATTERN=""
SKIP_GEN="false"
SKIP_SOL="false"
SKIP_VAL="false"
skip_compile_sol="false"

function handle_option {
	shifts=0
	case "${curr}" in
		-h|--help)
			usage
			exit 0
			;;
		-s|--sensitive)
			SENSITIVE_RUN="true"
			;;
		-w|--warning-sensitive)
			SENSITIVE_RUN="true"
			WARNING_SENSITIVE_RUN="true"
			;;
		-u|--update)
			UPDATE_MODE="true"
			;;
		-t|--test=*)
			fetch_arg_value "SPECIFIED_TESTS_PATTERN" "-t" "--test" "test name"
			SPECIFIC_TESTS="true"
			;;
		-m|--model-solution=*)
			fetch_arg_value "model_solution" "-m" "--model-solution" "solution path"
			;;
		-d|--gen-data=*)
			fetch_arg_value "gen_data_file" "-d" "--gen-data" "gen data path"
			;;
		--tests-dir=*)
			fetch_arg_value "tests_dir" "-@" "--tests-dir" "tests directory path"
			;;
		--no-gen)
			SKIP_GEN="true"
			;;
		--no-sol)
			SKIP_SOL="true"
			;;
		--no-val)
			SKIP_VAL="true"
			;;
		--no-sol-compile)
			skip_compile_sol="true"
			;;
		*)
			invalid_arg "undefined option"
			;;
	esac
}

function handle_positional_arg {
	invalid_arg "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "$@"

if ! "${SKIP_SOL}"; then
	if [ -z "${model_solution}" ]; then
		model_solution="$(sensitive get_model_solution)"
	fi

	sensitive check_file_exists "Solution file" "${model_solution}"
fi


sensitive check_file_exists "Generation data file" "${gen_data_file}"

command_exists dos2unix || cecho yellow "WARNING: dos2unix is not available. Line endings might be incorrect."

export SENSITIVE_RUN WARNING_SENSITIVE_RUN UPDATE_MODE SPECIFIC_TESTS SPECIFIED_TESTS_PATTERN SKIP_GEN SKIP_SOL SKIP_VAL


recreate_dir "${LOGS_DIR}"

export STATUS_PAD=20

printf "%-${STATUS_PAD}scompile" "generator"
if "${SKIP_GEN}"; then
	echo_status "SKIP"
else
	sensitive reporting_guard "generators.compile" build_with_make "${GEN_DIR}"
fi
echo

printf "%-${STATUS_PAD}scompile" "validator"
if "${SKIP_VAL}"; then
	echo_status "SKIP"
else
	sensitive reporting_guard "validators.compile" build_with_make "${VALIDATOR_DIR}"
fi
echo

printf "%-${STATUS_PAD}scompile" "solution"
if "${SKIP_SOL}" || "${skip_compile_sol}"; then
	echo_status "SKIP"
else
	sensitive reporting_guard "solution.compile" bash "${INTERNALS}/compile_solution.sh" "${model_solution}"
fi
echo

if "${UPDATE_MODE}" || "${SKIP_GEN}"; then
	cecho yellow "Warning: tests directory is not cleared."
else
	recreate_dir "${tests_dir}"
fi

ret=0
"${PYTHON}" "${INTERNALS}/gen.py" "${gen_data_file}" "${tests_dir}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
	cecho success "Finished."
else
	cecho fail "Terminated."
fi

exit ${ret}
