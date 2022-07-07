set -euo pipefail

mkdir "${output_dir_name}"

function check {
	local -r len="$1"; shift
	local -r charset="$1"; shift
	local -r seed="$1"; shift
	echo -e "${len}\t'${charset}'\t${seed}"
	local result
	result="$(generate_random_string "${len}" "${charset}" "${seed}")"
	[ "${#result}" -eq "${len}" ] ||
		error_exit 25 "Incorrect length of generation."
	local i c
	for ((i=0; i<${#result}; i++)); do
		c="${result:$i:1}"
		[[ "${charset}" == *"${c}"* ]] ||
		error_exit 25 "Invalid character '${c}' in the generated string."
	done
}

echo
check 0 "a" "34"
check 1 "a" "3"
check 2 "a" "ba"
check 3 "abA" "basdf"
check 4 "abA12" "bfsdf"
check 5 "aev1234" "bfsdf"
check 10 "aevABCD1234" "vhr"
check 20 "abcevxyABCD123456" "vhavr"
