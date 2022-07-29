
# Assumes that "util.sh" and "problem_util.sh" are already sourced.


function check_invoke_prerequisites {
	if ! is_windows && ! "${PYTHON}" -c "import psutil" &> "/dev/null"; then
		cerrcho error -n "Error: "
		errcho "Package 'psutil' is not installed."
		errcho "You can install it using:"
		errcho -e "\tpip install psutil"
		errcho "or:"
		errcho -e "\t${PYTHON} -m pip install psutil"
		exit 1
	fi
}


function check_and_init_limit_variables {
	if variable_not_exists "SOFT_TL" ; then
		SOFT_TL="$(get_time_limit)"
	fi

	if ! check_float "${SOFT_TL}"; then
		error_usage_exit 2 "Provided time limit '${SOFT_TL}' is not a positive real number."
	fi

	if variable_not_exists "HARD_TL" ; then
		HARD_TL="$("${PYTHON}" -c "print(${SOFT_TL} + 2)")"
	fi

	if ! check_float "${HARD_TL}"; then
		error_usage_exit 2 "Provided hard time limit '${HARD_TL}' is not a positive real number."
	fi

	if py_test "${HARD_TL} <= ${SOFT_TL}"; then
		error_usage_exit 2 "Provided hard time limit (${HARD_TL}) is not greater than the soft time limit (${SOFT_TL})."
	fi
}


function compile_solution_if_needed {
	local -r skip="$1"; shift
	local -r job_name="$1"; shift
	local -r solution_label="$1"; shift
	local -r solution_path="$1"; shift

	printf "%-${STATUS_PAD}scompile" "${solution_label}"
	if "${skip}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "${job_name}" bash "${INTERNALS}/compile_solution.sh" "${solution_path}"
	fi
	echo
}


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
