
#script initially 'source'd by tps before calling the given <command>

#exporting all variables
set -a

source "${base_dir}/scripts/internal/locations.sh"
source "${internals}/problem_data.sh"
PYTHONPATH="${PYTHONPATH}:${internals}:${templates}"

ulimit -s 512000 > /dev/null 2>&1 || true
JAVA_OPTS="-Xmx512M -Xss256M"

set +a

