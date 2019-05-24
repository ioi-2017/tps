import os
import sys
from util import load_json
from gen_data_parser import TestsVisitor, parse_data 

PROBLEM_JSON = os.environ.get('PROBLEM_JSON')


if __name__ == '__main__':
    task_data = load_json(PROBLEM_JSON)
    gen_data = sys.stdin.readlines()

    testsVisitor = TestsVisitor()
    parse_data(gen_data, task_data, testsVisitor)
    testsVisitor.print_tests(sys.stdout)

