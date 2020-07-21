
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run stage_dir '"stage"'

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

	index=2
	for cmd in "bar" "foo"; do
		echo
		capture_bc_g "p-${cmd}-u" "${cmd}" a_param
		capture_bc_g "p-${cmd}-u-" "${cmd}" -a_param
		capture_bc_g "p-${cmd}-u--" "${cmd}" --a_param
		capture_bc_g "p-${cmd}-h" "${cmd}" hello
		capture_bc_g "p-${cmd}-h-" "${cmd}" -hello
		capture_bc_g "p-${cmd}-h--" "${cmd}" --hello
		capture_exec_g "p-${cmd}-eq-a-6" tps_bc "${index}" 6 "${cmd}" --type=a
		capture_exec_g "p-${cmd}-eq-a-7" tps_bc "${index}" 7 "${cmd}" --type=a
		capture_exec_g "p-${cmd}-eq-a-8" tps_bc "${index}" 8 "${cmd}" --type=a
		capture_exec_g "p-${cmd}-eq-b-6" tps_bc "${index}" 6 "${cmd}" --type=b
		capture_exec_g "p-${cmd}-eq-b-7" tps_bc "${index}" 7 "${cmd}" --type=b
		capture_exec_g "p-${cmd}-eq-b-8" tps_bc "${index}" 8 "${cmd}" --type=b
	done
}

echo
tests_group ""
echo
capture_run set_exec_cwd '"a_dir"'
tests_group "-d"
capture_run unset_exec_cwd

end_capturing
popd_test_context
