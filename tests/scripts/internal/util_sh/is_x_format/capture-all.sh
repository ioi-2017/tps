
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "../definition_source_util_sh.sh"

capture_exec_key_counter=0
function capt {
    capture_exec "k-$((capture_exec_key_counter++))" "$@"
}

echo
capture_run stage_an_empty_dir
echo

for _TT_val in "t" "hi" "hey you" "hey_you" "hi3" "3hi" "h3i" "aa" "1a" "1" "_" "_a" "_1" "a_" "1_"; do
	capt "is_identifier_format" "${_TT_val}"
done
echo

for _TT_func_name in "is_unsigned_integer_format" "is_signed_integer_format" "is_unsigned_decimal_format" "is_signed_decimal_format"; do
	for _TT_sign in "" "+" "-"; do
		for _TT_val in "0" "3" "13" "0.0" "1.2" "1." ".2" "" " " "." "x" "2x" "x2" "1.x" ".x" "x.2" "x."; do
			capt "${_TT_func_name}" "${_TT_sign}${_TT_val}"
		done
	done
	echo
done

end_capturing
popd_test_context
