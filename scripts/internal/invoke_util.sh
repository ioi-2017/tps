
# Assumes that "util.sh" is already sourced.


function compile_checker_if_needed {
	if "${HAS_CHECKER}"; then
		printf "%-${STATUS_PAD}scompile" "checker"
		if "${SKIP_CHECK}"; then
			echo_status "SKIP"
		else
			sensitive reporting_guard "checker.compile" build_with_make "${CHECKER_DIR}"
		fi
		echo
	fi
}
