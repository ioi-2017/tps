#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"

grader="${GRADER_DIR}"
public="${PUBLIC_DIR}"

attachment_name="${PROBLEM_NAME}.zip"
public_files="${PUBLIC_DIR}/files"

function fix() {
	cecho yellow -n "fix: "
	echo "$@"
	check_file_exists "file" "${public}/$1"
	dos2unix -q "${public}/$1" > /dev/null
}

function pgg() {
	cecho yellow -n "pgg: "
	echo "$@"
	check_file_exists "file" "${grader}/$1"
	"${PYTHON}" "${INTERNALS}/pgg.py" < "${grader}/$1" > "${public}/$1"
	fix "$@"
}

function make_grader() {
	pgg "$@"
}

function make_public() {
	fix "$@"
}

extention_point="${TEMPLATES}/make_public_extension.sh"

if [ -f "${extention_point}" ]; then
	source "${extention_point}"
fi

function replace_tokens {
	sed -e "s/PROBLEM_NAME_PLACE_HOLDER/${PROBLEM_NAME}/g" \
	    -e "s/GRADER_NAME_PLACE_HOLDER/${GRADER_NAME}/g"
}

sensitive check_file_exists "Public package description file" "${public_files}"

pushd "${PUBLIC_DIR}" > /dev/null

while read raw_line; do
	line=$(echo ${raw_line} | replace_tokens | xargs)
	if [ -z "${line}" -o "${line:0:1}" == "#" ]; then
		continue
	fi

	args=($line)
	
	if [ "${args[0]}" == "copy_test_inputs" ]; then
		gen_data_file="${BASE_DIR}/${args[1]}"
		relative_public_tests_dir="${args[2]}"
		relative_generated_tests_dir="${args[3]}"
		generated_tests_dir="${BASE_DIR}/${relative_generated_tests_dir}"
		sensitive check_file_exists "Generation data file" "${gen_data_file}"
		#function is needed as "sensitive" does not work with multiple lines
		function check_tests_exist {
			"${PYTHON}" "${INTERNALS}/list_tests.py" "${gen_data_file}" | while read test_name; do
				generated_input="${generated_tests_dir}/${test_name}.in"
				sensitive check_file_exists "input file" "${generated_input}"
			done
		}
		sensitive check_tests_exist
		cecho yellow "Copying inputs in '${relative_generated_tests_dir}' to '$(basename ${public})/${relative_public_tests_dir}'; assuming data to be up to date."
		absolute_public_tests_dir="${PUBLIC_DIR}/${relative_public_tests_dir}"
		recreate_dir "${absolute_public_tests_dir}"
		"${PYTHON}" "${INTERNALS}/list_tests.py" "${gen_data_file}" | while read test_name; do
			generated_input="${generated_tests_dir}/${test_name}.in"
			relative_public_input="${relative_public_tests_dir}/${test_name}.in"
			absolute_public_input="${PUBLIC_DIR}/${relative_public_input}"
			cecho yellow -n "copy: "
			echo "${relative_public_input}"
			cp "${generated_input}" "${absolute_public_input}"
			dos2unix -q "${absolute_public_input}" > /dev/null
		done
		continue
	fi
	
	file="${args[1]}"
	make_${line}
	if grep -iq secret "${file}"; then
		errcho "Secret found in '${file}'"
		exit 1
	fi
	if [ "${file: -3}" == ".sh" ]; then
		chmod +x "${file}"
	fi
done < "${public_files}"

rm -f "${attachment_name}"

while read raw_line; do
	line=$(echo ${raw_line} | replace_tokens | xargs)
	if [ -z "${line}" -o "${line:0:1}" == "#" ]; then
		continue
	fi

	args=($line)
	
	if [ "${args[0]}" == "copy_test_inputs" ]; then
		gen_data_file="${BASE_DIR}/${args[1]}"
		relative_public_tests_dir="${args[2]}"
		"${PYTHON}" "${INTERNALS}/list_tests.py" "${gen_data_file}" | while read test_name; do
			relative_public_input="${relative_public_tests_dir}/${test_name}.in"
			echo "${relative_public_input}"
		done
		continue
	fi

	file="${args[1]}"
	echo "${file}"
done < "${public_files}" | zip -@ "${attachment_name}"

popd > /dev/null

mv "${PUBLIC_DIR}/${attachment_name}" "${BASE_DIR}/"

cecho yellow "Created attachment '${attachment_name}'."

cecho success OK
