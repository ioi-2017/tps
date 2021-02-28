import sys
import os
import subprocess

from util import get_bool_environ, load_json, simple_usage_message, wait_process_success
from color_util import cprint, cprinterr, colors
import tests_util as tu


INTERNALS_DIR = os.environ.get('INTERNALS')
LOGS_DIR = os.environ.get('LOGS_DIR')
SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
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

    for test_name in available_tests:
        command = [
            'bash',
            os.path.join(INTERNALS_DIR, 'invoke_test.sh'),
            tests_dir,
            test_name,
        ]
        wait_process_success(subprocess.Popen(command))

    print("\nSubtask summary")

    subtasks_data = dict(load_json(SUBTASKS_JSON))['subtasks']
    total_points = total_full_points = 0
    for subtask, tests in tu.get_subtasks_tests_dict_from_tests_dir(tests_dir).items():
        subtask_result = None
        testcases_run = 0

        for test in tests:
            score = verdict = None
            try:
                with open(os.path.join(LOGS_DIR, "{}.score".format(test)), 'r') as sf:
                    score = float(sf.readlines()[0].strip('\n'))
                with open(os.path.join(LOGS_DIR, "{}.verdict".format(test)), 'r') as vf:
                    verdict = vf.readlines()[0].strip('\n')
            except FileNotFoundError:
                pass
            else:
                if subtask_result is None or score < subtask_result[0]:
                    subtask_result = (score, verdict, test)
                testcases_run += 1

        if subtask_result is None:
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'subtask_summary.sh'),
                subtask,
                str(len(tests))
            ]
            wait_process_success(subprocess.Popen(command))
        else:
            subtask_score = subtask_result[0] * subtasks_data[subtask]['score']
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'subtask_summary.sh'),
                subtask,
                str(len(tests)),
                str(testcases_run),
                '{:g}'.format(round(subtask_score, 2)),
                str(subtasks_data[subtask]['score']),
                subtask_result[1],
                subtask_result[2]
            ]
            wait_process_success(subprocess.Popen(command))

            total_points += subtask_score
            total_full_points += subtasks_data[subtask]['score']

    color = colors.OK
    if total_points == 0:
        color = colors.ERROR
    elif total_points < total_full_points:
        color = colors.WARN
    cprint(color, "{:g}/{} pts".format(round(total_points, 2), total_full_points))

    if missing_tests:
        cprinterr(colors.WARN, "Missing {} {}!".format(len(missing_tests), "tests" if len(missing_tests) != 1 else "test"))
