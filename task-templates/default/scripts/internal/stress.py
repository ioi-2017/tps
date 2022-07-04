import sys
import os
import shlex
import random
import subprocess
import importlib.util

from util import simple_usage_message, wait_process_success
from color_util import cprint, colors


INTERNALS_DIR = os.environ.get('INTERNALS')
GEN_STR_RAND_SEED = os.environ.get('GEN_STR_RAND_SEED')


def _main():
    if len(sys.argv) != 3:
        simple_usage_message("<verify|number-of-rounds> <test-case-generation-file>")

    verification_mode = False
    if sys.argv[1] == "verify":
        verification_mode = True
    else:
        num_rounds = int(sys.argv[1])
    test_gen_python_file = sys.argv[2]

    GEN_COMMAND_FUNC_NAME = "gen_command"

    try:

        test_gen_spec = importlib.util.spec_from_file_location("test_gen_module", test_gen_python_file)
        if test_gen_spec is None:
            raise Exception("Not a valid spec.")
        test_gen_module = importlib.util.module_from_spec(test_gen_spec)
        sys.modules["test_gen_module"] = test_gen_module
        test_gen_spec.loader.exec_module(test_gen_module)
        if not hasattr(test_gen_module, GEN_COMMAND_FUNC_NAME):
            raise Exception("The module does not have a member named '{}'.".format(GEN_COMMAND_FUNC_NAME))
        gen_command_func = getattr(test_gen_module, GEN_COMMAND_FUNC_NAME)
        if not callable(gen_command_func):
            raise Exception("The object '{}' defined in the module is not callable.".format(GEN_COMMAND_FUNC_NAME))

    except Exception as ex:
        sys.stderr.write("""\
Error:
Could not load/use the test case generation module from '{fpath}'.
{error}
""".format(
                fpath=test_gen_python_file,
                error=ex,
            )
        )
        exit(2)

    def get_gen_command_line():
        command_line_str = gen_command_func()
        if not isinstance(command_line_str, str):
            raise Exception("The return value of {}() is not a string.".format(GEN_COMMAND_FUNC_NAME))
        try:
            command_line_list = shlex.split(command_line_str)
            if not command_line_list:
                raise Exception("The string must have at least one element.".format(GEN_COMMAND_FUNC_NAME))
        except Exception as ex:
            raise Exception("Error in parsing the return value of {}() '{}': {}".format(GEN_COMMAND_FUNC_NAME, command_line_str, ex))
        return (command_line_str, command_line_list,)


    if GEN_STR_RAND_SEED is not None:
        random.seed(GEN_STR_RAND_SEED)

    if verification_mode:
        # Calling gen_command_func once to check for the correctness of the program.
        try:
            get_gen_command_line()
        except Exception as ex:
            sys.stderr.write("""\
Error:
Could not successfully call '{func}' from '{fpath}'.
{error}
""".format(
                    func=GEN_COMMAND_FUNC_NAME,
                    fpath=test_gen_python_file,
                    error=ex,
                )
            )
            exit(2)

        exit(0)

    round_index = 0
    while True:
        round_index += 1
        if round_index > num_rounds >= 0:
            break

        cprint(colors.YELLOW, "Round {}:".format(round_index))
        try:
            (test_gen_cmd_str, test_gen_cmd_list,) = get_gen_command_line()
        except Exception as ex:
            cprint(
                colors.ERROR,
                """\
Error: Could not successfully create the test generation command line.
{error}""".format(error=ex),
            )
            continue

        print(test_gen_cmd_str)

        command = [
            'bash',
            os.path.join(INTERNALS_DIR, 'stress_single_test.sh'),
            str(round_index),
        ] + test_gen_cmd_list
        wait_process_success(subprocess.Popen(command))


if __name__ == '__main__':
    _main()
