import sys
import os
import subprocess

from util import get_bool_environ, simple_usage_message, check_file_exists, wait_process_success
from color_util import cprinterr, colors
from gen_data_parser import check_pattern_exists_in_test_names, test_name_pattern_matcher
from test_exists import test_exists


INTERNALS_DIR = os.environ.get('INTERNALS')
SPECIFIC_TESTS = get_bool_environ('SPECIFIC_TESTS')
SPECIFIED_TESTS_PATTERN = os.environ.get('SPECIFIED_TESTS_PATTERN')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        simple_usage_message("<tests-dir>")
    tests_dir = sys.argv[1]

    if not os.path.isdir(tests_dir):
        sys.stderr.write("The tests directory not found or not a valid directory: {}.\n".format(tests_dir))
        sys.exit(4)
    GEN_SUMMARY_FILE_NAME = os.environ.get('GEN_SUMMARY_FILE_NAME')
    gen_summary_file = os.path.join(tests_dir, GEN_SUMMARY_FILE_NAME)
    check_file_exists(gen_summary_file, "Tests are not correctly generated.\nTest generation summary file not available: '{}'".format(gen_summary_file))

    with open(gen_summary_file, 'r') as gsf:
        test_name_list = [
            line.split()[0]
            for line in map(str.strip, gsf.readlines())
            if line and not line.startswith("#")
        ]

    if SPECIFIC_TESTS:
        check_pattern_exists_in_test_names(SPECIFIED_TESTS_PATTERN, test_name_list)
        test_name_list = filter(test_name_pattern_matcher(SPECIFIED_TESTS_PATTERN), test_name_list)

    missing_tests = []
    available_tests = []
    for test_name in test_name_list:
        if test_exists(tests_dir, test_name):
            available_tests.append(test_name)
        else:
            missing_tests.append(test_name)

    if missing_tests:
        cprinterr(colors.WARN, "Missing tests: "+(", ".join(missing_tests)))

    for test_name in available_tests:
        command = [
            'bash',
            os.path.join(INTERNALS_DIR, 'invoke_test.sh'),
            tests_dir,
            test_name,
        ]
        wait_process_success(subprocess.Popen(command))

    if missing_tests:
        cprinterr(colors.WARN, "Missing {} {}!".format(len(missing_tests), "tests" if len(missing_tests) != 1 else "test"))
