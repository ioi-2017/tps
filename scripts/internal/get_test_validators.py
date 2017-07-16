import os
import sys

from json_extract import navigate_json
from util import check_file_exists, load_json, log_warning

SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')


def usage():
    sys.stderr.write('Usage: python get_test_validators.py <test-name> <mapping-file>')


def get_test_subtasks(mapping_file, target_test_name):
    check_file_exists(mapping_file)
    subtasks = []
    with open(mapping_file, 'r') as f:
        for line in f.readlines():
            line_subtask, line_test_name = line.split()
            if line_test_name == target_test_name:
                subtasks.append(line_subtask)
    return subtasks


if __name__ == '__main__':
    if len(sys.argv) != 3:
        usage()

    test_name = sys.argv[1]
    mapping_file = sys.argv[2]

    test_subtasks = get_test_subtasks(mapping_file, test_name)

    if len(test_subtasks) == 0:
        log_warning("Test '%s' is in no subtasks." % test_name)

    data = load_json(SUBTASKS_JSON)
    test_validators = data.get('global_validators', [])

    if len(test_validators) == 0:
        log_warning("There is no global validator for the problem.")

    for subtask in test_subtasks:
        test_validators += navigate_json(data, 'subtasks/%s' % subtask, SUBTASKS_JSON).get('validators', [])

    seen = set()
    for validator in test_validators:
        if validator not in seen:
            seen.add(validator)
            print(validator)
