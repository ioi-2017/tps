#!/bin/bash


function get_model_solution {
    model_solution_name="$(python "${internals}/get_model_solution.py")" || return $?
    echo "${solution_dir}/${model_solution_name}"
}

function get_time_limit {
    python "${internals}/json_extract.py" "${problem_json}" "time_limit"
}

function get_test_validators {
    test_name="$1"
    python "${internals}/get_test_validators.py" "${test_name}" "${mapping_file}"
}

function get_test_validator_executables {
    test_name="$1"
    validators="$(get_test_validators "${test_name}")" || return $?
    validator_executables="$(
        echo "${validators}" | while read validator_name; do
            [ -z "${validator_name}" ] && continue
            validator_executable="${validator_name%.*}.exe"

            if [ ! -x "${validator_dir}/${validator_executable}" ]; then
                errcho "validator '${validator_executable}' not found."
                return 4
            fi
            echo "${validator_dir}/${validator_executable}"
        done
    )" || return $?
    echo "${validator_executables}"
}