set -euo pipefail


function at_least_3_long_validation_command {
	local var_value
	var_value="$(cat)"
	if [[ "${#var_value}" -ge 3 ]]; then
		echo -n "${var_value}"
		return 0
	else
		errcho "Length must be at least 3 characters."
		return 1
	fi
}

function remove_starting_aa_validation_command {
	local var_value
	var_value="$(cat)"
	if [[ "${var_value}" == aa* ]]; then
		echo -n "${var_value:2}"
		return 0
	else
		errcho "Does not starts with aa."
		return 1
	fi
}

general_prompt "_VAR_NAME_PLACEHOLDER_" "_VAR_VALIDATION_CMD_PLACEHOLDER_" "_PROMPT_MESSAGE_PLACEHOLDER_" _VAR_DESCRIPTION_PLACEHOLDER_

if variable_exists "_VAR_NAME_PLACEHOLDER_"; then
	echo "_VAR_NAME_PLACEHOLDER_="
	echo "${_VAR_NAME_PLACEHOLDER_}"
else
	echo "_VAR_NAME_PLACEHOLDER_ is not defined."
fi

mkdir "${output_dir_name}"
