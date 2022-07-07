
echo "============ TTIS START ============"
>&2 echo "============ TTIS START ============"

ret=0
orig_ttis="$(dirname "$0")/task-template-instantiate.orig-ttis.sh"
bash "${orig_ttis}" || ret=$?

echo "============ TTIS FINISH ============"
>&2 echo "============ TTIS FINISH ============"

rm -f "${output_dir_name}/task-template-instantiate.orig-ttis.sh"

exit "${ret}"
