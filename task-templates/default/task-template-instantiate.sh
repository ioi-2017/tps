
set -euo pipefail

# Prompting template parameters required for task instantiation

prompt identifier short_name
prompt string task_title "Shown as heading of statement"
prompt bool has_grader "Are solutions linked with graders"
if "${has_grader}"; then
	prompt identifier grader_function_name
	prompt bool has_input_secret "Do input files have a secret string header"
	prompt bool has_output_secret "Do output files have a secret string header"
else
	has_input_secret="false"
	has_output_secret="false"
fi

if "${has_input_secret}" || "${has_output_secret}"; then
	prompt string random_seed "Used for randomly generated strings"
fi

prompt bool has_java "Is Java language available for solutions"
prompt bool has_python "Is Python language available for solutions"
prompt bool has_public "Is public data provided to the contestants"
prompt enum:md:tex:none statement_format "Is statement in markdown or tex format"
prompt bool has_gitlab_ci "Is gitlab-ci used"



# Cloning the template directory as the new task directory
clone_template_directory



# Updating task directory structure

# Removing unavailable languages
function remove_language {
	local -r lang="$1"; shift
	local -r language_name="$1"; shift
	errcho "Removing files related to language ${language_name}"
	rm -rf "./solution/"*/*".${lang}"
	local sol_pattern
	printf -v "sol_pattern" ',\s*"[^"]+\.%s"\s*:\s*{[^}]*}' "${lang}"
	py_regex_replace_in_files "${sol_pattern}" "" "./solutions.json"
	rm -rf "./grader/${lang}"
	rm -rf "./public/"*"/${lang}"
	local pub_pattern
	printf -v "pub_pattern" '^[[:space:]]*[a-zA-Z0-9_]\+[[:space:]]\+%s/' "${lang}"
	local f
	for f in "public/"*"/files"; do
		grep -v -e "${pub_pattern}" "${f}" > "${f}.replace_tmp"
		mv "${f}.replace_tmp" "${f}"
		py_regex_replace_in_files '[\n]{2,}' '\n\n' "${f}"
	done
}

replace_in_file_contents "__TPARAM_HAS_JAVA__" "${has_java}" "problem.json"
"${has_java}" ||
	remove_language "java" "Java"

replace_in_file_contents "__TPARAM_HAS_PYTHON__" "${has_python}" "problem.json"
"${has_python}" ||
	remove_language "py" "Python"

"${has_gitlab_ci}" ||
	rm -f ".gitlab-ci.yml"


# Replacing short name
replace_in_file_names_and_contents "__TPARAM_SHORT_NAME__" "${short_name}" "."

replace_in_file_contents "__TPARAM_TASK_TITLE__" "${task_title}" "."

# Grader
replace_in_file_contents "__TPARAM_HAS_GRADER__" "${has_grader}" "."
if "${has_grader}"; then
	replace_in_file_contents "__TPARAM_GRADER_FUNCTION_NAME__" "${grader_function_name}" "."
else
	rm -rf "grader"
fi


# Generating and replacing secrets
secret_charset="$(run_python -c "import string; print(string.ascii_uppercase+string.ascii_lowercase+string.digits)")"


function handle_secret_tag {
	local -r tag="$1"; shift
	local -r condition="$1"; shift
	local replacement
	if eval "${condition}"; then
		replacement='\1'
		errcho "Keeping lines with secret tag '${tag}'"
	else
		replacement=''
		errcho "Removing lines with secret tag '${tag}'"
	fi
	local line_pattern
	local -r hws='[^\S\n]*' # horizontal white space
	printf -v "line_pattern" '//%s\\$%s%s\\n([^\\n]*\\n)' "${hws}" "${tag}" "${hws}"
	py_regex_replace_in_files "${line_pattern}" "${replacement}" "validator/"* "checker/"*
	if "${has_grader}"; then
		py_regex_replace_in_files "${line_pattern}" "${replacement}" "grader/cpp/"*
		if "${has_java}"; then
			py_regex_replace_in_files "${line_pattern}" "${replacement}" "grader/java/"*
		fi
		if "${has_python}"; then
			printf -v "line_pattern" '#%s\\$%s%s\\n([^\\n]*\\n)' "${hws}" "${tag}" "${hws}"
			py_regex_replace_in_files "${line_pattern}" "${replacement}" "grader/py/"*
		fi
	fi
}

handle_secret_tag "SecretIO" "${has_input_secret} && ${has_output_secret}"
handle_secret_tag "Secret" "${has_input_secret} || ${has_output_secret}"
handle_secret_tag "SecretI" "${has_input_secret}"
handle_secret_tag "SecretO" "${has_output_secret}"
handle_secret_tag "!SecretO" "! ${has_output_secret}"

if "${has_input_secret}"; then
	input_secret="$(generate_random_string "32" "${secret_charset}" "input_secret-${random_seed}")"
	errcho "input_secret=${input_secret}"
	replace_in_file_contents "__TPARAM_INPUT_SECRET__" "${input_secret}" "."
fi

if "${has_output_secret}"; then
	output_secret="$(generate_random_string "32" "${secret_charset}" "output_secret-${random_seed}")"
	errcho "output_secret=${output_secret}"
	replace_in_file_contents "__TPARAM_OUTPUT_SECRET__" "${output_secret}" "."
fi


# Solution
pushdq "solution"
select_file_by_value "${has_grader}" "selected" \
	"true" "with-grader" \
	"false" "without-grader"
move_dir_contents "selected" "."
popdq


# Generator
pushdq "gen"
public_examples_dir="../public/examples"
public_example_inputs="$(ls -A1 "${public_examples_dir}" | grep '\.in$' || true)"
gen_data_sample_tests="$(
	while read public_example_input; do
		if "${has_public}"; then
			echo "copy ${public_examples_dir}/${public_example_input}"
		else
			manual_example_input="example-${public_example_input}"
			cp "${public_examples_dir}/${public_example_input}" "manual/${manual_example_input}"
			echo "manual ${manual_example_input}"
		fi
	done <<< "${public_example_inputs}"
)"
replace_in_file_contents "__TPARAM_SAMPLE_TESTS__" "${gen_data_sample_tests}" "data"

"${has_input_secret}" ||
	rm "input.header"
popdq


# Validator
# Nothing to do


# Checker
checker_name="checker.cpp"
pushdq "checker"
select_file_by_value "${has_grader}" "${checker_name}" \
	"false" "checker-without-grader.cpp" \
	"true" "checker-with-grader.cpp"
popdq


# Statement
pushdq "statement"
select_file_by_value "${statement_format}" "selected" \
	"tex" "tex" \
	"md" "md"
[ "${statement_format}" == "none" ] ||
	move_dir_contents "selected" "."
if [ "${statement_format}" == "md" ]; then
	select_file_by_value "${has_grader}" "index.md" \
		"true" "index-with-grader.md" \
		"false" "index-without-grader.md"
fi
if [ "${statement_format}" == "tex" ]; then
	select_file_by_value "${has_grader}" "statement.tex" \
		"true" "statement-with-grader.tex" \
		"false" "statement-without-grader.tex"
	if "${has_grader}"; then
		rm -rf "samples"
	fi
fi
popdq


# Public
public_dir="public"
if "${has_public}"; then
	pushdq "${public_dir}"
	select_file_by_value "${has_grader}" "selected" \
		"true" "with-grader" \
		"false" "without-grader"
	move_dir_contents "selected" "."
	popdq
else
	rm -rf "${public_dir}"
fi
