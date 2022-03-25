
set -euo pipefail

pushd_test_context_here
begin_capturing

capture_run source "definitions.sh"

capture_exec_key_counter=0
function arg_parse {
    capture_exec "ts2-$((capture_exec_key_counter++))" "${capture_args2[@]}" arg_parse2 "$@"
}

arg_parse
arg_parse -h
arg_parse --help
arg_parse -q
arg_parse --qqq
arg_parse uuu
arg_parse uuu vv
arg_parse "uuu vv"
arg_parse uuu vv zzz
arg_parse uuu vv zzz y
arg_parse uuu "vv zzz" y
arg_parse -x
arg_parse -x "myx"
arg_parse -x ""
arg_parse --x-val=myx
arg_parse --x-val=
arg_parse -y
arg_parse -y "myy"
arg_parse -y ""
arg_parse --y-val=myy
arg_parse --y-val=
arg_parse -x "myx" -y "myy"

arg_parse -A
arg_parse --AAA
arg_parse -a
arg_parse --aaa
arg_parse -B
arg_parse --BBB
arg_parse -b
arg_parse --bbb

arg_parse -aA
arg_parse -ab
arg_parse -AB
arg_parse -bB
arg_parse -aAb
arg_parse -aAB
arg_parse -aAbB
arg_parse -c
arg_parse -cc
arg_parse -ccc
arg_parse -ccccx "myx"
arg_parse -ccccy "myy"
arg_parse -ac
arg_parse -aAbBc
arg_parse -aAbBcc
arg_parse --ccc
arg_parse --ccc "hi" --ccc
arg_parse --ccc -c
arg_parse --ccc -cc
arg_parse -c a -c b -c c -c
arg_parse -c a -c b -x c -c
arg_parse -c a -x b -y c -c
arg_parse -c a -c b -c "c -c"
arg_parse -c -a -c -b -c -A -c -B

end_capturing
popd_test_context
