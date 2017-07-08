
#sets the variable problem_name from file problem.json

problem_name=$(python "${internals}/json_extract.py" "${problem_json}" "name")

