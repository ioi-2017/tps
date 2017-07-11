#!/bin/bash

set -euo pipefail

source "${internals}/util.sh"

grader="${grader_dir}"
public="${public_dir}"

attachment_name="${problem_name}.zip"
public_files="${templates}/public.files"

function pgg() {
	echo pgg: "$@"
	python ${internals}/pgg.py < "${grader}/$1" > "${public}/$1"
	fix "$@"
}

function fix() {
	echo fix: "$@"
	dos2unix "${public}/$1" &> /dev/null
}

function make_public() {
	fix "$@"
}

function make_grader() {
	pgg "$@"
}

extention_point="${templates}/make_public_extension.sh"

if [ -f "${extention_point}" ] ; then
	source "${extention_point}"
fi

function replace_tokens {
	sed -e "s/PROBLEM_NAME_PLACE_HOLDER/${problem_name}/g"
}

pushd "${public_dir}" > /dev/null

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

cecho green OK
