
#script initially 'source'd by tps before calling the given <command>

#exporting all variables
set -a

if [ -z "${BASE_DIR+x}" ]; then
    >&2 echo "You are using an old version of TPS ('${tps_version}'). We recommend you to install a newer version of TPS (>= '1.1'), and try again."
    >&2 echo "1) Oh, cool. I will do it."
    >&2 echo "2) How dare you? I love to work with my ancient version of TPS."
    >&2 read -p "Choose an option: [1/2]" _option
    if [ "${_option}" == "1" ]; then
        exit 1
    else
        export BASE_DIR="${base_dir}"
    fi
fi

source "${BASE_DIR}/scripts/internal/locations.sh"
source "${INTERNALS}/problem_data.sh"
PYTHONPATH="${PYTHONPATH}:${INTERNALS}:${TEMPLATES}"

ulimit -s 512000 > /dev/null 2>&1 || true
JAVA_OPTS="-Xmx512M -Xss256M"

set +a

