set -euo pipefail

function arg_parse2 {

	source "${PROJECT_SCRIPTS_DIR}/internal/util.sh"

	function usage {
		errcho "This is the usage."
	}

	function handle_option2 {
		local -r curr_arg="${curr}"
		case "${curr_arg}" in
			-h|--help)
				usage
				exit 0
				;;
			-x|--x-val=*)
				fetch_arg_value "var_x" "-x" "--x-val" "value x"
				;;
			-y|--y-val=*)
				fetch_arg_value "var_y" "-y" "--y-val" "value y"
				;;
			-A|--AAA)
				it_is_A="true"
				;;
			-a|--aaa)
				it_is_a="true"
				;;
			-B|--BBB)
				it_is_B="true"
				;;
			-b|--bbb)
				it_is_b="true"
				;;
			-c|--ccc)
				c_counter="$((c_counter+1))"
				;;
			*)
				invalid_arg "undefined option2"
				;;
		esac
	}

	function handle_positional_arg2 {
		local -r curr_arg="${curr}"
		my_positional_args+=("${curr_arg}")
	}

	it_is_A="false"
	it_is_a="false"
	it_is_B="false"
	it_is_b="false"
	c_counter="0"
	my_positional_args=()
	has_exited="true"
	argument_parser "handle_positional_arg2" "handle_option2" "$@"
	has_exited="false"
}

probed_vars2=(var_x var_y it_is_A it_is_a it_is_B it_is_b c_counter my_positional_args has_exited)

capture_args2=()
for _probed_varname in "${probed_vars2[@]}"; do
	capture_args2+=("-vc" "${_probed_varname}")
done
