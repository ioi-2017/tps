import os
import sys
from collections import defaultdict
from gen_data_parser import DataVisitor, parse_data, data_parse_error, check_test_exists
from util import run_bash_command

SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
INTERNALS_DIR = os.environ.get('INTERNALS')
SINGULAR_TEST = os.environ.get('SINGULAR_TEST')
SOLE_TEST_NAME = os.environ.get('SOLE_TEST_NAME')


class MappingVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests_map = defaultdict(set)
        self.subtasks = []

    def on_testset(self, testset_name):
        self.tests_map[testset_name] = set()

    def on_subtask(self, subtask_name):
        self.subtasks.append(subtask_name)

    def on_include(self, testset_name, included_testset):
        if included_testset not in self.tests_map:
            data_parse_error("Undefined testset %s" % included_testset)
        self.tests_map[testset_name] |= self.tests_map[included_testset]

    def on_test(self, testset_name, test_name, line):
        self.tests_map[testset_name].add(test_name)

    def get_test_subtasks(self):
        test_subtasks = defaultdict(list)
        for subtask in self.subtasks:
            for test in self.tests_map[subtask]:
                test_subtasks[test].append(subtask)
        return test_subtasks

    def print_mapping(self, stream):
        for subtask in self.subtasks:
            for test in sorted(list(self.tests_map[subtask])):
                stream.write("%s %s\n" % (subtask, test))


class GeneratingVisitor(DataVisitor):
    def on_test(self, testset_name, test_name, line):
        if SINGULAR_TEST == "false" or test_name == SOLE_TEST_NAME:
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'gen_test.sh'),
                test_name,
                line.strip('\n'),
            ]
            run_bash_command(command)


if __name__ == '__main__':
    gen_data = sys.stdin.readlines()

    if SINGULAR_TEST == "true":
        check_test_exists(gen_data, SOLE_TEST_NAME)

    mapping_visitor = MappingVisitor()
    parse_data(gen_data, mapping_visitor)

    with open(sys.argv[1], 'w') as f:
        mapping_visitor.print_mapping(f)

    parse_data(gen_data, GeneratingVisitor())
