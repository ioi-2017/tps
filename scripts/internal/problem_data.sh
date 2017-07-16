
#sets the variable problem_name from file problem.json

problem_name="$(python "${internals}/json_extract.py" "${problem_json}" "name")"
problem_type="$(python "${internals}/json_extract.py" "${problem_json}" "type")"
HAS_GRADER="$(python "${internals}/json_extract.py" "${problem_json}" "has_grader" 2> /dev/null)" || true

if [ -z "${HAS_GRADER}"  ]; then
    case "${problem_type}" in
        output-only) HAS_GRADER="false" ;;
        *) HAS_GRADER="true" ;;
    esac
else
    if [ "${HAS_GRADER}" != "true" -a "${HAS_GRADER}" != "false" ]; then
        >&2 echo "Invalid 'has_grader' value '${HAS_GRADER}' in problem.json (possible values are 'true' and 'false')"
        exit 3
    fi
fi
