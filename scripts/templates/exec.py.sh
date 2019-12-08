#!/bin/bash

problem_name=PROBLEM_NAME_PLACE_HOLDER
main_file=MAIN_FILE_NAME_PLACE_HOLDER
python_cmd=PYTHON_CMD_PLACE_HOLDER
sandbox=$(dirname "$0")

"${python_cmd}" "${sandbox}/${main_file}.py" "$@"
