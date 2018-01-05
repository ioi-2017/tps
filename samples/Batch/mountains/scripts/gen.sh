#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"
source "${INTERNALS}/problem_util.sh"


function usage {
	errcho "Usage: <gen> [options]"
	errcho "Options:"
	errcho -e "  -h, --help"
	errcho -e "  -s, --sensitive"
	errcho -e "\tTerminates on the first error."
	errcho -e "  -m, --model-solution=<model-solution-path>"
	errcho -e "  -t, --test=<test-name>"
	errcho -e "  -d, --gen-data=<gen-data-file>"
	errcho -e "      --no-gen"
	errcho -e "      --no-sol"
	errcho -e "      --no-val"
	errcho -e "      --no-sol-compile"
}


model_solution=""
gen_data_file="${GEN_DIR}/data"
SENSITIVE_RUN="false"
SINGULAR_TEST="false"
SOLE_TEST_NAME=""
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
        -t|--test=*)
            fetch_arg_value "SOLE_TEST_NAME" "-t" "--test" "test name"
            SINGULAR_TEST="true"
            ;;
        -m|--model-solution=*)
            fetch_arg_value "model_solution" "-m" "--model-solution" "solution path"
            ;;
        -s|--sensitive)
            SENSITIVE_RUN="true"
            ;;
        -d|--gen-data=*)
            fetch_arg_value "gen_data_file" "-d" "--gen-data" "gen data path"
            ;;
        --no-sol-compile)
            skip_compile_sol="true"
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

export SENSITIVE_RUN SINGULAR_TEST SOLE_TEST_NAME SKIP_GEN SKIP_SOL SKIP_VAL


recreate_dir "${LOGS_DIR}"

export STATUS_PAD=20

printf "%-${STATUS_PAD}scompile" "generator"
if "${SKIP_GEN}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "generators.compile" make -C "${GEN_DIR}"
fi
echo

printf "%-${STATUS_PAD}scompile" "solution"
if "${SKIP_SOL}" || "${skip_compile_sol}";  then
    echo_status "SKIP"
else
    sensitive reporting_guard "solution.compile" bash "${SCRIPTS}/compile.sh" "${model_solution}"
fi
echo

printf "%-${STATUS_PAD}scompile" "validator"
if "${SKIP_VAL}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "validators.compile" make -C "${VALIDATOR_DIR}"
fi
echo

# TODO confirm
if ! "${SKIP_GEN}"; then
    recreate_dir "${TESTS_DIR}"
fi

ret=0
python "${INTERNALS}/gen.py" "${MAPPING_FILE}" < "${gen_data_file}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
    cecho green "Finished."
else
    cecho red "Terminated."
fi

exit ${ret}
