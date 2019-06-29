#!/bin/bash


function get_model_solution {
    model_solution_name="$(python "${INTERNALS}/get_model_solution.py")" || return $?
    echo "${SOLUTION_DIR}/${model_solution_name}"
}

function get_time_limit {
    python "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "time_limit"
}

function get_test_validators {
    test_name="$1"
    python "${INTERNALS}/get_test_validators.py" "${test_name}" "${MAPPING_FILE}"
}


function get_test_validator_commands {
    test_name="$1"
    get_test_validators "${test_name}" | while read validator_name validator_args ; do 
        [ -z "${validator_name}" ] && continue
		#echo "validator_name='${validator_name}'" 
		#echo "validator_args='${validator_args}'"
		check_executability=false
		check_existance=false
		case "${validator_name}" in
		*.cpp | *.pas )
				#echo "it's cpp|pas"
				validator_target="${VALIDATOR_DIR}/${validator_name%.*}.exe"
				validator_command="'${validator_target}' ${validator_args}"
				check_executability=true
		        ;;
		*.java )
				#echo "it's java"
				validator_target="${VALIDATOR_DIR}/${validator_name%.*}.class"
				validator_command="java -cp '${VALIDATOR_DIR}' '${validator_name%.*}' ${validator_args}"
				check_existance=true
				;;
		*.py )
				#echo "it's python"
				validator_target="${VALIDATOR_DIR}/${validator_name}"
				validator_command="python '${validator_target}' ${validator_args}"
				check_existance=true
				;;
		*.sh )
				#echo "it's bash"
				validator_target="${VALIDATOR_DIR}/${validator_name}"
				validator_command="bash '${validator_target}' ${validator_args}"
				check_existance=true
				;;
		*.* )
				#echo "it's other executable file"
				validator_target="${VALIDATOR_DIR}/${validator_name}"
				validator_command="'${validator_target}' ${validator_args}"
				check_executability=true
				;;
		* )
				#echo "it has no extension"
				validator_target="No validator target when the first validator argument has no extension"
				validator_command="${validator_name} ${validator_args}"
				;;
		esac
		#echo "validator_target='${validator_target}'"
		#echo "check_existance='${check_existance}'"
		#echo "check_executability='${check_executability}'"
		#echo "validator_command='${validator_command}'"

		if "${check_existance}" ; then
			check_file_exists "validator" "${validator_target}" || return $?
		fi
		if "${check_executability}" ; then
			check_executable_exists "validator" "${validator_target}" || return $?
		fi
        
    	echo "${validator_command}"
    done || return $?
}
