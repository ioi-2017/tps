set -euo pipefail

prompt "_VAR_TYPE_PLACEHOLDER_" "_VAR_NAME_PLACEHOLDER_" _VAR_DESCRIPTION_PLACEHOLDER_

if variable_exists "_VAR_NAME_PLACEHOLDER_"; then
	echo "_VAR_NAME_PLACEHOLDER_="
	echo "${_VAR_NAME_PLACEHOLDER_}"
else
	echo "_VAR_NAME_PLACEHOLDER_ is not defined."
fi

mkdir "${output_dir_name}"
