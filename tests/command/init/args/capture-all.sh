
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir "stage"
echo

capture_run source "../definitions.sh"

capture_run _TT_check_stage_not_in_a_tps_repo
echo

capture_exec_key_counter=0

function capture_init {
	capture_exec "k-$((capture_exec_key_counter++))" tps "init" "$@"
}


function testset1 {
	echo
	capture_init "new_dir"
	capture_init "new_dir" -t "default"
	capture_init "new_dir" -t "tpl1"
	capture_init "new_dir" -t "file_x"
	capture_init "new_dir" -t "tpl2"

	echo
	capture_init "new_dir" --template=default
	capture_init "new_dir" --template=tpl1
	capture_init "new_dir" --template=file_x
	capture_init "new_dir" --template=tpl2
}

function testset2 {
	echo
	capture_init "new_dir" -T "templates1"
	capture_init "new_dir" -T "z"
	capture_init "new_dir" --templates-dir=templates1
	capture_init "new_dir" --templates-dir=z

	echo
	capture_init "new_dir" -T "templates1"
	capture_init "new_dir" -T "templates1" -t "default"
	capture_init "new_dir" -T "templates1" -t "tpl1"
	capture_init "new_dir" -T "templates1" -t "file_x"
	capture_init "new_dir" -T "templates1" -t "z"

	echo
	capture_init "new_dir" -T "templates1" --template=default
	capture_init "new_dir" -T "templates1" --template=tpl1
	capture_init "new_dir" -T "templates1" --template=file_x
	capture_init "new_dir" -T "templates1" --template=z
}


echo
capture_run unset TPS_TASK_TEMPLATES_PATH

echo
capture_init

echo
capture_init -T "templates1" -t "default" "new_dir"
capture_init -T "templates1" -t "default" "new_dir" "another_arg"
capture_init -T "templates1" -t "default" "another_dir"
capture_init -T "templates1" -t "default" "another_file"

echo
capture_init "new_dir" -T
capture_init "new_dir" -T ""
capture_init "new_dir" -T "nowhere"
capture_init "new_dir" -T "another_file"
capture_init "new_dir" --templates-dir
capture_init "new_dir" --templates-dir=
capture_init "new_dir" --templates-dir=nowhere
capture_init "new_dir" --templates-dir=another_file
capture_init "new_dir" -t
capture_init "new_dir" -t ""
capture_init "new_dir" --template
capture_init "new_dir" --template=
capture_init "new_dir" -T "templates1" --template
capture_init "new_dir" -T "templates1" --template=
capture_init "new_dir" -T "templates1" -t
capture_init "new_dir" -T "templates1" -t ""

testset1
testset2


echo
capture_run export TPS_TASK_TEMPLATES_PATH=nowhere

testset2


echo
capture_run export TPS_TASK_TEMPLATES_PATH=templates1

testset1


echo
capture_run export TPS_TASK_TEMPLATES_PATH=templates2

testset1


echo
capture_run export TPS_TASK_TEMPLATES_PATH=templates1:templates2

testset1


end_capturing
popd_test_context
