import sys
import os

from util import simple_usage_message, check_file_exists, load_json, log_warning
from json_extract import navigate_json


SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')


def get_test_subtasks(target_test_name, mapping_file):
    check_file_exists(mapping_file)
    subtasks = []
    with open(mapping_file, 'r') as f:
        for line in f.readlines():
            line_subtask, line_test_name = line.split()
            if line_test_name == target_test_name:
                subtasks.append(line_subtask)
    return subtasks



def get_test_validators(test_name, mapping_file):
    test_subtasks = get_test_subtasks(test_name, mapping_file)

    if len(test_subtasks) == 0:
        log_warning("Test '%s' is in no subtasks." % test_name)

    data = load_json(SUBTASKS_JSON)

    global_validators = data.get('global_validators', [])
    subtask_sensitive_validators = data.get('subtask_sensitive_validators', [])

    def check_subtask_sensitive_validators(subtask_sensitive_validators):
        subtask_placeholder_var = "subtask"
        subtask_placeholder_test_substitute = "___SUBTASK_PLACEHOLDER_SUBSTITUTE___"
        for subtask_sensitive_validator in subtask_sensitive_validators:
            try:
                subtask_validator_substituted = subtask_sensitive_validator.format(**{
                    subtask_placeholder_var : subtask_placeholder_test_substitute
                })
            except KeyError as e:
                sys.stderr.write('Subtask-sensitive validator "{}" contains unknown placeholder {{{}}}.\n'.format(subtask_sensitive_validator, e.args[0]))
                sys.exit(3)
            else:
                if subtask_placeholder_test_substitute not in subtask_validator_substituted:
                    log_warning('Subtask-sensitive validator "{}" does not contain the subtask placeholder {{{}}}.'.format(subtask_sensitive_validator, subtask_placeholder_var))
    check_subtask_sensitive_validators(subtask_sensitive_validators)

    test_validators = list(global_validators)
    for subtask in test_subtasks:
        test_validators += [validator.format(subtask=subtask) for validator in subtask_sensitive_validators]
        test_validators += navigate_json(data, 'subtasks/%s' % subtask, SUBTASKS_JSON).get('validators', [])

    if len(test_validators) == 0:
        log_warning("There is no validator for test {}.".format(test_name))

    def unify_list(l):
        seen = []
        for e in l:
            if e not in seen:
                seen.append(e)
        return seen

    return unify_list(test_validators)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        simple_usage_message("<test-name> <mapping-file>")

    for validator in get_test_validators(test_name=sys.argv[1], mapping_file=sys.argv[2]):
        print(validator)
