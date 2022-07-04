#!/bin/bash


function get_model_solution {
	model_solution_name="$("${PYTHON}" "${INTERNALS}/get_model_solution.py")" || return $?
	echo "${SOLUTION_DIR}/${model_solution_name}"
}

function get_time_limit {
	"${PYTHON}" "${INTERNALS}/json_extract.py" "${PROBLEM_JSON}" "time_limit"
}


function convert_validator_names_to_commands {
	while read validator_name validator_args; do
		[ -z "${validator_name}" ] && continue
		#echo "validator_name='${validator_name}'" 
		#echo "validator_args='${validator_args}'"
		check_executability=false
		check_existance=false
		case "${validator_name}" in
		*.cpp | *.pas )
				#echo "It is C++ or Pascal."
				validator_target="${VALIDATOR_DIR}/${validator_name%.*}.exe"
				validator_command="'${validator_target}' ${validator_args}"
				check_executability=true
				;;
		*.java )
				#echo "It is Java."
				validator_target="${VALIDATOR_DIR}/${validator_name%.*}.class"
				validator_command="java -cp '${VALIDATOR_DIR}' '${validator_name%.*}' ${validator_args}"
				check_existance=true
				;;
		*.py )
				#echo "It is Python."
				validator_target="${VALIDATOR_DIR}/${validator_name}"
				validator_command="'${PYTHON}' '${validator_target}' ${validator_args}"
				check_existance=true
				;;
		*.sh )
				#echo "It is bash."
				validator_target="${VALIDATOR_DIR}/${validator_name}"
				validator_command="bash '${validator_target}' ${validator_args}"
				check_existance=true
				;;
		*.* )
				#echo "It is other executable file."
				validator_target="${VALIDATOR_DIR}/${validator_name}"
				validator_command="'${validator_target}' ${validator_args}"
				check_executability=true
				;;
		* )
				#echo "It has no extension."
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


function get_test_validators {
	local -r test_name="$1"; shift
	local -r tests_dir="$1"; shift
	"${PYTHON}" "${INTERNALS}/get_test_validators.py" "${test_name}" "${tests_dir}"
}

function get_test_validator_commands {
	tests_dir="$1"; shift
	test_name="$1"; shift
	get_test_validators "${test_name}" "${tests_dir}" | convert_validator_names_to_commands || return $?
}


function get_global_validators {
	"${PYTHON}" "${INTERNALS}/get_global_validators.py"
}

function get_global_validator_commands {
	get_global_validators | convert_validator_names_to_commands || return $?
}
