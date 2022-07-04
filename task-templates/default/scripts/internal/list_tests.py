import sys
import os

from util import simple_usage_message, load_json
from tests_util import get_test_names_by_gen_data


if __name__ == '__main__':
    if len(sys.argv) != 2:
        simple_usage_message("<gen-data-file>")
    gen_data_file = sys.argv[1]

    PROBLEM_JSON = os.environ.get('PROBLEM_JSON')
    task_data = load_json(PROBLEM_JSON)
    with open(gen_data_file, 'r') as gdf:
        gen_data = gdf.readlines()
    tests = get_test_names_by_gen_data(gen_data, task_data)

    for test in tests:
        print(test)
