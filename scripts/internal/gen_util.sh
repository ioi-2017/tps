
# Assumes that "util.sh" is already sourced.


function compile_generators_if_needed {
	printf "%-${STATUS_PAD}scompile" "generator"
	if "${SKIP_GEN}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "generators.compile" build_with_make "${GEN_DIR}"
	fi
	echo
}


function compile_validators_if_needed {
	printf "%-${STATUS_PAD}scompile" "validator"
	if "${SKIP_VAL}"; then
		echo_status "SKIP"
	else
		sensitive reporting_guard "validators.compile" build_with_make "${VALIDATOR_DIR}"
	fi
	echo
}
