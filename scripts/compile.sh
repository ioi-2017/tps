#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"


function usage {
    errcho "Usage: <compile> [options] <solution-path>"
    errcho "Options:"
    errcho -e "  -h, --help"
    errcho -e "  -p, --public"
    errcho -e "\tCompile using public graders"
}

HAS_GRADER=true

if "${HAS_GRADER}"; then
    grader_type="judge"
    used_grader_dir="${grader_dir}"
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
                grader_type="public"
                used_grader_dir="${public_dir}"
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
    if [ -z "${solution+x}" ]; then
        solution="${curr}"
        return
    fi
    invalid_arg "meaningless argument"
}

argument_parser "handle_positional_arg" "handle_option" "$@"

if [ -z "${solution+x}" ]; then
    errcho "Solution is not specified."
    usage
    exit 2
fi

sensitive check_file_exists "Solution file" "${solution}"


ext="$(extension "${solution}")"
prog="${problem_name}.${ext}"

if "${HAS_GRADER}"; then
    grader_lang_dir="${used_grader_dir}/${ext}"
fi

recreate_dir "${sandbox}"
cp "${solution}" "${sandbox}/${prog}"

pushd "${sandbox}" > /dev/null
if [ "${ext}" == "cpp" ] ; then
    [ -z "${CPP_STD_OPT+x}" ] && CPP_STD_OPT="--std=gnu++14"
    [ -z "${CPP_OPTS+x}" ] && CPP_OPTS="-DEVAL ${CPP_STD_OPT} -Wall -Wextra -Wshadow -O2"
    if "${HAS_GRADER}"; then
        cp "${grader_lang_dir}/${problem_name}.h" "${grader_lang_dir}/grader.cpp" "${sandbox}"
        g++ ${CPP_OPTS} -c "grader.cpp" -o "grader.o"
        rm "grader.cpp"
        g++ ${CPP_OPTS} "grader.o" "${prog}" -o "${problem_name}.exe"
    else
        g++ ${CPP_OPTS} "${prog}" -o "${problem_name}.exe"
    fi
elif [ "${ext}" == "pas" ] ; then
    [ -z "${PAS_OPTS+x}" ] && PAS_OPTS="-dEVAL -XS -O2"
    if "${HAS_GRADER}"; then
        cp "${grader_lang_dir}/grader.pas" "${sandbox}"
        [ -f "${grader_lang_dir}/graderlib.pas" ] && cp "${grader_lang_dir}/graderlib.pas" "${sandbox}"
        fpc ${PAS_OPTS} "grader.pas" "-o${problem_name}.exe"
    else
        fpc ${PAS_OPTS} "${prog}" "-o${problem_name}.exe"
    fi
elif [ "${ext}" == "java" ] ; then
    [ -z "${JAVAC_OPTS+x}" ] && JAVAC_OPTS=""
    if "${HAS_GRADER}"; then
        cp "${grader_lang_dir}/grader.java" "${sandbox}"
        javac ${JAVAC_OPTS} "grader.java" "${prog}"
        jar cfe "${problem_name}.jar" "grader" *.class
    else
        javac ${JAVAC_OPTS} "${prog}"
        jar cfe "${problem_name}.jar" "${problem_name}" *.class
    fi
    rm *.class
else
    errcho "Unknown extension: ${ext}"
    exit 1
fi
popd > /dev/null


function replace_tokens {
    sed -e "s/PROBLEM_NAME_PLACE_HOLDER/${problem_name}/g"
}

execsh="${sandbox}/exec.sh"
cat "${templates}/exec.${ext}.sh" | replace_tokens > "${execsh}"
chmod +x "${execsh}"

runsh="${sandbox}/run.sh"
if "${HAS_GRADER}"; then
    source_runsh="${templates}/run.${grader_type}.sh"
else
    source_runsh="${templates}/run.judge.sh"
fi

cat "${source_runsh}" | replace_tokens > "${runsh}"
chmod +x "${runsh}"


post_compile="${templates}/post_compile.sh"

if [ -f "${post_compile}" ] ; then
    if "${HAS_GRADER}"; then
        export grader_type
        export used_grader_dir
        export grader_lang_dir
    fi
    export solution
    bash "${post_compile}"
fi

cecho green OK
