import os
import sys
import fnmatch
from test_name import get_test_name

line_number = 0


def data_parse_error(message):
    global line_number
    sys.stderr.write("Error on line #%d: %s\n" % (line_number, message))
    exit(1)


class DataVisitor:
    def __init__(self):
        pass

    def on_include(self, testset_name, included_testset, line_number):
        pass

    def on_test(self, testset_name, test_name, line, line_number):
        pass

    def on_testset(self, testset_name, line_number):
        pass

    def on_subtask(self, subtask_name, line_number):
        pass


'''
gen_data: list of lines in a gen/data file
task_data: json of problem.json
visitor: an instance of DataVisitor
'''
def parse_data(gen_data, task_data, visitor):
    global line_number
    line_number = 0

    testset_index, testset_name = -1, None
    subtask_index, subtask_counter = -1, -1
    test_index, test_offset = 1, -1

    for line0 in gen_data:
        line = line0.strip('\n')
        line_number += 1

        if len(line.strip()) == 0 or line.strip().startswith("#"):
            continue

        command = line.strip().split()[0]
        args = line.strip().split()[1:]

        if command.startswith("@"):
            if command == "@subtask" or command == "@testset":
                test_offset = 1
                testset_index += 1
                testset_name = args[0]
                visitor.on_testset(testset_name, line_number)
                if command == "@subtask":
                    visitor.on_subtask(testset_name, line_number)
                    subtask_counter += 1
                    subtask_index = subtask_counter
                else:
                    subtask_index = -1
            elif command == "@include":
                if testset_index < 0:
                    data_parse_error("No subtask/testset is defined.")

                for included_testset in args:
                    visitor.on_include(testset_name, included_testset, line_number)
            else:
                data_parse_error("Unknown command %s" % command)
        else:
            if testset_index < 0:
                data_parse_error("No subtask/testset is defined.")

            test_name = get_test_name(
                task_data=task_data,
                testset_name=testset_name,
                testset_index=testset_index,
                subtask_index=subtask_index,
                test_index=test_index,
                test_offset=test_offset,
                gen_line=line,
            )

            visitor.on_test(testset_name, test_name, line, line_number)

            test_index += 1
            test_offset += 1


class TestsVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests = []

    def on_test(self, testset_name, test_name, line, line_number):
        self.tests.append(test_name)

    def has_test(self, test_name):
        return test_name in self.tests

    def print_tests(self, stream):
        for test in self.tests:
            stream.write("%s\n" % test)


def check_test_exists(gen_data, task_data, test_name):
    tests_visitor = TestsVisitor()
    parse_data(gen_data, task_data, tests_visitor)
    if not tests_visitor.has_test(test_name):
        sys.stderr.write("Invalid test name '%s'\n" % test_name)
        exit(2)



def test_name_matches_pattern(test_name, pattern):
    return fnmatch.fnmatchcase(test_name, pattern)



def check_test_pattern_exists(gen_data, task_data, test_pattern):
    tests_visitor = TestsVisitor()
    parse_data(gen_data, task_data, tests_visitor)
    if not [test_name for test_name in tests_visitor.tests if test_name_matches_pattern(test_name, test_pattern)]:
        sys.stderr.write("No test name matches the pattern '%s'\n" % test_pattern)
        exit(2)

