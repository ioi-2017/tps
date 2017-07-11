#!/bin/bash

dest_dir="/usr/local/bin"
# ${dest_dir} must be in PATH

set -e

dest="${dest_dir}/tps"

echo "copying 'tps.sh' to '${dest_dir}' as 'tps'..."

cp tps.sh "${dest}"
chmod +x "${dest}"

bc_file="tps.bash_completion.sh"
bc_dir="/etc/bash_completion.d"

echo "copying '${bc_file}' to '${bc_dir}'..."
cp "${bc_file}" "${bc_dir}/"

echo done.
