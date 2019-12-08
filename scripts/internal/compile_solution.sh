
# This script compiles a solution.
#
# Argument list:
#	* SOLUTION: the solution file path
#
# Environment conditions:
#	* Environment variables regarding file locations like SANDBOX, INTERNALS, ... must be set.
#		They are naturally set and exported in locations.sh during TPS initialization.
#	* Environment variable HAS_GRADER must be set to either "true" or "false".
#		It is naturally specified by problem_data.sh in TPS initialization.
#	* Environment variable GRADER_TYPE determines the type of grader (meaningful if HAS_GRADER is "true").
#		Its value must be either "judge" or "public".
#		If it is not set, it will be considered to be "judge".
#	* Environment variable VERBOSE determines if verbose details should be printed or not.
#		It must be either "true" or "false".
#		If it is not set, it will be considered to be "false".
#
# Behavior:
#	* The script builds the solution in SANDBOX.
#	* The exit code is non-zero in case of failure.
#	* It also detects compile warnings if WARN_FILE is defined.


set -euo pipefail

source "${INTERNALS}/util.sh"


function error_echo {
	cerrcho error -n "Error: "
	errcho "$@"
}
function error_exit {
	exit_code=$1; shift
	error_echo "$@"
	exit ${exit_code}
}


# This function 'echo's its arguments iff VERBOSE is true
# It assumes the variable VERBOSE is already defined with value either "true" or "false".
function vecho {
	if "${VERBOSE}" ; then
		cerrcho cyan "$@"
	fi
}


# This function runs a command
# It also prints the command before running iff VERBOSE is true
# It assumes the variable VERBOSE is already defined with value either "true" or "false".
function vrun {
	if "${VERBOSE}" ; then
		cerrcho cyan -n "RUN: "
		errcho "$@"
	fi
	"$@"
}


[ "$#" -eq 1 ] || error_exit 2 "Illegal number of arguments"
SOLUTION="$1"; shift

if variable_not_exists "VERBOSE" ; then
	VERBOSE="false"
elif ! is_in "${VERBOSE}" "true" "false" ; then
	error_exit 1 "Invalid value for variable VERBOSE: ${VERBOSE}"
fi

check_variable HAS_GRADER
if "${HAS_GRADER}"; then
	if variable_not_exists "GRADER_TYPE" ; then
		GRADER_TYPE="judge"
	fi
	if [ "${GRADER_TYPE}" == "judge" ] ; then
		USED_GRADER_DIR="${GRADER_DIR}"
	elif [ "${GRADER_TYPE}" == "public" ] ; then
		USED_GRADER_DIR="${PUBLIC_DIR}"
	else
		error_exit 1 "Invalid grader type: ${GRADER_TYPE}"
	fi
fi

sensitive check_file_exists "Solution file" "${SOLUTION}"

ext="$(extension "${SOLUTION}")"

if is_in "${ext}" "cpp" "cc" ; then
	vecho "Detected language: C++"
	LANG="cpp"
elif [ "${ext}" == "pas" ] ; then
	vecho "Detected language: Pascal"
	LANG="pas"
elif [ "${ext}" == "java" ] ; then
	vecho "Detected language: Java"
	LANG="java"
else
	error_exit 1 "Unknown solution extension: ${ext}"
fi

if "${HAS_GRADER}"; then
	vecho "The task has grader."
	vecho "GRADER_TYPE='${GRADER_TYPE}'"
	vecho "USED_GRADER_DIR='${USED_GRADER_DIR}'"
	GRADER_LANG_DIR="${USED_GRADER_DIR}/${LANG}"
	vecho "GRADER_LANG_DIR='${GRADER_LANG_DIR}'"
else
	vecho "The task does not have grader."
fi

vecho "Cleaning the sandbox..."
vrun recreate_dir "${SANDBOX}"

prog="${PROBLEM_NAME}.${LANG}"

vecho "Copying solution '${SOLUTION}' to sandbox as '${prog}'..."
vrun cp "${SOLUTION}" "${SANDBOX}/${prog}"


