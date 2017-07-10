#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"
source "${internals}/problem_util.sh"

test_name="$1"; shift
command="$1"; shift
args="$@"

input="${tests_dir}/${test_name}.in"
output="${tests_dir}/${test_name}.out"

function gen_input {
    if [ "${command}" == "manual" ]; then
        cat "${gen_dir}/manual/${args}" > "${input}"
    else
        "${gen_dir}/${command}.exe" ${args} > "${input}"
    fi
}

function gen_output {
    if [ ! -f "${input}" ]; then
        errcho "input file ${test_name}.in is not available"
        return 4
    fi
    bash "${scripts}/run.sh" < "${input}" > "${output}"
}

function validate {
    if [ ! -f "${input}" ]; then
        errcho "input file ${test_name}.in is not available"
        return 4
    fi

    validators="$(get_test_validator_executables "${test_name}")" || return $?
    echo "${validators}" | while read validator; do
        [ -z "${validator}" ] && continue
        errcho "started $(basename ${validator}):"
        "${validator}" < "${input}" || return $?
        errcho "OK"
    done
}


printf "%-${status_pad}s" "${test_name}"

failed_jobs=""
final_ret=0


export box_padding=7

echo -n "gen"
gen_job="${test_name}.gen"

if ! "${skip_gen}"; then
    insensitive guard "${gen_job}" gen_input
    ret=$(job_ret "${gen_job}")

    if [ ${ret} -ne 0 ]; then
        final_ret=${ret}
        failed_jobs="${failed_jobs} ${gen_job}"
    fi
fi

gen_status=$(job_status "${gen_job}")
echo_status "${gen_status}"


echo -n "sol"
sol_job="${test_name}.sol"

if ! "${skip_sol}" && ! is_in "${gen_status}" "FAIL"; then
    insensitive guard "${sol_job}" gen_output
    ret=$(job_ret "${sol_job}")

    if [ ${ret} -ne 0 ]; then
        final_ret=${ret}
        failed_jobs="${failed_jobs} ${sol_job}"
    fi
fi

sol_status=$(job_status "${sol_job}")
echo_status "${sol_status}"


echo -n "val"
val_job="${test_name}.val"

if ! "${skip_val}" && ! is_in "${gen_status}" "FAIL"; then
    insensitive guard "${val_job}" validate
    ret=$(job_ret "${val_job}")

    if [ ${ret} -ne 0 ]; then
        final_ret=${ret}
        failed_jobs="${failed_jobs} ${val_job}"
    fi
fi

val_status=$(job_status "${val_job}")
echo_status "${val_status}"

echo


if "${sensitive_run}"; then
    if [ ${final_ret} -ne 0 ]; then
        for job in ${failed_jobs}; do
            echo
            echo "failed job: ${job}"
            execution_report "${job}"
        done

        exit ${final_ret}
    fi
fi