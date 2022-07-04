"""This script is mainly used for testing purposes.
"""

import sys
from util import simple_usage_message, load_json
from test_name import get_test_name


if __name__ == '__main__':
    if len(sys.argv) < 8:
        simple_usage_message("<task_data file (problem.json)> <testset_name> <testset_index> " +
                             "<subtask_index> <test_index> <test_offset> <gen_arguments...>")

    test_name = get_test_name(
        task_data=load_json(sys.argv[1]),
        testset_name=sys.argv[2],
        testset_index=int(sys.argv[3]),
        subtask_index=int(sys.argv[4]),
        test_index=int(sys.argv[5]),
        test_offset=int(sys.argv[6]),
        gen_line=sys.argv[7:],
    )

    print(test_name)
