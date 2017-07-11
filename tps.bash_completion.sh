
# bash completion for tps

function _tps() {
	COMPREPLY=( )
	index=0
	while IFS= read tmp; do
		if [ -z "${tmp}" ]; then
			continue
		fi
		COMPREPLY[${index}]="${tmp}"
		index=$((index+1))
	done <<< "$(tps --bash-completion "${COMP_CWORD}" "${COMP_WORDS[@]}")"
}

complete -o nospace -o bashdefault -F _tps tps
