import sys
import os
import shlex
import subprocess

from util import get_bool_environ, simple_usage_message, load_json, wait_process_success
from gen_data_parser import DataVisitor, parse_data
import tests_util as tu


PROBLEM_JSON = os.environ.get('PROBLEM_JSON')
SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
INTERNALS_DIR = os.environ.get('INTERNALS')
SPECIFIC_TESTS = get_bool_environ('SPECIFIC_TESTS')
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

    def make_gen_summary_file(self, tests_dir):
        GEN_SUMMARY_FILE_NAME = os.environ.get('GEN_SUMMARY_FILE_NAME')
        gen_summary_file = os.path.join(tests_dir, GEN_SUMMARY_FILE_NAME)
        with open(gen_summary_file, 'w') as f:
            self.print_summary(f)


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

    def make_mapping_file(self, tests_dir):
        MAPPING_FILE_NAME = os.environ.get('MAPPING_FILE_NAME')
        mapping_file = os.path.join(tests_dir, MAPPING_FILE_NAME)
        with open(mapping_file, 'w') as f:
            self.print_mapping(f)


class GeneratingVisitor(DataVisitor):
    def __init__(self, tests_dir):
        self.tests_dir = tests_dir
        super().__init__()

    def on_test(self, testset_name, test_name, line, line_number):
        if not SPECIFIC_TESTS or tu.test_name_matches_pattern(test_name, SPECIFIED_TESTS_PATTERN):
            command = [
                'bash',
                os.path.join(INTERNALS_DIR, 'gen_test.sh'),
                self.tests_dir,
                test_name,
            ] + shlex.split(line)
            wait_process_success(subprocess.Popen(command))


def _main():
    if len(sys.argv) != 3:
        simple_usage_message("<gen-data-file> <tests-dir>")
    gen_data_file = sys.argv[1]
    tests_dir = sys.argv[2]

    task_data = load_json(PROBLEM_JSON)
    with open(gen_data_file, 'r') as gdf:
        gen_data = gdf.readlines()

    if SPECIFIC_TESTS:
        tu.check_pattern_exists_in_test_names(SPECIFIED_TESTS_PATTERN, tu.get_test_names_by_gen_data(gen_data, task_data))

    summary_visitor = SummaryVisitor()
    parse_data(gen_data, task_data, summary_visitor)
    summary_visitor.make_gen_summary_file(tests_dir)

    mapping_visitor = MappingVisitor()
    parse_data(gen_data, task_data, mapping_visitor)
    mapping_visitor.make_mapping_file(tests_dir)

    parse_data(gen_data, task_data, GeneratingVisitor(tests_dir))


if __name__ == '__main__':
    _main()
