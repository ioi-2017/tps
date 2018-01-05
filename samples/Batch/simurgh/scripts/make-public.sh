#!/bin/bash

set -euo pipefail

source "${INTERNALS}/util.sh"

grader="${GRADER_DIR}"
public="${PUBLIC_DIR}"

attachment_name="${PROBLEM_NAME}.zip"
public_files="${TEMPLATES}/public.files"

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
	python ${INTERNALS}/pgg.py < "${grader}/$1" > "${public}/$1"
	fix "$@"
}

function make_grader() {
	pgg "$@"
}

function make_public() {
	fix "$@"
}

extention_point="${TEMPLATES}/make_public_extension.sh"

if [ -f "${extention_point}" ] ; then
	source "${extention_point}"
fi

function replace_tokens {
	sed -e "s/PROBLEM_NAME_PLACE_HOLDER/${PROBLEM_NAME}/g"
}

pushd "${PUBLIC_DIR}" > /dev/null

while read raw_line; do
	line=$(echo $raw_line | replace_tokens | xargs)
	if [ -z "${line}" -o "${line:0:1}" == "#" ]; then
		continue
	fi
	args=($line)
	file=${args[1]}
	make_${line}
	if grep -iq secret "${file}"; then
		errcho "Secret found in '${file}'"
		exit 1
	fi
done < "${public_files}"

rm -f "${attachment_name}"

while read raw_line; do
	line=$(echo $raw_line | replace_tokens | xargs)
	if [ -z "${line}" -o "${line:0:1}" == "#" ]; then
		continue
	fi
	args=($line)
	file=${args[1]}
	echo "$file"
done < $public_files | zip -@ "${attachment_name}"

popd > /dev/null

mv "${PUBLIC_DIR}/${attachment_name}" .

cecho yellow "Created attachment '${attachment_name}'."

cecho green OK