coloring_enabled="false"
if [ -t 2 ]; then
	coloring_enabled="true"
fi


vecho "Entering the sandbox."
pushd "${SANDBOX}" > /dev/null


compiler_out="compile.outputs"

function capture_compile {
	"$@" 2>&1 | tee -i -a "${compiler_out}" 1>&2
}

function check_warning {
	local warning_text_pattern="$1"
	if variable_exists "WARN_FILE"; then
		vecho "WARN_FILE='${WARN_FILE}'"
		if grep -q "${warning_text_pattern}" "${compiler_out}"; then
			vecho "Text pattern '${warning_text_pattern}' found in compiler outputs."
			echo "Text pattern '${warning_text_pattern}' found in compiler outputs." >> "${WARN_FILE}"
		else
			vecho "Text pattern '${warning_text_pattern}' not found in compiler outputs."
		fi
	else
		vecho "variable WARN_FILE is not defined."
	fi	
}


if [ "${LANG}" == "cpp" ] ; then
	variable_not_exists "CPP_STD_OPT" && CPP_STD_OPT="--std=gnu++14"
	vecho "CPP_STD_OPT='${CPP_STD_OPT}'"
	variable_not_exists "CPP_WARNING_OPTS" && CPP_WARNING_OPTS="-Wall -Wextra -Wshadow"
	vecho "CPP_WARNING_OPTS='${CPP_WARNING_OPTS}'"
	variable_not_exists "CPP_OPTS" && CPP_OPTS="-DEVAL ${CPP_STD_OPT} ${CPP_WARNING_OPTS} -O2"
	vecho "CPP_OPTS='${CPP_OPTS}'"
	if "${coloring_enabled}" ; then
		coloring_flag="-fdiagnostics-color=always"
	else
		coloring_flag="-fdiagnostics-color=never"
	fi
	files_to_compile=("${prog}")
	if is_windows; then
		vecho "It is Windows. Needed disabling runtime error dialog."
		wrdd="win_rte_dialog_disabler.cpp"
		vecho "Copying '${wrdd}' to sandbox..."
		vrun cp "${INTERNALS}/${wrdd}" "."
		files_to_compile+=("${wrdd}")
	fi
	if "${HAS_GRADER}"; then
		grader_header="${PROBLEM_NAME}.h"
		grader_cpp="grader.cpp"
		vecho "Copying '${grader_header}' and '${grader_cpp}' to sandbox..."
		vrun cp "${GRADER_LANG_DIR}/${grader_header}" "${GRADER_LANG_DIR}/${grader_cpp}" "."
		vecho "Compiling grader..."
		vrun capture_compile g++ ${CPP_OPTS} -c "${grader_cpp}" -o "grader.o" "${coloring_flag}"
		vecho "Removing grader source..."
		vrun rm "${grader_cpp}"
		files_to_compile+=("grader.o")
		vecho "Added grader object file to the list of files to compile."
	fi
	vecho "files_to_compile: ${files_to_compile[@]}"
	exe_file="${PROBLEM_NAME}.exe"
	vecho "Compiling and linking..."
	vrun capture_compile g++ ${CPP_OPTS} "${files_to_compile[@]}" -o "${exe_file}" "${coloring_flag}"
	check_warning "${WARNING_TEXT_PATTERN_FOR_CPP}"
elif [ "${LANG}" == "pas" ] ; then
	variable_not_exists "PAS_OPTS" && PAS_OPTS="-dEVAL -XS -O2"
	vecho "PAS_OPTS='${PAS_OPTS}'"
	files_to_compile=()
	if "${HAS_GRADER}"; then
		grader_pas="grader.pas"
		vecho "Copying '${grader_pas}' to sandbox..."
		vrun cp "${GRADER_LANG_DIR}/${grader_pas}" "."
		graderlib="graderlib.pas"
		if [ -f "${GRADER_LANG_DIR}/${graderlib}" ] ; then
			vecho "Copying '${graderlib}' to sandbox..."
			vrun cp "${GRADER_LANG_DIR}/${graderlib}" "."
		fi
		files_to_compile+=("${grader_pas}")
	else
		files_to_compile+=("${prog}")
	fi
	vecho "files_to_compile: ${files_to_compile[@]}"
	exe_file="${PROBLEM_NAME}.exe"
	vecho "Compiling and linking..."
	vrun capture_compile fpc ${PAS_OPTS} "${files_to_compile[@]}" "-o${exe_file}"
	if [ ! -x "${exe_file}" ]; then
		error_exit 1 -e "Executable ${exe_file} is not created by the compiler.\nThe source file was probably a UNIT instead of a PROGRAM."
	fi
	check_warning "${WARNING_TEXT_PATTERN_FOR_PAS}"
