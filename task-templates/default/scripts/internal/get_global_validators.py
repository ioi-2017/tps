import os

from util import load_json, log_warning, unify_list


SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')


def get_global_validators():
    data = load_json(SUBTASKS_JSON)

    validators = list(data.get('global_validators', []))
    if len(validators) == 0:
        log_warning("There is no global validator.")
    return unify_list(validators)


if __name__ == '__main__':
    for validator in get_global_validators():
        print(validator)
