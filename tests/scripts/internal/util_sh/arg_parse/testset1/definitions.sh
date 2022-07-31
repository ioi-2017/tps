set -euo pipefail

function arg_parse1 {

	function usage {
		errcho "This is the usage."
	}

	function handle_option1 {
		local -r curr_arg="$1"; shift
		case "${curr_arg}" in
			-h|--help)
				usage
				exit 0
				;;
			-a|--aaa=*)
				fetch_arg_value "var_aaa" "-a" "--aaa" "a a a"
				;;
			-b|--bcd=*)
				fetch_nonempty_arg_value "var_bcd" "-b" "--bcd" "b c d"
				;;
			-n|--next)
				fetch_next_arg "next_param" "-n" "--next" "get-next param"
				;;
			-c|--cool)
				it_is_cool="true"
				;;
			*)
				invalid_arg_with_usage "${curr_arg}" "undefined option"
				;;
		esac
	}

	function handle_positional_arg1 {
		local -r curr_arg="$1"; shift
		if variable_not_exists "param1"; then
			param1="${curr_arg}"
			return
		fi
		if variable_not_exists "param2"; then
			param2="${curr_arg}"
			return
		fi
		invalid_arg_with_usage "${curr_arg}" "meaningless argument"
	}

	it_is_cool="false"
	has_exited="true"
	argument_parser "handle_positional_arg1" "handle_option1" "invalid_arg_with_usage" "$@"
	has_exited="false"
}

probed_vars1=(var_aaa var_bcd next_param it_is_cool param1 param2 has_exited)

capture_args1=()
for _probed_varname in "${probed_vars1[@]}"; do
	capture_args1+=("-vc" "${_probed_varname}")
done
