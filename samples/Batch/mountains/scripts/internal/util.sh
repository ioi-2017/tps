#!/bin/bash

function errcho {
	>&2 echo "$@"
}

function print_exit_code {
    ret=0
    "$@" || ret=$?
    echo "${ret}"
}

function extension {
	file=$1
	echo "${file##*.}"
}

function check_variable {
	varname=$1
	if [ -z ${!varname+x} ]; then
		errcho "Error: Variable '${varname}' is not set."
		exit 1
	fi
}

function are_same {
    diff "$1" "$2" > /dev/null 2>&1
}

function recreate_dir {
    dir=$1
    mkdir -p "${dir}"
    ls -A1 "${dir}" | while read file; do
        [ -z "${file}" ] && continue
        rm -rf "${dir}/${file}"
    done
}

function _sort {
    sort_command=$(which -a "sort" | grep -iv "windows" | sed -n 1p)
	if [ -z "${sort_command}" ] ; then
		sort_command="cat"
	fi
	"${sort_command}" "$@"
}

function sensitive {
    "$@"
    ret=$?
    if [ "${ret}" -ne 0 ]; then
        exit ${ret}
    fi
}

function is_windows {
    if [ -z "${OS+x}" ]; then
        return 1
    fi
    echo "${OS}" | grep -iq "windows"
}

function is_web {
    if [ -z "${WEB_TERMINAL+x}" ]; then
        return 1
    fi
    [ "${WEB_TERMINAL}" == "true" ]
}

function term_color_support {
    test -t 1 || return 1
    ncolors=$(tput colors)
    test -n "${ncolors}" || return 1
    test ${ncolors} -ge 8 || return 1
}

term_color_reset="\033[00m"
term_color_green="\033[32m"
term_color_red="\033[31m"
term_color_yellow="\033[033m"
term_color_purple="\033[35m"
term_color_blue="\033[34m"
term_color_gray="\033[02;37m"

function linux_cecho {
	color="$1"
	shift
	if term_color_support || is_web; then
	    color_var="term_color_${color}"
	    echo -en "${!color_var}"
	    echo "$@"
	    echo -en "${term_color_reset}"
	else
	    echo "$@"
	fi
}

function win_cecho {
    color="$1"; shift
    echo "$@"
}

#'echo's with the given color
#examples:
# cecho green this is a text
# cecho red -n this is a text with no new line

function cecho {
    if is_windows; then
        win_cecho "$@"
    else
        linux_cecho "$@"
    fi
}

function boxed_echo {
    color="$1"; shift

    echo -n "["
    cecho "${color}" -n "$1"
    echo -n "]"

    if [ ! -z "${BOX_PADDING+x}" ]; then
        pad=$((BOX_PADDING - ${#1}))
        hspace "${pad}"
    fi
}

function echo_status {
    status="$1"

    case "${status}" in
        OK) color=green ;;
        FAIL) color=red ;;
        WARN) color=yellow ;;
        SKIP) color=gray ;;
        *) color=purple ;;
    esac

    boxed_echo "${color}" "${status}"
}

function echo_verdict {
    verdict="$1"

    case "${verdict}" in
        Correct) color=green ;;
        Partial*) color=yellow ;;
        Wrong*|Runtime*) color=red ;;
        Time*) color=blue ;;
        Unknown) color=gray ;;
        *) color=purple ;;
    esac

    boxed_echo "${color}" "${verdict}"
}

skip_status=1000
abort_status=1001

function job_ret {
    job="$1"
    ret_file="${LOGS_DIR}/${job}.ret"
    if [ -f "${ret_file}" ]; then
        cat "${ret_file}"
    else
        echo "${skip_status}"
    fi
}

function check_float {
    echo "$1" | grep -Eq '^[0-9]+\.?[0-9]*$'
}

function job_tlog_file {
    job="$1"
    echo "${LOGS_DIR}/${job}.tlog"
}

function job_tlog {
    job="$1"; shift
    key="$1"
    tlog_file="$(job_tlog_file "${job}")"
    if [ -f "${tlog_file}" ]; then
        ret=0
        line="$(grep "^${key} " "${tlog_file}")" || ret=$?
        if [ ${ret} -ne 0 ]; then
            errcho "tlog file '${tlog_file}' does not contain key '${key}'"
            exit 1
        fi
        echo "${line}" | cut -d' ' -f2-
    else
        errcho "tlog file '${tlog_file}' is not created"
        exit 1
    fi
}

