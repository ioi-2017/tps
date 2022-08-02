#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"
source "${INTERNALS}/gen_util.sh"
source "${INTERNALS}/invoke_util.sh"


function usage {
	errcho -ne "\
Usage:
  tps stress [options] <solution-file> <test-case-generation-file-path|test-case-generation-format-string>

Description:
  Puts <solution-file> under stress testing.
  More specifically, it runs the solution against a series of (randomly) generated test cases
   in order to find a test case for which the solution fails, or so called, is \"hacked\".
  In each round, a \"test case generation string\" is first produced
   by either <test-case-generation-file-path> or <test-case-generation-format-string>.
  This string is a single-line text similar to the test generation lines in file 'gen/data'.
  The test case input is then generated from the test case generation string.
  In addition to the presentations in the standard output,
   test case generation strings by which the solution is hacked
   are written into 'logs/hacked.txt' too.

<solution-file>:
  Path of the solution file to be stressed.

<test-case-generation-file-path>:
  Path of a python file which produces the test case generation strings.
  The python file must implement a function 'gen_command' that gets no arguments as input.
  Upon each call, this function must return a test case generation string.
  Here is an example of a test case generation file:
---------------------------- begin example ----------------------------
from stress_test_gen_utils import *

def gen_command():
    return \"gen 100 {} {}\".format(random.randint(1, 100), ustr(8, 10))
----------------------------- end example -----------------------------
  The module 'stress_test_gen_utils' (located at 'scripts/templates/stress_test_gen_utils.py')
   is available for the test case generation file for importing
   and provides utilities such as 'ustr' (and also imports the module 'random').

<test-case-generation-format-string>:
  A general string used for producing test case generation strings.
  The string must be in the shape of a format string in python.
  Upon each evaluation, the format string must produce a test case generation string.
  Example:
    \"gen 100 {random.randint(1, 100)} {ustr(8, 10)}\"
  The elements of the module 'stress_test_gen_utils' (and thus also the module 'random')
   are automatically imported when evaluating the format string.
  For using other modules in the format string,
    the option -i/--import can be used (for multiple times).
  Here is an example:
    tps stress \"solution/x.cpp\" -i math --import string \\
               \"gen 100 {math.factorial(random.randint(1, 5))} {ustr(7, 13, string.ascii_uppercase)}\"
  Limitations:
  * This feature requires python 3.6+
  * Triple-apostrophes (''') are not allowed in the format string
    (due to the issues in the current version of implementation).

The second positional argument will be interpreted as <test-case-generation-file-path>
 if an ordinary file exists with the same path as that argument.
Otherwise, it will be interpreted as <test-case-generation-format-string>.
In a rare case that a <test-case-generation-format-string>
 happens to be also the path to an existing ordinary file,
 a simple work around can be changing the format string \"the-path-to-some-file\"
 to something like \"{ 'the-path-to-some-file' }\".

Options:
\
  -h, --help
\tShows this help.
\
  -s, --sensitive
\tTerminates on the first unexpected error and shows the error details.
\
  -w, --warning-sensitive
\tTerminates on the first warning or error and shows the details.
\
  -k, --hack-sensitive
\tTerminates on the first hacking test case.
\
  -m, --model-solution=<model-solution-path>
\tGenerates test outputs using the given solution.
\
  -r, --rounds=<number-of-rounds>
\tThe number of tests to generate to stress the solution.
\tIf not specified, the stress process continues infinitely.
\
  -i, --import <python-module-name>
\tImports the given module and makes it available
\t to be used during the evaluation of <test-case-generation-format-string>.
\tThis option can be used for multiple times.
\tThis option has no effect if a <test-case-generation-file-path>
\t is given instead of a <test-case-generation-format-string>.
\
      --seed=<random-seed>
\tThe random seed given to the python module 'random'
\t for producing the test case generation strings.
\tIf the seed option is not given,
\t no seed will be set and the module 'random' will have its default behavior.
\tThe seed can be any string.
\tThis seed does not have any effect on the generation of the test case inputs.
\
      --no-val
\tSkips validating test inputs.
\
      --no-sol-compile
\tSkips compiling the model & stressed solutions.
\
      --no-model
\tSkips running the model on the test.
\tThe checker should be able to work without having the correct answer.
\
      --no-check
\tSkips running the checker on the outputs of the stressed solution.
\
      --no-tle
\tRemoves the default time limit on the execution of the solution.
\tActually, a limit of 24 hours is applied.
\
      --time-limit=<time-limit>
\tOverrides the (soft) time limit on the solution execution.
\tGiven in seconds, e.g. --time-limit=1.2 means 1.2 seconds
\
      --hard-time-limit=<hard-time-limit>
\tSolution process will be killed after <hard-time-limit> seconds.
\tDefaults to <time-limit> + 2.
\tNote: The hard time limit must be greater than the (soft) time limit.
\
      --min-score=<min-score>
\tMinimum value as a valid score.
\tGiven as a decimal value, typically in the range [0, 1].
\tThis option is generally used in tasks with partial scoring.
\tDefault value is 1.
"
}


model_solution=""
SENSITIVE_RUN="false"
WARNING_SENSITIVE_RUN="false"
HACK_SENSITIVE="false"
SKIP_GEN="false"
SKIP_VAL="false"
skip_compile_sol="false"
SKIP_MODEL="false"
SKIP_CHECK="false"
MODULES_TO_IMPORT=""
unset GEN_STR_RAND_SEED

SANDBOX_ROOT="${SANDBOX}"
SANDBOX_MODEL="${SANDBOX}/model"
SANDBOX_STRESSED="${SANDBOX}/stressed"
SANDBOX_GEN="${SANDBOX}/test_gen"
unset SANDBOX

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
		-k|--hack-sensitive)
			HACK_SENSITIVE="true"
			;;
		-m|--model-solution=*)
			fetch_arg_value "model_solution" "-m" "--model-solution" "solution path"
			;;
		-r|--rounds=*)
			fetch_arg_value "num_rounds" "-r" "--rounds" "number of rounds"
			;;
		-i|--import)
			a_module_name=""
			fetch_next_arg "a_module_name" "-i" "--import" "module name"
			MODULES_TO_IMPORT="${MODULES_TO_IMPORT} ${a_module_name}"
			;;
		--seed=*)
			fetch_arg_value "GEN_STR_RAND_SEED" "-@" "--seed" "random seed"
			;;
		--no-val)
			SKIP_VAL="true"
			;;
		--no-sol-compile)
			skip_compile_sol="true"
			;;
		--no-model)
			SKIP_MODEL="true"
			;;
		--no-check)
			SKIP_CHECK="true"
			;;
		--no-tle)
			SOFT_TL=$((24*60*60))
			;;
		--time-limit=*)
			fetch_arg_value "SOFT_TL" "-@" "--time-limit" "soft time limit"
			;;
		--hard-time-limit=*)
			fetch_arg_value "HARD_TL" "-@" "--hard-time-limit" "hard time limit"
			;;
		--min-score=*)
			fetch_arg_value "MIN_SCORE" "-@" "--min-score" "minimum valid score"
			;;
		*)
			invalid_arg_with_usage "${curr_arg}" "undefined option"
			;;
	esac
}

function handle_positional_arg {
	local -r curr_arg="$1"; shift
	if variable_not_exists "stressed_solution" ; then
		stressed_solution="${curr_arg}"
		return
	fi
	if variable_not_exists "test_gen_arg" ; then
		test_gen_arg="${curr_arg}"
		return
	fi
	invalid_arg_with_usage "${curr_arg}" "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "invalid_arg_with_usage" "$@"


variable_exists "stressed_solution" ||
	error_usage_exit 2 "The stressed solution file is not specified."

variable_exists "test_gen_arg" ||
	error_usage_exit 2 "The test case generation file/format-string is not specified."

check_invoke_prerequisites

check_and_init_limit_variables

if variable_exists "num_rounds" ; then
	is_unsigned_integer_format "${num_rounds}" ||
		error_usage_exit 2 "Provided number of rounds '${num_rounds}' is not a nonnegative integer value."
else
	num_rounds="-1"
fi

if variable_exists "MIN_SCORE" ; then
	is_signed_decimal_format "${MIN_SCORE}" ||
		error_usage_exit 2 "Provided value as the minimum of score '${MIN_SCORE}' is not a valid decimal value."
else
	MIN_SCORE="1"
fi

if ! "${SKIP_MODEL}"; then
	[ -n "${model_solution}" ] ||
		model_solution="$(sensitive get_model_solution)"
	sensitive check_file_exists "Model solution file" "${model_solution}"
fi

sensitive check_file_exists "Stressed solution file" "${stressed_solution}"

if [ -f "${test_gen_arg}" ]; then
	readonly test_gen_arg_is_file="true"
	readonly given_test_gen_python_file_path="${test_gen_arg}"
	[[ "${given_test_gen_python_file_path}" == *py ]] ||
		error_usage_exit 2 "Provided test case generation file '${given_test_gen_python_file_path}' is not a python program."
else
	readonly test_gen_arg_is_file="false"
	readonly given_test_gen_format_string="${test_gen_arg}"
fi

if "${skip_compile_sol}"; then
	"${SKIP_MODEL}" ||
		check_directory_exists "Compilation directory for model solution" "${SANDBOX_MODEL}"
	check_directory_exists "Compilation directory for stressed solution" "${SANDBOX_STRESSED}"
else
	recreate_dir "${SANDBOX_ROOT}"
fi

export SANDBOX_ROOT SANDBOX_MODEL SANDBOX_STRESSED SANDBOX_GEN \
	SENSITIVE_RUN WARNING_SENSITIVE_RUN HACK_SENSITIVE \
	MODULES_TO_IMPORT \
	SKIP_VAL SKIP_MODEL SKIP_CHECK SOFT_TL HARD_TL MIN_SCORE

variable_not_exists "GEN_STR_RAND_SEED" ||
	export GEN_STR_RAND_SEED

recreate_dir "${LOGS_DIR}"

export STATUS_PAD=20

recreate_dir "${SANDBOX_GEN}"

if "${test_gen_arg_is_file}"; then
	readonly given_test_gen_python_file_basename="$(basename "${given_test_gen_python_file_path}")"
	readonly target_test_gen_python_file_path="${SANDBOX_GEN}/${given_test_gen_python_file_basename}"
	function copy_test_gen_python_file {
		cp "${given_test_gen_python_file_path}" "${target_test_gen_python_file_path}"
	}
	printf "%-${STATUS_PAD}s%s" "test-gen-file" "copy"
	sensitive reporting_guard "test-gen-file.copy" copy_test_gen_python_file
	echo
else
	readonly source_test_gen_python_file_path="${TEMPLATES}/stress_gen_command_with_fstring.py"
	readonly target_test_gen_python_file_path="${SANDBOX_GEN}/gen_command_with_fstring.py"
	export TEST_GEN_FORMAT_STRING="${given_test_gen_format_string}"
	function create_test_gen_python_file {
		cp "${source_test_gen_python_file_path}" "${target_test_gen_python_file_path}"
	}
	printf "%-${STATUS_PAD}s%s" "test-gen-file" "create"
	sensitive reporting_guard "test-gen-file.create" create_test_gen_python_file
	echo
fi

function verify_test_gen_python_file {
	"${PYTHON}" "${INTERNALS}/stress.py" "verify" "${target_test_gen_python_file_path}"
}
printf "%-${STATUS_PAD}s%s" "test-gen-file" "verify"
sensitive reporting_guard "test-gen-file.verify" verify_test_gen_python_file
echo

compile_generators_if_needed

compile_validators_if_needed

skipping_compile_model="$(str_or "${SKIP_MODEL}" "${skip_compile_sol}")"
export SANDBOX="${SANDBOX_MODEL}"
compile_solution_if_needed "${skipping_compile_model}" "model-solution.compile" "model solution" "${model_solution}"
unset SANDBOX

export SANDBOX="${SANDBOX_STRESSED}"
compile_solution_if_needed "${skip_compile_sol}" "stressed-solution.compile" "stressed solution" "${stressed_solution}"
unset SANDBOX

compile_checker_if_needed

ret=0
"${PYTHON}" "${INTERNALS}/stress.py" "${num_rounds}" "${target_test_gen_python_file_path}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
	cecho success "Finished."
else
	cecho fail "Terminated."
fi

exit ${ret}
