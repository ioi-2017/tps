
#sets the problem related variables from file problem.json

PROBLEM_NAME="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "name")"
PROBLEM_TYPE="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "type")"
HAS_GRADER="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_grader" 2> /dev/null)" || true
HAS_MANAGER="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_manager" 2> /dev/null)" || true


function check_bool {
	local var_name="$1"; shift
	local value="$1"; shift
	if [ "${value}" != "true" -a "${value}" != "false" ]; then
		>&2 echo "Invalid '${var_name}' value '${value}' in problem.json (possible values are 'true' and 'false')"
		exit 3
	fi
}

if [ -z "${HAS_GRADER}"  ]; then
	case "${PROBLEM_TYPE}" in
		Output*) HAS_GRADER="false" ;;
		*) HAS_GRADER="true" ;;
	esac
else
	check_bool "has_grader" "${HAS_GRADER}"
fi

if [ -z "${HAS_MANAGER}"  ]; then
	case "${PROBLEM_TYPE}" in
		Communicat*) HAS_MANAGER="true" ;;
		*) HAS_MANAGER="false" ;;
	esac
else
	check_bool "has_manager" "${HAS_MANAGER}"
fi
