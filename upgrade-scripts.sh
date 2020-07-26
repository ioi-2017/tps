#!/bin/bash

set -euo pipefail

if [ -n "${PYTHON+x}" ] ; then
	if ! command -v "${PYTHON}" >/dev/null 2>&1; then
		>&2 echo "Error: Python command '${PYTHON}' set by environment variable 'PYTHON' does not exist."
		exit 3
	fi
else
	if command -v "python3" >/dev/null 2>&1 ; then
		PYTHON="python3"
	elif command -v "python" >/dev/null 2>&1 ; then
		PYTHON="python"
	else
		>&2 echo "Error: Environment variable 'PYTHON' is not set and neither of python commands 'python3' nor 'python' exists."
		exit 3
	fi
fi

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
problem_scripts_version_file="${problem_dir}/scripts/internal/version"
problem_scripts_version_legacy_file_name=".scripts_version"
problem_scripts_version_legacy_file="${problem_dir}/${problem_scripts_version_legacy_file_name}"


function ask_yes_no {
    local prompt="$1"; shift
    local res
    read -p "${prompt} [y/n] " res
    while : ; do
        res="$(echo "${res}" | tr '[:upper:]' '[:lower:]')"
        [ "${res}" == "y" ] && return 0
        [ "${res}" == "n" ] && return 1
        read -p "Please, respond with 'y' or 'n': " res
    done
}

function check_proceed {
    local exit_code="$1"; shift
    local prompt="$1"; shift
    if ! ask_yes_no "${prompt}"; then
        exit "${exit_code}"
    fi
}


if [ -f "${problem_scripts_version_file}" ]; then
    old_scripts_version="$(cat "${problem_scripts_version_file}")"
    old_scripts_commit="v${old_scripts_version}"
elif [ -f "${problem_scripts_version_legacy_file}" ]; then
    old_scripts_commit="$(cat "${problem_scripts_version_legacy_file}")"
else
    old_scripts_commit="$(git log --pretty=format:"%H" | tail -n 1)"
fi

if ! git show -s --oneline "${old_scripts_commit}" > /dev/null; then
    cecho red >&2 "Problem scripts commit '${old_scripts_commit}' not found in this source repository."
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
    cecho red >&2 "There are uncommitted changes in the problem repository."
    check_proceed 1 "Are you sure you want to proceed?"
    echo
fi

if ! check_repo_is_clean "$(dirname ${source_scripts})"; then
    cecho red >&2 "There are uncommitted changes in source scripts repository."
    check_proceed 1 "Are you sure you want to proceed?"
    echo
fi

ret=0
tag="$(git describe --tags | head -1)" || ret=$?
if [ "${ret}" -eq 0 ] && [[ ${tag} == v* ]]; then
    source_current_scripts_version="${tag#*v}"
else
    cecho red >&2 "There is no version tag on the current source scripts repository commit."
    check_proceed 1 "Are you sure you want to proceed with commit hash as a version?"
    echo
    source_current_scripts_version="$(git log --pretty=format:"%H" -n 1)"
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
    git show "${old_scripts_commit}:${source_scripts}/${file}" > "${a}" 2> /dev/null || a_exists="false"

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
                if "${a_exists}" && are_same "${a}" "${b}"; then
                    message="not changed"
                else
                    message="both problem and script source changed this file in the same way"
                fi
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

if ! "${dry_run}" && [ -e "${problem_scripts_version_legacy_file}" ]; then
    errcho

    remove_legacy_version="true"
    if "${has_conflicts}"; then
        remove_legacy_version="false"
        if ask_yes_no "There are some conflicts. Should the legacy file '${problem_scripts_version_legacy_file_name}' be deleted?"; then
            remove_legacy_version="true"
        fi
    fi
    if "${remove_legacy_version}"; then
        rm -f "${problem_scripts_version_legacy_file}"
        cecho yellow "Removed legacy file '${problem_scripts_version_legacy_file_name}' in problem."
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