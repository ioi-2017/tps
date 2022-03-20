
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir "stage"

function capture_bc {
	local -r key="$1"; shift
	local args=("$@")
	unset "args[${#args[@]}-1]"
	capture_exec "${key}-n" tps_bc "${index}" 0 ${args[@]+"${args[@]}"}
	args=("$@")
	local i
	for ((i=0; i<=3; i++)); do
		capture_exec "${key}-${i}" tps_bc "${index}" "${i}" "${args[@]}"
	done
}

function tests_group {
	local -r suffix="$1"; shift
	function capture_exec_g {
		local -r key="$1"; shift
		capture_exec "${key}${suffix}" "$@"
	}
	function capture_bc_g {
		local -r key="$1"; shift
		capture_bc "${key}${suffix}" "$@"
	}

	capture_exec_g "no-cmd" tps
	capture_exec_g "cmd" tps a_command
	capture_exec_g "cmd-p" tps a_command a_param
	capture_exec_g "say" tps say
	capture_exec_g "say-p" tps say a_param
	capture_exec_g "foo" tps foo
	capture_exec_g "foo-p" tps foo a_param

	echo
	index=1
	capture_bc_g "c-u" a_command
	capture_bc_g "c-u-p" a_command a_param
	capture_bc_g "c-say" say
	capture_bc_g "c-say-p" say a_param
	capture_bc_g "c-so" so
	capture_bc_g "c-so-p" so a_param

	echo
	index=2
	capture_bc_g "p-u" a_command a_param

	capture_bc_g "p-say" say a_param
	capture_bc_g "p-say-" say -a_param
	capture_bc_g "p-say--" say --a_param
	capture_exec_g "p-say-eq-a-9" tps_bc "${index}" 9 say --a_param=a
	capture_exec_g "p-say-eq-a-10" tps_bc "${index}" 10 say --a_param=a
	capture_exec_g "p-say-eq-a-11" tps_bc "${index}" 11 say --a_param=a
	capture_exec_g "p-say-eq-b-9" tps_bc "${index}" 9 say --a_param=b
	capture_exec_g "p-say-eq-b-10" tps_bc "${index}" 10 say --a_param=b
	capture_exec_g "p-say-eq-b-11" tps_bc "${index}" 11 say --a_param=b

	capture_bc_g "p-foo-u" foo a_param
	capture_bc_g "p-foo-u-" foo -a_param
	capture_bc_g "p-foo-u--" foo --a_param
	capture_bc_g "p-foo-h" foo hello
	capture_bc_g "p-foo-h-" foo -hello
	capture_bc_g "p-foo-h--" foo --hello
	capture_exec_g "p-foo-eq-a-6" tps_bc "${index}" 6 foo --type=a
	capture_exec_g "p-foo-eq-a-7" tps_bc "${index}" 7 foo --type=a
	capture_exec_g "p-foo-eq-a-8" tps_bc "${index}" 8 foo --type=a
	capture_exec_g "p-foo-eq-b-6" tps_bc "${index}" 6 foo --type=b
	capture_exec_g "p-foo-eq-b-7" tps_bc "${index}" 7 foo --type=b
	capture_exec_g "p-foo-eq-b-8" tps_bc "${index}" 8 foo --type=b
}

echo
tests_group ""
echo
capture_run set_exec_cwd "a_dir"
tests_group "-d"
capture_run unset_exec_cwd

end_capturing
popd_test_context
