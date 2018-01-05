
#sets the problem related variables from file problem.json

PROBLEM_NAME="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "name")"
PROBLEM_TYPE="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "type")"
HAS_GRADER="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_grader" 2> /dev/null)" || true
HAS_MANAGER="$(python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "has_manager" 2> /dev/null)" || true

if [ -z "${HAS_GRADER}"  ]; then
    case "${PROBLEM_TYPE}" in
        Output*) HAS_GRADER="false" ;;
        *) HAS_GRADER="true" ;;
    esac
else
    if [ "${HAS_GRADER}" != "true" -a "${HAS_GRADER}" != "false" ]; then
        >&2 echo "Invalid 'has_grader' value '${HAS_GRADER}' in problem.json (possible values are 'true' and 'false')"
        exit 3
    fi
fi

if [ -z "${HAS_MANAGER}"  ]; then
    case "${PROBLEM_TYPE}" in
        Communicat*) HAS_MANAGER="true" ;;
        *) HAS_MANAGER="false" ;;
    esac
else
    if [ "${HAS_MANAGER}" != "true" -a "${HAS_MANAGER}" != "false" ]; then
        >&2 echo "Invalid 'has_manager' value '${HAS_MANAGER}' in problem.json (possible values are 'true' and 'false')"
        exit 3
    fi
fi
