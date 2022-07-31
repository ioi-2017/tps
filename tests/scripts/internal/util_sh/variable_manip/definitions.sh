set -euo pipefail

export a_variable_that_should_exist="hi"
export an_empty_variable_that_should_exist=""
unset a_variable_that_should_not_exist
export a_variable_that_is_unset="hi"
unset a_variable_that_is_unset

array0=()
array1=("a")
array2=()
array2[1]="b"
array3=("a" "b")
export array0 array1 array2 array3
