#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"


function usage {
	errcho "Usage: <compile> [--public] <solution-path>"
	exit 2
}

[ $# -gt 0 ] || usage

if [ "$1" == "--public" ]; then
	shift
	grader_type="public"
	used_grader_dir="${public_dir}"
else
	grader_type="judge"
	used_grader_dir="${grader_dir}"
fi

[ $# -gt 0 ] || usage
solution="$1"; shift

[ $# -gt 0 ] && usage

sensitive check_file_exists "Solution file" "${solution}"

ext="$(extension "${solution}")"
prog="${problem_name}.${ext}"

grader_lang_dir="${used_grader_dir}/${ext}"
recreate_dir "${sandbox}"
cp "${solution}" "${sandbox}/${prog}"


if [ "${ext}" == "cpp" ] ; then
	cp "${grader_lang_dir}/${problem_name}.h" "${grader_lang_dir}/grader.cpp" "${sandbox}"
	[ -z "${CPP_STD_OPT+x}" ] && CPP_STD_OPT="--std=gnu++14"
	[ -z "${CPP_OPTS+x}" ] && CPP_OPTS="-DEVAL ${CPP_STD_OPT} -Wall -Wextra -Wshadow -O2"
	pushd "${sandbox}" > /dev/null
	g++ ${CPP_OPTS} -c "grader.cpp" -o "grader.o"
	rm "grader.cpp"
	g++ ${CPP_OPTS} "grader.o" "${prog}" -o "${problem_name}.exe"
	popd > /dev/null
elif [ "${ext}" == "pas" ] ; then
	cp "${grader_lang_dir}/grader.pas" "${sandbox}"
	[ -f "${grader_lang_dir}/graderlib.pas" ] && cp "${grader_lang_dir}/graderlib.pas" "${sandbox}"
	[ -z "${PAS_OPTS+x}" ] && PAS_OPTS="-dEVAL -XS -O2"
	pushd "${sandbox}" > /dev/null
	fpc ${PAS_OPTS} "grader.pas" "-o${problem_name}.exe"
	popd > /dev/null
elif [ "${ext}" == "java" ] ; then
	cp "${grader_lang_dir}/grader.java" "${sandbox}"
	pushd "${sandbox}" > /dev/null
	[ -z "${JAVAC_OPTS+x}" ] && JAVAC_OPTS=""
	javac ${JAVAC_OPTS} "grader.java" "${prog}"
	jar cfe "${problem_name}.jar" "grader" *.class
	rm *.class
	popd > /dev/null
else
	errcho "Unknown extension: ${ext}"
	exit 1
fi


function replace_tokens {
	sed -e "s/PROBLEM_NAME_PLACE_HOLDER/${problem_name}/g"
}

execsh="${sandbox}/exec.sh"
cat "${templates}/exec.${ext}.sh" | replace_tokens > "${execsh}"
chmod +x "${execsh}"

runsh="${sandbox}/run.sh"
cat "${templates}/run.${grader_type}.sh" | replace_tokens > "${runsh}"
chmod +x "${runsh}"


post_compile="${templates}/post_compile.sh"

if [ -f "${post_compile}" ] ; then
	export grader_type
	export used_grader_dir
	export grader_lang_dir
	export solution
	bash "${post_compile}"
fi

cecho green OK
