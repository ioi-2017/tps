
#sets the variable problem_name from file problem.json

problem_name="$(python "${internals}/json_extract.py" "${problem_json}" "name")"
problem_type="$(python "${internals}/json_extract.py" "${problem_json}" "type")"
has_grader="$(python "${internals}/json_extract.py" "${problem_json}" "has_grader" 2> /dev/null)"

if [ -z "${has_grader}"  ]; then
    case "${problem_type}" in
        output-only) has_grader="false" ;;
        *) has_grader="true" ;;
    esac
else
    if [ "${has_grader}" != "true" -a "${has_grader}" != "false" ]; then
        >&2 echo "Invalid 'has_grader' value '${has_grader}' in problem.json (possible values are 'true' and 'false')"
        exit 3
    fi
fi