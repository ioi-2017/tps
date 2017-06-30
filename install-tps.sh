#!/bin/bash

dest_dir="/usr/local/bin"
# ${dest_dir} must be in PATH

set -e

dest="${dest_dir}/tps"

echo "copying 'tps.sh' to '${dest_dir}' as 'tps'..."

cp tps.sh "${dest}"
chmod +x "${dest}"

echo done.
