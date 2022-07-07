
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir "stage"
echo

capture_run source "../definitions.sh"

capture_run _TT_check_stage_not_in_a_tps_repo
echo

capture_exec_key_counter=0

function capture_init_bc {
	if [ $# -lt 2 ]; then
		_TT_errcho "init_bc: At least 2 paramters 'index' and 'cursor_offset' are required."
		return 3
	fi
	local -r index="$1"; shift
	local -r cursor_offset="$1"; shift
	capture_exec "k-$((capture_exec_key_counter++))" tps_bc "${index}" "${cursor_offset}" "init" "$@"
}


function testset1 {
	local i
	echo
	capture_init_bc 3 0 -t
	for i in 0 1 4; do
		capture_init_bc 3 $i -t tpl1
	done
	capture_init_bc 3 1 -t d
	capture_init_bc 3 1 -t z

	echo
	for i in 11 12 15; do
		capture_init_bc 2 $i --template=tpl1
	done
	capture_init_bc 2 12 --template=d
	capture_init_bc 2 12 --template=z
}

function testset2 {
	local i
	echo
	capture_init_bc 3 0 -T 
	for i in 0 1 2 9 10; do
		capture_init_bc 3 $i -T templates1
	done
	capture_init_bc 3 1 -T z

	echo
	for i in 16 17 18 25 26; do
		capture_init_bc 2 $i --templates-dir=templates1
	done
	capture_init_bc 2 17 --templates-dir=z

	local tdir
	for tdir in templates1 templates2; do
		echo
		capture_init_bc 5 0 -T "${tdir}" -t
		for i in 0 1 4; do
			capture_init_bc 5 $i -T "${tdir}" -t tpl1
		done
		capture_init_bc 5 1 -T "${tdir}" -t d
		capture_init_bc 5 1 -T "${tdir}" -t z

		echo
		for i in 11 12 15; do
			capture_init_bc 4 $i -T "${tdir}" --template=tpl1
		done
		capture_init_bc 4 12 -T "${tdir}" --template=d
		capture_init_bc 4 12 -T "${tdir}" --template=z
	done
}

echo

capture_run unset TPS_TASK_TEMPLATES_PATH

echo
capture_init_bc 1 0
capture_init_bc 1 1
capture_init_bc 1 2
capture_init_bc 2 0
capture_init_bc 2 0 a
for i in 0 1 2 3 9 10; do
	capture_init_bc 2 $i --template=
done
for i in 0 1 2 3 10 11; do
	capture_init_bc 2 $i --templates-dir=
done
for i in 0 1 2 3 6 7; do
	capture_init_bc 2 $i --define 
done

testset1
testset2

echo
capture_run export TPS_TASK_TEMPLATES_PATH=nowhere

testset1
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
