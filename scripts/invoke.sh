#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"


function usage {
	errcho "Usage: <invoke> [options] <solution-path>"
	errcho "Options:"
	errcho -e "  -h, --help"
	errcho -e "  -s, --sensitive"
	errcho -e "\tTerminates on the first error."
	errcho -e "  -r, --show-reason"
	errcho -e "\tDisplays the reason for not being accepted, e.g. checker output"
	errcho -e "  -t, --test=<test-name>"
	errcho -e "  -d, --gen-data=<gen-data-file>"
	errcho -e "      --no-check"
	errcho -e "      --no-sol-compile"
	errcho -e "      --no-tle"
	errcho -e "      --time-limit=<time-limit>"
	errcho -e "\tGiven in seconds, e.g. --time-limit=1.2 means 1.2 seconds"
	errcho -e "      --hard-time-limit=<hard-time-limit>"
	errcho -e "\tSolution code will be killed after <hard-time-limit> seconds,"
	errcho -e "\t\tdefaults to <time-limit> + 2"
}


gen_data_file="${GEN_DIR}/data"
SHOW_REASON="false"
SENSITIVE_RUN="false"
SINGULAR_TEST="false"
SOLE_TEST_NAME=""
SKIP_CHECK="false"
skip_compile_sol="false"


function handle_option {
    shifts=0
    case "${curr}" in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--test=*)
            fetch_arg_value "SOLE_TEST_NAME" "-t" "--test" "test name"
            SINGULAR_TEST="true"
            ;;
        -s|--sensitive)
            SENSITIVE_RUN="true"
            ;;
        -d|--gen-data=*)
            fetch_arg_value "gen_data_file" "-d" "--gen-data" "gen data path"
            ;;
        -r|--show-reason)
            SHOW_REASON="true"
            ;;
        --no-sol-compile)
            skip_compile_sol="true"
            ;;
        --no-check)
            SKIP_CHECK="true"
            ;;
        --time-limit=*)
            fetch_arg_value "SOFT_TL" "-@" "--time-limit" "soft time limit"
            ;;
        --hard-time-limit=*)
            fetch_arg_value "HARD_TL" "-@" "--hard-time-limit" "hard time limit"
            ;;
        --no-tle)
            SOFT_TL=$((24*60*60))
            ;;
        *)
            invalid_arg "undefined option"
            ;;
    esac
}

function handle_positional_arg {
    if [ -z "${solution+x}" ]; then
        solution="${curr}"
        return
    fi
    invalid_arg "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "$@"

if [ -z "${solution+x}" ]; then
    errcho "Solution is not specified."
    usage
    exit 2
fi

if ! python -c "import psutil" >/dev/null 2>/dev/null; then
    errcho "Error: Package 'psutil' is not installed. You can install it using:"
    errcho "pip install psutil"
    exit 1
fi

if [ -z "${SOFT_TL+x}" ]; then
    SOFT_TL="$(get_time_limit)"
fi

if ! check_float "${SOFT_TL}"; then
    errcho "Provided time limit '${SOFT_TL}' is not a positive real number"
    usage
    exit 2
fi

if [ -z "${HARD_TL+x}" ]; then
    HARD_TL="$(python -c "print(${SOFT_TL} + 2)")"
fi

if ! check_float "${HARD_TL}"; then
    errcho "Provided hard time limit '${HARD_TL}' is not a positive real number"
    usage
    exit 2
fi

sensitive check_file_exists "Solution file" "${solution}"

sensitive check_file_exists "Generation data file" "${gen_data_file}"

export SHOW_REASON SENSITIVE_RUN SINGULAR_TEST SOLE_TEST_NAME SKIP_CHECK SOFT_TL HARD_TL


recreate_dir "${LOGS_DIR}"

export STATUS_PAD=20

printf "%-${STATUS_PAD}scompile" "solution"
if "${skip_compile_sol}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "solution.compile" bash "${SCRIPTS}/compile.sh" "${solution}"
fi
echo

printf "%-${STATUS_PAD}scompile" "checker"
if "${SKIP_CHECK}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "checker.compile" make -C "${CHECKER_DIR}"
fi
echo

ret=0
python "${INTERNALS}/invoke.py" < "${gen_data_file}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
    cecho green "Finished."
else
    cecho red "Terminated."
fi

exit ${ret}
