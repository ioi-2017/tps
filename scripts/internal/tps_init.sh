
#script initially 'source'd by tps before calling the given <command>

#exporting all variables
set -a

source "${base_dir}/scripts/internal/locations.sh"
source "${internals}/set_problem_name.sh"
PYTHONPATH="${PYTHONPATH}:${internals}:${templates}"

set +a

