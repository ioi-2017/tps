import sys
import os
import re
import fnmatch
from collections import defaultdict

from gen_data_parser import DataVisitor, parse_data
from test_exists import test_exists


def test_name_matches_pattern(test_name, pattern):
    pattern_terms = re.split(",|\\|", pattern) # Split by ',' and '|'
    pattern_terms = map(str.strip, pattern_terms)
    return any(fnmatch.fnmatchcase(test_name, pattern_term) for pattern_term in pattern_terms)


def test_name_pattern_matcher(pattern):
    return lambda test_name: test_name_matches_pattern(test_name, pattern)


def filter_test_names_by_pattern(test_names, pattern):
    return filter(test_name_pattern_matcher(pattern), test_names)


def check_pattern_exists_in_test_names(pattern, test_names):
    if not any(map(test_name_pattern_matcher(pattern), test_names)):
        sys.stderr.write("No test name matches the pattern '%s'\n" % pattern)
        sys.exit(2)


class TestsVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests = []

    def on_test(self, testset_name, test_name, line, line_number):
        self.tests.append(test_name)


def get_test_names_by_gen_data(gen_data, task_data):
    tests_visitor = TestsVisitor()
    parse_data(gen_data, task_data, tests_visitor)
    return tests_visitor.tests


class MalformedTestsException(Exception):
    pass


def get_test_names_from_tests_dir(tests_dir):
    if not os.path.isdir(tests_dir):
        raise MalformedTestsException("Tests directory not found or not a valid directory: '{}'".format(tests_dir))
    GEN_SUMMARY_FILE_NAME = os.environ.get('GEN_SUMMARY_FILE_NAME')
    gen_summary_file = os.path.join(tests_dir, GEN_SUMMARY_FILE_NAME)
    if not os.path.isfile(gen_summary_file):
        raise MalformedTestsException("Tests are not correctly generated.\nTest generation summary file not found or not a valid file: '{}'".format(gen_summary_file))

    with open(gen_summary_file, 'r') as gsf:
        return [
            line.split()[0]
            for line in map(str.strip, gsf.readlines())
            if line and not line.startswith("#")
        ]


def divide_tests_by_availability(test_names, tests_dir):
    missing_tests = []
    available_tests = []
    for test_name in test_names:
        if test_exists(tests_dir, test_name):
            available_tests.append(test_name)
        else:
            missing_tests.append(test_name)
    return available_tests, missing_tests


def get_subtask_test_relations_from_tests_dir(tests_dir):
    if not os.path.isdir(tests_dir):
        raise MalformedTestsException("Tests directory not found or not a valid directory: '{}'".format(tests_dir))
    MAPPING_FILE_NAME = os.environ.get('MAPPING_FILE_NAME')
    mapping_file = os.path.join(tests_dir, MAPPING_FILE_NAME)
    if not os.path.isfile(mapping_file):
        raise MalformedTestsException("Tests are not correctly generated.\nSubtasks mapping file not found or not a valid file: '{}'".format(mapping_file))
    with open(mapping_file, 'r') as f:
        subtask_test_relations = [tuple(line.split()) for line in f.readlines()]
    if not all(len(rel) == 2 for rel in subtask_test_relations):
        raise MalformedTestsException("Subtasks mapping file '{}' does not have the correct format.".format(mapping_file))
    return subtask_test_relations


def get_test_subtasks_from_tests_dir(test_name, tests_dir):
    subtask_test_relations = get_subtask_test_relations_from_tests_dir(tests_dir)
    return [
        rel_subtask
        for rel_subtask, rel_test_name in subtask_test_relations
        if rel_test_name == test_name
    ]


def get_subtasks_tests_dict_from_tests_dir(tests_dir):
    subtask_test_relation = get_subtask_test_relations_from_tests_dir(tests_dir)
    subtasks_tests = defaultdict(list)
    for subtask, test_name in subtask_test_relation:
        subtasks_tests[subtask].append(test_name)
    return subtasks_tests
