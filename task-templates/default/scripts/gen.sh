#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/gen_util.sh"
source "${INTERNALS}/invoke_util.sh"


function usage {
	errcho -ne "\
Usage:
  tps gen [options]

Description:
  Generates the test data.

Options:
\
  -h, --help
\tShows this help.
\
  -s, --sensitive
\tTerminates on the first error and shows the error details.
\
  -w, --warning-sensitive
\tTerminates on the first warning or error and shows the details.
\
  -u, --update
\tUpdates the existing set of tests.
\tPrevents the initial cleanup of the tests directory.
\tUsed when a subset of test data needs to be generated again.
\tWarning: Use this feature only when the other tests are not needed or already generated correctly.
\
  -t, --test=<test-name-pattern>
\tGenerates only tests matching the given pattern. Examples: 1-01, '1-*', '1-0?'
\tMultiple patterns can be given using commas or pipes. Examples: '1-01, 2-*', '?-01|*2|0-*'
\tNote: Use quotation marks or escaping (with '\\') when using wildcards in the pattern to prevent shell expansion.
\t      Also, use escaping (with '\\') when separating multiple patterns using pipes.
\
  -m, --model-solution=<model-solution-path>
\tGenerates test outputs using the given solution.
\
  -d, --gen-data=<gen-data-file>
\tOverrides the location of meta-data file used for test generation.
\
      --tests-dir=<tests-directory-path>
\tOverrides the location of the tests directory.
\
      --no-gen
\tSkips running the generators for generating test inputs.
\tPrevents the initial cleanup of the tests directory.
\tUsed when test inputs are already thoroughly generated and only test outputs need to be generated.
\
      --no-sol
\tSkips running the model solution for generating test outputs.
\
      --no-val
\tSkips validating test inputs.
\
      --no-sol-compile
\tSkips compiling the model solution.
\tUses the solution already compiled and available in the sandbox.
"
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
flag_for_not_recreating_tests_dir=""

function handle_option {
	local -r curr_arg="$1"; shift
	case "${curr_arg}" in
		-h|--help)
			usage_exit 0
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
			flag_for_not_recreating_tests_dir="${curr_arg}"
			;;
		-t|--test=*)
			fetch_nonempty_arg_value "SPECIFIED_TESTS_PATTERN" "-t" "--test" "test name pattern"
			SPECIFIC_TESTS="true"
			;;
		-m|--model-solution=*)
			fetch_nonempty_arg_value "model_solution" "-m" "--model-solution" "solution path"
			;;
		-d|--gen-data=*)
			fetch_nonempty_arg_value "gen_data_file" "-d" "--gen-data" "gen data path"
			;;
		--tests-dir=*)
			fetch_nonempty_arg_value "tests_dir" "-@" "--tests-dir" "tests directory path"
			;;
		--no-gen)
			SKIP_GEN="true"
			flag_for_not_recreating_tests_dir="${curr_arg}"
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
			invalid_arg_with_usage "${curr_arg}" "undefined option"
			;;
	esac
}

function handle_positional_arg {
	local -r curr_arg="$1"; shift
	invalid_arg_with_usage "${curr_arg}" "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "invalid_arg_with_usage" "$@"

if ! "${SKIP_SOL}"; then
	if [ -z "${model_solution}" ]; then
		model_solution="$(sensitive get_model_solution)"
	fi

	sensitive check_file_exists "Solution file" "${model_solution}"
fi


sensitive check_file_exists "Generation data file" "${gen_data_file}"


if [ -n "${flag_for_not_recreating_tests_dir}" -a ! -d "${tests_dir}" ]; then
	errcho "Error: tests directory '${tests_dir}' does not exist (needed due to flag '${flag_for_not_recreating_tests_dir}')."
	exit 3
fi


command_exists dos2unix || cecho yellow "WARNING: dos2unix is not available. Line endings might be incorrect."

export SENSITIVE_RUN WARNING_SENSITIVE_RUN UPDATE_MODE SPECIFIC_TESTS SPECIFIED_TESTS_PATTERN SKIP_GEN SKIP_SOL SKIP_VAL


recreate_dir "${LOGS_DIR}"

export STATUS_PAD=20

compile_generators_if_needed

compile_validators_if_needed

skipping_compile_sol="$(str_or "${SKIP_SOL}" "${skip_compile_sol}")"
compile_solution_if_needed "${skipping_compile_sol}" "solution.compile" "solution" "${model_solution}"

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
