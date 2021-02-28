import sys
import os
import subprocess

from util import get_bool_environ, simple_usage_message, wait_process_success
from color_util import cprinterr, colors
import tests_util as tu


INTERNALS_DIR = os.environ.get('INTERNALS')
LOGS_DIR = os.environ.get('LOGS_DIR')
SPECIFIC_TESTS = get_bool_environ('SPECIFIC_TESTS')
SPECIFIED_TESTS_PATTERN = os.environ.get('SPECIFIED_TESTS_PATTERN')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        simple_usage_message("<tests-dir>")
    tests_dir = sys.argv[1]

    try:
        test_name_list = tu.get_test_names_from_tests_dir(tests_dir)
    except tu.MalformedTestsException as e:
        cprinterr(colors.ERROR, "Error:")
        sys.stderr.write("{}\n".format(e))
        sys.exit(4)

    if SPECIFIC_TESTS:
        tu.check_pattern_exists_in_test_names(SPECIFIED_TESTS_PATTERN, test_name_list)
        test_name_list = tu.filter_test_names_by_pattern(test_name_list, SPECIFIED_TESTS_PATTERN)

    available_tests, missing_tests = tu.divide_tests_by_availability(test_name_list, tests_dir)
    if missing_tests:
        cprinterr(colors.WARN, "Missing tests: "+(", ".join(missing_tests)))

    subtask_score_and_verdict = dict.fromkeys(tu.get_subtasks_tests_dict_from_tests_dir(tests_dir).keys())

    for test_name in available_tests:
        command = [
            'bash',
            os.path.join(INTERNALS_DIR, 'invoke_test.sh'),
            tests_dir,
            test_name,
        ]
        wait_process_success(subprocess.Popen(command))

        score = verdict = None
        with open(os.path.join(LOGS_DIR, "{}.score".format(test_name)), 'r') as sf:
            score = float(sf.readlines()[0].strip('\n'))
        with open(os.path.join(LOGS_DIR, "{}.verdict".format(test_name)), 'r') as vf:
            verdict = vf.readlines()[0].strip('\n')

        for subtask in tu.get_test_subtasks_from_tests_dir(test_name, tests_dir):
            if subtask_score_and_verdict[subtask] is None or score < subtask_score_and_verdict[subtask][0]:
                subtask_score_and_verdict[subtask] = (score, verdict, test_name)

    print("\nSubtask summary")
    for subtask in subtask_score_and_verdict.keys():
        if subtask_score_and_verdict[subtask] is not None:
            score, verdict, test_name = subtask_score_and_verdict[subtask]
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'subtask_summary.sh'),
                subtask,
                str(score),
                verdict,
                test_name
            ]
            wait_process_success(subprocess.Popen(command))

    if missing_tests:
        cprinterr(colors.WARN, "Missing {} {}!".format(len(missing_tests), "tests" if len(missing_tests) != 1 else "test"))
