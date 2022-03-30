# Do not edit this file manually. It is automatically generated.
# Edit 'capture-all.sh' instead.

stage_dir stage

expect_exec -o "captured-data/no-cmd/stdout" -eempty -r 1 tps
expect_exec -d a_dir -o "captured-data/no-cmd-d/stdout" -eempty -r 1 tps
expect_exec -oempty -e "captured-data/cmd/stderr" -r 2 tps a_command
expect_exec -d a_dir -oempty -e "captured-data/cmd-d/stderr" -r 2 tps a_command
expect_exec -oempty -e "captured-data/cmd-p/stderr" -r 2 tps a_command a_param
expect_exec -d a_dir -oempty -e "captured-data/cmd-p-d/stderr" -r 2 tps a_command a_param

expect_exec -oh "init " -eempty tps_bc 1 0
expect_exec -oh "init " -eempty tps_bc 1 0 a_command
expect_exec -oempty -eempty tps_bc 1 1 a_command
expect_exec -oh "init " -eempty tps_bc 1 0 a_command a_param
expect_exec -oempty -eempty tps_bc 1 1 a_command a_param
expect_exec -oh "init " -eempty tps_bc 1 0 i_command
expect_exec -oh "init " -eempty tps_bc 1 1 i_command
expect_exec -oempty -eempty tps_bc 1 2 i_command
expect_exec -oh "init " -eempty tps_bc 1 0 i_command a_param
expect_exec -oh "init " -eempty tps_bc 1 1 i_command a_param
expect_exec -oempty -eempty tps_bc 1 2 i_command a_param
expect_exec -oempty -eempty tps_bc 2 0 i_command a_param
expect_exec -oempty -eempty tps_bc 2 1 i_command a_param
