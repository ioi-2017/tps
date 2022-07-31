
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "../definition_source_util_sh.sh"
capture_run source "definitions.sh"

capture_exec_key_counter=0
function capt {
    capture_exec "k-$((capture_exec_key_counter++))" "$@"
}

echo
capture_run stage_an_empty_dir
echo

for _TT_func in variable_exists variable_not_exists check_variable; do
    for _TT_var in \
            a_variable_that_should_exist \
            an_empty_variable_that_should_exist \
            a_variable_that_should_not_exist \
            a_variable_that_is_unset \
            array0 array1 array2 array3; do
        capt "${_TT_func}" "${_TT_var}"
    done
    echo
done


capture_run unset "my_new_var"
capt -vc "my_new_var" true
capt -vc "my_new_var" set_variable "my_new_var" "my-new-value"
capt -vc "my_new_var" set_variable "my_new_var" "my new value"
capt -vc "my_new_var" set_variable "my_new_var" "my
new value"

echo

capture_run export my_counter=20
echo
capt -vc "my_counter" increment "my_counter"
capt -vc "my_counter" increment "my_counter" "1"
capt -vc "my_counter" increment "my_counter" "2"
capt -vc "my_counter" increment "my_counter" "10"
echo
capt -vc "my_counter" decrement "my_counter"
capt -vc "my_counter" decrement "my_counter" "1"
capt -vc "my_counter" decrement "my_counter" "2"
capt -vc "my_counter" decrement "my_counter" "10"

end_capturing
popd_test_context
