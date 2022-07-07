set -euo pipefail

prompt "int" "a_variable"

clone_template_directory

echo "${a_variable}" > "result.txt"
