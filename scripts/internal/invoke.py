import os
import sys

from gen_data_parser import DataVisitor, parse_data, check_test_exists
from util import run_bash_command


INTERNALS_DIR = os.environ.get('internals')
SINGULAR_TEST = os.environ.get('singular_test')
SOLE_TEST_NAME = os.environ.get('sole_test_name')


class InvokingVisitor(DataVisitor):
    def on_test(self, testset_name, test_name, line):
        if SINGULAR_TEST == "false" or test_name == SOLE_TEST_NAME:
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'invoke_test.sh'),
                test_name,
            ]
            run_bash_command(command)

if __name__ == '__main__':
    gen_data = sys.stdin.readlines()

    if SINGULAR_TEST == "true":
        check_test_exists(gen_data, SOLE_TEST_NAME)

    parse_data(gen_data, InvokingVisitor())
