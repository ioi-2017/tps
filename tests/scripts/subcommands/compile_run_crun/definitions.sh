
function tcompile {
	_TT_dos2unixify tps compile "$@"
	return $?
}

function trun {
	_TT_dos2unixify tps run "$@"
	return $?
}

function tcrun {
	_TT_dos2unixify tps crun "$@"
	return $?
}
