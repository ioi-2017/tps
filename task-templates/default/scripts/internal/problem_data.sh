
#sets the problem related variables from file problem.json

PROBLEM_NAME="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "name")"
PROBLEM_TYPE="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "type")"
HAS_GRADER="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_grader" 2> "/dev/null")" || true
HAS_MANAGER="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_manager" 2> "/dev/null")" || true
HAS_CHECKER="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_checker" 2> "/dev/null")" || true
GRADER_NAME="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "grader_name" 2> "/dev/null")" || true
NUM_SOL_PROCESSES="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "num_processes" 2> "/dev/null")" || true

HAS_LANG_CPP="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "cpp_enabled" 2> "/dev/null")" || true
HAS_LANG_JAVA="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "java_enabled" 2> "/dev/null")" || true
HAS_LANG_PASCAL="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "pascal_enabled" 2> "/dev/null")" || true
HAS_LANG_PYTHON="$("${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "python_enabled" 2> "/dev/null")" || true


function check_bool {
	local var_name="$1"; shift
	local value="$1"; shift
	if [ "${value}" != "true" -a "${value}" != "false" ]; then
		>&2 echo "Invalid '${var_name}' value '${value}' in problem.json (possible values are 'true' and 'false')"
		exit 3
	fi
}

if [ -z "${HAS_GRADER}" ]; then
	case "${PROBLEM_TYPE}" in
		Output*) HAS_GRADER="false" ;;
		*) HAS_GRADER="true" ;;
	esac
else
	check_bool "has_grader" "${HAS_GRADER}"
fi

if [ -z "${HAS_MANAGER}" ]; then
	case "${PROBLEM_TYPE}" in
		Communicat*) HAS_MANAGER="true" ;;
		*) HAS_MANAGER="false" ;;
	esac
else
	check_bool "has_manager" "${HAS_MANAGER}"
fi

if [ -z "${HAS_CHECKER}" ]; then
	case "${PROBLEM_TYPE}" in
		Communicat*) HAS_CHECKER="false" ;;
		*) HAS_CHECKER="true" ;;
	esac
else
	check_bool "has_checker" "${HAS_CHECKER}"
fi

if [ -z "${GRADER_NAME}" ]; then
	GRADER_NAME="grader"
fi

if [ -z "${NUM_SOL_PROCESSES}" ]; then
	NUM_SOL_PROCESSES="1"
fi

if [ -z "${HAS_LANG_CPP}" ]; then
	HAS_LANG_CPP="true"
fi
if [ -z "${HAS_LANG_JAVA}" ]; then
	HAS_LANG_JAVA="true"
fi
if [ -z "${HAS_LANG_PASCAL}" ]; then
	HAS_LANG_PASCAL="false"
fi
if [ -z "${HAS_LANG_PYTHON}" ]; then
	HAS_LANG_PYTHON="false"
fi
