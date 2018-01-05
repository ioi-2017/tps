#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"


function usage {
    errcho "Usage: <compile> [options] <solution-path>"
    errcho "Options:"
    errcho -e "  -h, --help"
    errcho -e "  -p, --public"
    errcho -e "\tCompile using public graders"
}

if "${HAS_GRADER}"; then
    GRADER_TYPE="judge"
    USED_GRADER_DIR="${GRADER_DIR}"
fi

function handle_option {
    shifts=0
    case "${curr}" in
        -h|--help)
            usage
            exit 0
            ;;
        -p|--public)
            if "${HAS_GRADER}"; then
                GRADER_TYPE="public"
                USED_GRADER_DIR="${PUBLIC_DIR}"
            else
                errcho "Grader is not supported."
                exit 2
            fi
            ;;
        *)
            invalid_arg "undefined option"
            ;;
    esac
}

function handle_positional_arg {
    if [ -z "${SOLUTION+x}" ]; then
        SOLUTION="${curr}"
        return
    fi
    invalid_arg "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "$@"

if [ -z "${SOLUTION+x}" ]; then
    errcho "Solution is not specified."
    usage
    exit 2
fi

sensitive check_file_exists "Solution file" "${SOLUTION}"


ext="$(extension "${SOLUTION}")"
prog="${PROBLEM_NAME}.${ext}"

if "${HAS_GRADER}"; then
    GRADER_LANG_DIR="${USED_GRADER_DIR}/${ext}"
fi

recreate_dir "${SANDBOX}"
cp "${SOLUTION}" "${SANDBOX}/${prog}"

pushd "${SANDBOX}" > /dev/null
if [ "${ext}" == "cpp" ] ; then
    [ -z "${CPP_STD_OPT+x}" ] && CPP_STD_OPT="--std=gnu++14"
    [ -z "${CPP_OPTS+x}" ] && CPP_OPTS="-DEVAL ${CPP_STD_OPT} -Wall -Wextra -Wshadow -O2"
    if "${HAS_GRADER}"; then
        cp "${GRADER_LANG_DIR}/${PROBLEM_NAME}.h" "${GRADER_LANG_DIR}/grader.cpp" "${SANDBOX}"
        g++ ${CPP_OPTS} -c "grader.cpp" -o "grader.o"
        rm "grader.cpp"
        g++ ${CPP_OPTS} "grader.o" "${prog}" -o "${PROBLEM_NAME}.exe"
    else
        g++ ${CPP_OPTS} "${prog}" -o "${PROBLEM_NAME}.exe"
    fi
elif [ "${ext}" == "pas" ] ; then
    [ -z "${PAS_OPTS+x}" ] && PAS_OPTS="-dEVAL -XS -O2"
    if "${HAS_GRADER}"; then
        cp "${GRADER_LANG_DIR}/grader.pas" "${SANDBOX}"
        [ -f "${GRADER_LANG_DIR}/graderlib.pas" ] && cp "${GRADER_LANG_DIR}/graderlib.pas" "${SANDBOX}"
        fpc ${PAS_OPTS} "grader.pas" "-o${PROBLEM_NAME}.exe"
    else
        fpc ${PAS_OPTS} "${prog}" "-o${PROBLEM_NAME}.exe"
    fi
elif [ "${ext}" == "java" ] ; then
    [ -z "${JAVAC_OPTS+x}" ] && JAVAC_OPTS=""
    if "${HAS_GRADER}"; then
        cp "${GRADER_LANG_DIR}/grader.java" "${SANDBOX}"
        javac ${JAVAC_OPTS} "grader.java" "${prog}"
        jar cfe "${PROBLEM_NAME}.jar" "grader" *.class
    else
        javac ${JAVAC_OPTS} "${prog}"
        jar cfe "${PROBLEM_NAME}.jar" "${PROBLEM_NAME}" *.class
    fi
    rm *.class
else
    errcho "Unknown extension: ${ext}"
    exit 1
fi
popd > /dev/null


function replace_tokens {
    sed -e "s/PROBLEM_NAME_PLACE_HOLDER/${PROBLEM_NAME}/g"
}

execsh="${SANDBOX}/exec.sh"
cat "${TEMPLATES}/exec.${ext}.sh" | replace_tokens > "${execsh}"
chmod +x "${execsh}"

runsh="${SANDBOX}/run.sh"
if "${HAS_GRADER}"; then
    source_runsh="${TEMPLATES}/run.${GRADER_TYPE}.sh"
else
    source_runsh="${TEMPLATES}/run.judge.sh"
fi

cat "${source_runsh}" | replace_tokens > "${runsh}"
chmod +x "${runsh}"


post_compile="${TEMPLATES}/post_compile.sh"

if [ -f "${post_compile}" ] ; then
    if "${HAS_GRADER}"; then
        export GRADER_TYPE
        export USED_GRADER_DIR
        export GRADER_LANG_DIR
    fi
    export SOLUTION
    bash "${post_compile}"
fi

cecho green OK
