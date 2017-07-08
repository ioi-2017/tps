# bash completion for tps

function _tps() {
	local cur

	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"

	opts="$(tps --bash-completion)"

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

complete -F _tps tps
