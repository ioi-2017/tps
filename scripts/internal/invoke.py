import sys
import os
import subprocess

from util import load_json, wait_process_success
from gen_data_parser import DataVisitor, parse_data, check_test_pattern_exists, test_name_matches_pattern


PROBLEM_JSON = os.environ.get('PROBLEM_JSON')
INTERNALS_DIR = os.environ.get('INTERNALS')
SPECIFIC_TESTS = os.environ.get('SPECIFIC_TESTS')
SPECIFIED_TESTS_PATTERN = os.environ.get('SPECIFIED_TESTS_PATTERN')


class InvokingVisitor(DataVisitor):
    def on_test(self, testset_name, test_name, line, line_number):
        global tests_dir
        if SPECIFIC_TESTS == "false" or test_name_matches_pattern(test_name, SPECIFIED_TESTS_PATTERN):
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'invoke_test.sh'),
                tests_dir,
                test_name,
            ]
            wait_process_success(subprocess.Popen(command))

if __name__ == '__main__':
    
    if len(sys.argv) != 2:
        from util import simple_usage_message
        simple_usage_message("<tests-dir>")
        
    global tests_dir
    tests_dir = sys.argv[1]
    
    task_data = load_json(PROBLEM_JSON)
    gen_data = sys.stdin.readlines()

    if SPECIFIC_TESTS == "true":
        check_test_pattern_exists(gen_data, task_data, SPECIFIED_TESTS_PATTERN)

    parse_data(gen_data, task_data, InvokingVisitor())
