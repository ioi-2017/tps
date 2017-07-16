#!/bin/bash


function get_model_solution {
    model_solution_name="$(python "${INTERNALS}/get_model_solution.py")" || return $?
    echo "${SOLUTION_DIR}/${model_solution_name}"
}

function get_time_limit {
    python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "time_limit"
}

function get_test_validators {
    test_name="$1"
    python "${INTERNALS}/get_test_validators.py" "${test_name}" "${MAPPING_FILE}"
}

function get_test_validator_executables {
    test_name="$1"
    validators="$(get_test_validators "${test_name}")" || return $?
    validator_executables="$(
        echo "${validators}" | while read validator_name; do
            [ -z "${validator_name}" ] && continue
            validator_executable="${validator_name%.*}.exe"

            if [ ! -x "${VALIDATOR_DIR}/${validator_executable}" ]; then
                errcho "validator '${validator_executable}' not found."
                return 4
            fi
            echo "${VALIDATOR_DIR}/${validator_executable}"
        done
    )" || return $?
    echo "${validator_executables}"
}