function has_warnings {
    job="$1"
    WARN_FILE="${LOGS_DIR}/${job}.warn"
    [ -s "${WARN_FILE}" ]
}

function job_status {
    job="$1"
    ret="$(job_ret "${job}")"

    if [ "${ret}" -eq 0 ]; then
        if has_warnings "${job}"; then
            echo "WARN"
        else
            echo "OK"
        fi
    elif [ "${ret}" -eq "${skip_status}" ]; then
        echo "SKIP"
    else
        echo "FAIL"
    fi
}

function guard {
    job="$1"; shift
    outlog="${LOGS_DIR}/${job}.out"
    errlog="${LOGS_DIR}/${job}.err"
    retlog="${LOGS_DIR}/${job}.ret"
    export WARN_FILE="${LOGS_DIR}/${job}.warn"

    echo "${abort_status}" > "${retlog}"

    ret=0
    "$@" > "${outlog}" 2> "${errlog}" || ret=$?
    echo "${ret}" > "${retlog}"

    return ${ret}
}

function insensitive {
    "$@" || true
}

function boxed_guard {
    job="$1"

    insensitive guard "$@"
    echo_status "$(job_status "${job}")"
}

function execution_report {
    job="$1"

    cecho yellow -n "exit-code: "
    echo "$(job_ret "${job}")"
    if has_warnings "${job}"; then
        cecho yellow "warnings:"
        cat "${LOGS_DIR}/${job}.warn"
    fi
    cecho yellow "stdout:"
    cat "${LOGS_DIR}/${job}.out"
    cecho yellow "stderr:"
    cat "${LOGS_DIR}/${job}.err"
}

function reporting_guard {
    job="$1"

    boxed_guard "$@"
    ret="$(job_ret "${job}")"

    if [ "${ret}" -ne 0 ]; then
        echo
        execution_report "${job}"
    fi

    return ${ret}
}

function is_in {
    key="$1"; shift
    for item in "$@"; do
        if [ "${key}" == "${item}" ]; then
            return 0
        fi
    done
    return 1
}

function hspace {
    printf "%$1s" ""
}

function check_file_exists {
    file_type="$1"
    file_path="$2"

    if [ ! -f "${file_path}" ]; then
        errcho "${file_type} '$(basename "${file_path}")' not found."
        errcho "Given address: '${file_path}'"
        return 4
    fi
}

function invalid_arg {
    errcho "Error at argument '${curr}': " "$@"
    usage
    exit 2
}

# Fetches the value of an option, while parsing the arguments of the command
# ${curr} denotes the current token
# ${next} denotes the next token when ${next_available} is "true"
# the next token is allowed to be used when ${can_use_next} is "true"

function fetch_arg_value {
    variable_name="$1"; shift
    short_name="$1"; shift
    long_name="$1"; shift
    argument_name="$1"

    fetched_arg_value=""
    if [ "${curr}" == "${short_name}" ]; then
        if "${can_use_next}" && "${next_available}"; then
            fetched_arg_value="${next}"
            shifts=1
        fi
    else
        fetched_arg_value="${curr#${long_name}=}"
    fi
    [ ! -z "${fetched_arg_value}" ] || invalid_arg "missing ${argument_name}"
    eval "${variable_name}=${fetched_arg_value}"
}

# Parses arguments of the command
# two callbacks should be provided in order to handle positional args and options
# variables ${curr}, ${next}, ${next_available}, and ${can_use_next} are provided to callbacks

function argument_parser {
    handle_positional_arg_callback="$1"; shift
    handle_option_callback="$1"; shift

    while [ $# -gt 0 ]; do
        shifts=0
        curr="$1"; shift
        next_available="false"
        if [ $# -gt 0 ]; then
            next="$1"
            next_available="true"
        fi

        if [[ "${curr}" == --* ]]; then
            can_use_next="false"
            "${handle_option_callback}"
        elif [[ "${curr}" == -* ]]; then
            if [ "${#curr}" == 1 ]; then
                invalid_argument "invalid argument"
            else
                temp="${curr#-}"
                while [ ! -z "${temp}" ]; do
                    can_use_next="false"
                    if [ "${#temp}" -eq 1 ]; then
                        can_use_next="true"
                    fi
                    curr="-${temp:0:1}"
                    handle_option
                    temp="${temp:1}"
                done
            fi
        else
            "${handle_positional_arg_callback}"
        fi

        shift "${shifts}"
    done
}
