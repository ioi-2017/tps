
set -euo pipefail

# Rule:
#  Do not use "&&" instead of "if".
#  It may cause unexpected exits.
#  You can use "||". But, then be careful. Use "|| return 0", not "|| return".

source "${UTILS_DIR}/general.sh"
source "${UTILS_DIR}/testing.sh"
source "${UTILS_DIR}/project-related.sh"
