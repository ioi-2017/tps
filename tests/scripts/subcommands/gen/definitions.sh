
function tgen {
	local ret=0
	_TT_dos2unixify tps gen "$@" || ret=$?
	_TT_dos2unixq "tests/"*
	return "${ret}"
}
