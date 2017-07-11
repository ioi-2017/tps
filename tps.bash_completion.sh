
# bash completion for tps

function _tps() {
	COMPREPLY=( )
	PRE=( ${COMP_LINE:0:${COMP_POINT}} )
	LAST="${PRE[${COMP_CWORD}]}"
	while IFS= read tmp; do
		[ -z "${tmp}" ] && continue
		COMPREPLY+=( "${tmp}" )
	done <<< "$(tps --bash-completion "${COMP_CWORD}" "${#LAST}" "${COMP_WORDS[@]}")"
}

complete -o nospace -o bashdefault -F _tps tps
