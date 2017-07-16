#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"
source "${internals}/problem_util.sh"


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


gen_data_file="${gen_dir}/data"
show_reason="false"
sensitive_run="false"
singular_test="false"
sole_test_name=""
skip_check="false"
skip_compile_sol="false"


function handle_option {
    shifts=0
    case "${curr}" in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--test=*)
            fetch_arg_value "sole_test_name" "-t" "--test" "test name"
            singular_test="true"
            ;;
        -s|--sensitive)
            sensitive_run="true"
            ;;
        -d|--gen-data=*)
            fetch_arg_value "gen_data_file" "-d" "--gen-data" "gen data path"
            ;;
        -r|--show-reason)
            show_reason="true"
            ;;
        --no-sol-compile)
            skip_compile_sol="true"
            ;;
        --no-check)
            skip_check="true"
            ;;
        --time-limit=*)
            fetch_arg_value "soft_tl" "-@" "--time-limit" "soft time limit"
            ;;
        --hard-time-limit=*)
            fetch_arg_value "hard_tl" "-@" "--hard-time-limit" "hard time limit"
            ;;
        --no-tle)
            soft_tl=$((24*60*60))
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

if [ -z "${soft_tl+x}" ]; then
    soft_tl="$(get_time_limit)"
fi

if ! check_float "${soft_tl}"; then
    errcho "Provided time limit '${soft_tl}' is not a positive real number"
    usage
    exit 2
fi

if [ -z "${hard_tl+x}" ]; then
    hard_tl="$(python -c "print(${soft_tl} + 2)")"
fi

if ! check_float "${hard_tl}"; then
    errcho "Provided hard time limit '${hard_tl}' is not a positive real number"
    usage
    exit 2
fi

sensitive check_file_exists "Solution file" "${solution}"

sensitive check_file_exists "Generation data file" "${gen_data_file}"

export show_reason sensitive_run singular_test sole_test_name skip_check soft_tl hard_tl


recreate_dir "${logs_dir}"

export status_pad=20

printf "%-${status_pad}scompile" "solution"
if "${skip_compile_sol}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "solution.compile" bash "${scripts}/compile.sh" "${solution}"
fi
echo

printf "%-${status_pad}scompile" "checker"
if "${skip_check}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "checker.compile" make -C "${checker_dir}"
fi
echo

ret=0
python "${internals}/invoke.py" < "${gen_data_file}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
    cecho green "Finished."
else
    cecho red "Terminated."
fi

exit ${ret}
