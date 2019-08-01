#!/bin/bash

set -euo pipefail

export INTERNALS="scripts/internal"

source "${INTERNALS}/util.sh"

function usage {
	errcho "Usage: upgrade-scripts.sh [options] <problem-dir>"
	errcho "Options:"
	errcho -e "  -h, --help"
	errcho -e "  -d, --dry"
}


dry_run="false"

function handle_option {
    shifts=0
    case "${curr}" in
        -h|--help)
            usage
            exit 0
            ;;
        -d|--dry)
            dry_run="true"
            ;;
        *)
            invalid_arg "undefined option"
            ;;
    esac
}

function handle_positional_arg {
    if [ -z "${problem_dir+x}" ]; then
        problem_dir="${curr}"
        return
    fi
    invalid_arg "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "$@"


if [ -z "${problem_dir+x}" ]; then
    cecho red >&2 "Problem directory is not specified."
    usage
    exit 2
fi

if [ ! -d "${problem_dir}" ]; then
    cecho red >&2 "Problem directory '${problem_dir}' not found"
    exit 4
fi


problem_scripts="${problem_dir}/scripts"
source_scripts="scripts"
old_scripts="old"
problem_old_scripts_version_file="${problem_dir}/.scripts_version"


if [ -f "${problem_old_scripts_version_file}" ]; then
    old_scripts_version="$(cat "${problem_old_scripts_version_file}")"
else
    old_scripts_version="$(git log --pretty=format:"%H" | tail -n 1)"
fi

if ! git show -s --oneline "${old_scripts_version}" > /dev/null; then
    cecho red >&2 "Problem scripts version '${old_scripts_version}' not found in this source repo"
    exit 4
fi


function check_repo_is_clean {
    dir="$1"
    pushd "${dir}" > /dev/null 2>&1 || exit 1
    ret=0
    if [ -n "$(git status --porcelain)" ]; then
        ret=1
    fi
    popd > /dev/null 2>&1
    return ${ret}
}

if ! check_repo_is_clean "$(dirname ${problem_scripts})"; then
    cecho red >&2 "There are uncommitted changes in problem repo"
    read -p "Are you sure you want to proceed? [y/N]" res
    if [ "${res}" != "y" ]; then
        exit 1
    else
        echo
    fi
fi

if ! check_repo_is_clean "$(dirname ${source_scripts})"; then
    cecho red >&2 "There are uncommitted changes in source scripts repo"
    read -p "Are you sure you want to proceed? [y/N]" res
    if [ "${res}" != "y" ]; then
        exit 1
    else
        echo
    fi
fi

ret=0
tag="$(git describe --tags | head -1)" || ret=$?
if [ "${ret}" -eq 0 ]; then
    source_current_scripts_version="${tag}"
else
    source_current_scripts_version="$(git log --pretty=format:'%H' -n 1)"
fi

function list_dir_files {
    dir="$1"
    pushd "${dir}" > /dev/null 2>&1 || exit 1
    git ls-files | while read file; do
        [ -f "${file}" ] && echo "${file}"
    done
    popd  > /dev/null 2>&1
}

function get_all_scripts_files {
    {
        list_dir_files "${source_scripts}"
        list_dir_files "${problem_scripts}"
    } | sort | uniq
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
        status="FAIL"
        ret=0
        "$@" || ret=$?
        if [ ${ret} -eq 0 ]; then
            changed="true"
            status="OK"
        fi
        return ${ret}
    fi
}

recreate_dir "${old_scripts}"

while read file; do
    c="${problem_scripts}/${file}"
    b="${source_scripts}/${file}"
    a="${old_scripts}/${file}"

    a_exists="true"
    mkdir -p "$(dirname "${a}")"
    git show "${old_scripts_version}:${source_scripts}/${file}" > "${a}" 2> /dev/null || a_exists="false"

    b_exists="true"
    [ -f "${b}" ] || b_exists="false"

    c_exists="true"
    [ -f "${c}" ] || c_exists="false"

    changed="false"
    status="OK"
    "${dry_run}" && status="SKIP"
    message=""
    if "${b_exists}"; then
        if "${c_exists}"; then
            if are_same "${b}" "${c}"; then
                message="not changed"
            elif "${a_exists}" && are_same "${a}" "${b}"; then
                message="keeping changes in problem"
            elif "${a_exists}" && are_same "${a}" "${c}"; then
                message="applying changes in problem"
                do_action cp "${b}" "${c}"
            else
                push_conflict "${file}"
                message="CONFLICT! both problem and script source changed this file"
            fi
        else
            if ! "${a_exists}"; then
                message="added as new file"
                do_action mkdir -p "$(dirname "${c}")"
                do_action cp "${b}" "${c}"
            elif are_same "${a}" "${b}"; then
                message="keeping deleted"
            else
                push_conflict "${file}"
                message="CONFLICT! deleted file in problem has been updated"
            fi
        fi
    else
        if "${c_exists}"; then
            if ! "${a_exists}"; then
                message="keeping extra file in problem"
            elif are_same "${a}" "${c}"; then
                message="file deleted because it is deleted in source"
                do_action rm -f "${c}"
            else
                push_conflict "${file}"
                message="CONFLICT! changed file in problem has been deleted"
            fi
        else
            cecho red >&2 "Unreachable code reached!"
            exit 1
        fi
    fi

    printf >&2 "%-40s" "${file}"
    BOX_PADDING=10
    echo_status "${status}"
    if "${changed}"; then
        cecho yellow >&2 "${message}"
    else
        errcho "${message}"
    fi
done <<< "$(get_all_scripts_files)"

if ! "${dry_run}"; then
    errcho

    do_update_version="true"
    if "${has_conflicts}"; then
        do_update_version="false"
        read -p "There are some conflicts. Should the .scripts_version file be updated? [y/N]" res
        if [ "${res}" == "y" ]; then
            do_update_version="true"
        fi
    fi
    if "${do_update_version}"; then
        echo "${source_current_scripts_version}" > "${problem_old_scripts_version_file}"
        cecho yellow "updated .script_version file in problem to '${source_current_scripts_version}'"
    fi
fi

errcho


if "${has_conflicts}"; then
    cecho red >&2 "Please resolve the following conflicts now!"
    sleep 0.1
    for file in "${conflict_list[@]}"; do
        echo "${file}"
    done

    exit 10
else
    cecho green >&2 "OK"
fi