elif [ "${LANG}" == "java" ] ; then
	variable_not_exists "JAVAC_WARNING_OPTS" && JAVAC_WARNING_OPTS="-Xlint:all"
	vecho "JAVAC_WARNING_OPTS='${JAVAC_WARNING_OPTS}'"
	variable_not_exists "JAVAC_OPTS" && JAVAC_OPTS="${JAVAC_WARNING_OPTS}"
	vecho "JAVAC_OPTS='${JAVAC_OPTS}'"
	files_to_compile=("${prog}")
	if "${HAS_GRADER}"; then
		grader_java="grader.java"
		vecho "Copying '${grader_java}' to sandbox..."
		vrun cp "${GRADER_LANG_DIR}/${grader_java}" "."
		files_to_compile+=("${grader_java}")
		main_class="grader"
	else
		main_class="${PROBLEM_NAME}"
	fi
	vecho "files_to_compile: ${files_to_compile[@]}"
	vecho "Compiling java sources..."
	vrun capture_compile javac ${JAVAC_OPTS} "${files_to_compile[@]}"
	jar_file="${PROBLEM_NAME}.jar"
	vecho "Creating the jar file..."
	vrun capture_compile jar cfe "${jar_file}" "${main_class}" *.class
	vecho "Removing *.class files..."
	vrun rm *.class
	check_warning "${WARNING_TEXT_PATTERN_FOR_JAVA}"
else
	error_exit 5 "Illegal state; unknown language: ${LANG}"
fi

vecho "Exiting the sandbox."
popd > /dev/null


function replace_tokens {
	the_file="$1"
	# Do not try to delete the backup removal code by omitting '.bak'.
	# Implementation of 'sed' in GNU (Linux) is different from BSD (Mac).
	# For any change of this code you have to test it both in Linux and Mac.
	vrun sed -i.bak -e "s/PROBLEM_NAME_PLACE_HOLDER/${PROBLEM_NAME}/g" "${the_file}"
	vrun rm "${the_file}.bak"
}

execsh_name="exec.sh"
execsh="${SANDBOX}/${execsh_name}"
vecho "Creating '${execsh_name}' in sandbox..."
vrun cp "${TEMPLATES}/exec.${LANG}.sh" "${execsh}"
replace_tokens "${execsh}"
vrun chmod +x "${execsh}"

if "${HAS_GRADER}"; then
	source_runsh="${TEMPLATES}/run.${GRADER_TYPE}.sh"
else
	source_runsh="${TEMPLATES}/run.judge.sh"
fi

runsh_name="run.sh"
runsh="${SANDBOX}/${runsh_name}"
vecho "Creating '${runsh_name}' in sandbox..."
vrun cp "${source_runsh}" "${runsh}"
replace_tokens "${runsh}"
vrun chmod +x "${runsh}"


post_compile_name="post_compile.sh"
post_compile="${TEMPLATES}/${post_compile_name}"

if [ -f "${post_compile}" ] ; then
	if "${HAS_GRADER}"; then
		export GRADER_TYPE
		export USED_GRADER_DIR
		export GRADER_LANG_DIR
	fi
	export SOLUTION
	vecho "File ${post_compile_name} is present in templates. Executing..."
	vrun bash "${post_compile}"
else
	vecho "File ${post_compile_name} is not present in templates. Nothing more to do."
fi
