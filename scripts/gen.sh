#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"
source "${internals}/problem_util.sh"


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
gen_data_file="${gen_dir}/data"
sensitive_run="false"
singular_test="false"
sole_test_name=""
skip_gen="false"
skip_sol="false"
skip_val="false"
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
        -m|--model-solution=*)
            fetch_arg_value "model_solution" "-m" "--model-solution" "solution path"
            ;;
        -s|--sensitive)
            sensitive_run="true"
            ;;
        -d|--gen-data=*)
            fetch_arg_value "gen_data_file" "-d" "--gen-data" "gen data path"
            ;;
        --no-sol-compile)
            skip_compile_sol="true"
            ;;
        --no-gen)
            skip_gen="true"
            ;;
        --no-sol)
            skip_sol="true"
            ;;
        --no-val)
            skip_val="true"
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


if [ -z "${model_solution}" ]; then
    model_solution="$(sensitive get_model_solution)"
fi

sensitive check_file_exists "Solution file" "${model_solution}"

sensitive check_file_exists "Generation data file" "${gen_data_file}"

export sensitive_run singular_test sole_test_name skip_gen skip_sol skip_val


recreate_dir "${logs_dir}"

export status_pad=20

printf "%-${status_pad}scompile" "generator"
if "${skip_gen}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "generators.compile" make -C "${gen_dir}"
fi
echo

printf "%-${status_pad}scompile" "solution"
if "${skip_sol}" || "${skip_compile_sol}";  then
    echo_status "SKIP"
else
    sensitive reporting_guard "solution.compile" bash "${scripts}/compile.sh" "${model_solution}"
fi
echo

printf "%-${status_pad}scompile" "validator"
if "${skip_val}"; then
    echo_status "SKIP"
else
    sensitive reporting_guard "validators.compile" make -C "${validator_dir}"
fi
echo

# TODO confirm
if ! "${skip_gen}"; then
    recreate_dir "${tests_dir}"
fi

ret=0
python "${internals}/gen.py" "${mapping_file}" < "${gen_data_file}" || ret=$?


echo

if [ ${ret} -eq 0 ]; then
    cecho green "Finished."
else
    cecho red "Terminated."
fi

exit ${ret}