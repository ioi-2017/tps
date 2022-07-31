
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "../../definition_source_util_sh.sh"
capture_run source "definitions.sh"

capture_exec_key_counter=0
function arg_parse {
    capture_exec "ts1-$((capture_exec_key_counter++))" "${capture_args1[@]}" arg_parse1 "$@"
}

echo
capture_run stage_an_empty_dir
echo

arg_parse
arg_parse aha
arg_parse aha ehe
arg_parse aha ehe oho
arg_parse aha "ehe oho"
arg_parse -h
arg_parse --help
arg_parse -c
arg_parse --cool
arg_parse -a aha
arg_parse -a
arg_parse -a ""
arg_parse --aaa=aha
arg_parse --aaa aha
arg_parse --aaa=
arg_parse -ca ehe
arg_parse -b ehe
arg_parse -b
arg_parse -b ""
arg_parse --bcd=ehe
arg_parse --bcd ehe
arg_parse --bcd=
arg_parse --yx ehe
arg_parse -cb "hee haa"
arg_parse -cb hee haa
arg_parse -cb hee -a haa
arg_parse -cb hee -n haa
arg_parse -cb hee --next haa
arg_parse -cb hee --next=haa
arg_parse -cb hee -a hey --next haa
arg_parse -cb hee -a hey vv1 --next haa
arg_parse -cb hee -a hey --next haa vv1
arg_parse -cb hee -a hey --next haa vv1 vv2
arg_parse -cb hee -a hey vv1 --next haa vv2

end_capturing
popd_test_context
