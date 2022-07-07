set -euo pipefail

(
	PATH="_PATH_PLACEHOLDER_"
	run_python _ARGS_PLACEHOLDER_
) || exit $?

mkdir "${output_dir_name}"
