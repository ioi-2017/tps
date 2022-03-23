
set -euo pipefail

# Rule:
#  Do not use "&&" instead of "if".
#  It may cause unexpected exits.
#  You can use "||". But, then be careful. Use "|| return 0", not "|| return".

source "${_TT_UTILS_DIR}/general.sh"
source "${_TT_UTILS_DIR}/testing.sh"
source "${_TT_UTILS_DIR}/project-related.sh"
