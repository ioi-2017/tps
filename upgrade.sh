#!/bin/bash

set -euo pipefail

function errcho {
    >&2 echo "$@"
}

function recreate_dir {
    dir=$1
    mkdir -p "${dir}"
    ls -A1 "${dir}" | while read file; do
        [ -z "${file}" ] && continue
        rm -rf "${dir}/${file}"
    done
}

function usage {
	errcho "Usage: upgrade.sh <problem-dir>"
	exit 2
}

[ $# -eq 1 ] || usage

problem_dir="$1"
problem_scripts="${problem_dir}/scripts"
source_current_scripts="scripts"
old_scripts="old"
problem_old_scripts_version_file="${problem_dir}/.scripts_version"
dry_run="false"


if [ -z "${problem_dir}" ]; then
    errcho "Problem directory is not specified."
    exit 2
fi

if [ ! -d "${problem_dir}" ]; then
    errcho "Problem directory '${problem_dir}' not found"
    exit 4
fi


if [ -f "${problem_old_scripts_version_file}" ]; then
    old_scripts_version="$(cat "${problem_old_scripts_version_file}")"
else
    old_scripts_version="$(git log --pretty=format:"%H" | tail -n 1)"
fi

if ! git show -s --oneline "${old_scripts_version}" > /dev/null; then
    errcho "Problem scripts version '${old_scripts_version}' not found in this source repo"
    exit 4
fi


function source_current_scripts_version {
    ret=0
    tag="$(git describe --tags | head -1)" || ret=$?
    if [ "${ret}" -eq 0 ]; then
        version="${tag}"
    else
        version="$(git log --pretty=format:'%H' -n 1)"
    fi
    echo "${version}"
}

function list_dir_files {
    dir="$1"
    pushd "${dir}" > /dev/null 2>&1
    find . -type f
    popd  > /dev/null 2>&1
}

function get_all_scripts_files {
    {
        list_dir_files "${source_current_scripts}"
        list_dir_files "${problem_scripts}"
    } | cut -d/ -f2- | sort | uniq
}

has_conflicts="false"
declare -a conflict_list
conflict_index=0

function push_conflict {
    status="FAIL"
    has_conflicts="true"
    conflict_list["${conflict_index}"]="$1"
    conflict_index=$((conflict_index + 1))
}

function do_action {
    if ! "${dry_run}"; then
        "$@"
    fi
}

recreate_dir "${old_scripts}"

get_all_scripts_files | while read file; do
    c="${problem_scripts}/${file}"
    b="${source_current_scripts}/${file}"
    a="${old_scripts}/${file}"

    a_exists="true"
    git show "${old_scripts_version}:${file}" > "${a}" || a_exists="false"

    b_exists="true"
    [ -f "${b}" ] || b_exists="false"

    c_exists="true"
    [ -f "${c}" ] || c_exists="false"

    status="OK"
    message=""
    if "${b_exists}"; then
        if "${c_exists}"; then
            if diff "${b}" "${c}"; then
                message="'${file}' is not changed"
            elif "${a_exists}" && diff "${a}" "${b}"; then
                message="keeping changes of '${file}' in problem"
            elif "${a_exists}" && diff "${a}" "${c}"; then
                message="applying changes to '${file}'"
                do_action cp "${b}" "${c}"
            else
                push_conflict "${file}"
                message="CONFLICT! both problem and script source changed '${file}'"
            fi
        else
            if ! "${a_exists}"; then
                message="new file '${file}' added"
                do_action mkdir -p "$(dirname "${c}")"
                do_action cp "${b}" "${c}"
            elif diff "${a}" "${b}"; then
                message="keeping file '${file}' deleted"
            else
                push_conflict "${file}"
                message="CONFLICT! file '${file}' which is deleted in problem has been updated"
            fi
        fi
    else
        if "${c_exists}"; then
            if ! "${a_exists}"; then
                message="keeping extra file '${file}' in problem"
            elif diff "${a}" "${c}"; then
                message="deleted file '${file}' because it is deleted in source"
                do_action rm -f "${c}"
            else
                push_conflict "${file}"
                message="CONFLICT! file '${file}' which is changed in problem has been deleted"
            fi
        else
            errcho "Unreachable code reached!"
            exit 1
        fi
    fi

    errcho -e "${file}:\t[${status}]\t${message}"
done

echo "$(source_current_scripts_version)" > "${problem_old_scripts_version_file}"

echo


if "${has_conflicts}"; then
    errcho "Please resolve the following conflicts now!"
    sleep 0.1
    for file in "${conflict_list[@]}"; do
        echo "${file}"
    done

    exit 10
fi