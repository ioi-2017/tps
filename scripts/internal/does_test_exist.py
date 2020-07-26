"""This script is mainly used for testing purposes.
"""

import sys
from util import simple_usage_message
from test_exists import test_exists


if __name__ == '__main__':
    if len(sys.argv) != 3:
        simple_usage_message("<tests-dir> <test-name>")

    tests_dir = sys.argv[1]
    test_name = sys.argv[2]

    sys.exit(0 if test_exists(tests_dir, test_name) else 1)
