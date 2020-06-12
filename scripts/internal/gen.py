import sys
import os
import shlex
import subprocess

from util import load_json, wait_process_success
from gen_data_parser import DataVisitor, parse_data, check_test_pattern_exists, test_name_matches_pattern


PROBLEM_JSON = os.environ.get('PROBLEM_JSON')
SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
INTERNALS_DIR = os.environ.get('INTERNALS')
SPECIFIC_TESTS = os.environ.get('SPECIFIC_TESTS')
SPECIFIED_TESTS_PATTERN = os.environ.get('SPECIFIED_TESTS_PATTERN')


class SummaryVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests = []

    def on_test(self, testset_name, test_name, line, line_number):
        self.tests.append((test_name, line_number, line))

    def print_summary(self, stream):
        stream.write("# test_name gen_line_number gen_line_content\n")
        for test in self.tests:
            stream.write("%s\t%3d\t%s\n" % test)


class MappingVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests_map = dict()
        self.subtasks = []

    def on_testset(self, testset_name, line_number):
        self.tests_map[testset_name] = set()

    def on_subtask(self, subtask_name, line_number):
        self.subtasks.append(subtask_name)

    def on_include(self, testset_name, included_testset, line_number):
        self.tests_map[testset_name] |= self.tests_map[included_testset]

    def on_test(self, testset_name, test_name, line, line_number):
        self.tests_map[testset_name].add(test_name)

    def print_mapping(self, stream):
        for subtask in self.subtasks:
            for test in sorted(list(self.tests_map[subtask])):
                stream.write("%s %s\n" % (subtask, test))


class GeneratingVisitor(DataVisitor):
    def on_test(self, testset_name, test_name, line, line_number):
        global tests_dir
        if SPECIFIC_TESTS == "false" or test_name_matches_pattern(test_name, SPECIFIED_TESTS_PATTERN):
            command = [
                    'bash',
                    os.path.join(INTERNALS_DIR, 'gen_test.sh'),
                    tests_dir,
                    test_name,
                ] + shlex.split(line)
            wait_process_success(subprocess.Popen(command))


if __name__ == '__main__':
    
    if len(sys.argv) != 4:
        from util import simple_usage_message
        simple_usage_message("<tests-dir> <mapping-file> <gen-summary-file>")
    
    global tests_dir
    tests_dir = sys.argv[1]
    mapping_file = sys.argv[2]
    gen_summary_file = sys.argv[3]
    
    task_data = load_json(PROBLEM_JSON)
    gen_data = sys.stdin.readlines()

    if SPECIFIC_TESTS == "true":
        check_test_pattern_exists(gen_data, task_data, SPECIFIED_TESTS_PATTERN)

    summary_visitor = SummaryVisitor()
    parse_data(gen_data, task_data, summary_visitor)
    with open(gen_summary_file, 'w') as f:
        summary_visitor.print_summary(f)
    
    mapping_visitor = MappingVisitor()
    parse_data(gen_data, task_data, mapping_visitor)
    with open(mapping_file, 'w') as f:
        mapping_visitor.print_mapping(f)

    parse_data(gen_data, task_data, GeneratingVisitor())
