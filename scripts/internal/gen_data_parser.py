import os
import sys
from test_name import get_test_name

line_number = 0


def data_parse_error(message):
    global line_number
    sys.stderr.write("Error on line #%d: %s\n" % (line_number, message))
    exit(1)


class DataVisitor:
    def __init__(self):
        pass

    def on_include(self, testset_name, included_testset):
        pass

    def on_test(self, testset_name, test_name, line):
        pass

    def on_testset(self, testset_name):
        pass

    def on_subtask(self, subtask_name):
        pass


def parse_data(data, visitor):
    global line_number
    line_number = 0

    testset_index, testset_name = -1, None
    subtask_index, subtask_counter = -1, -1
    test_index, test_offset = 1, -1

    for line in data:
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
                visitor.on_testset(testset_name)
                if command == "@subtask":
                    visitor.on_subtask(testset_name)
                    subtask_counter += 1
                    subtask_index = subtask_counter
                else:
                    subtask_index = -1
            elif command == "@include":
                if testset_index < 0:
                    data_parse_error("No subtask/testset is defined.")

                for included_testset in args:
                    visitor.on_include(testset_name, included_testset)
            else:
                data_parse_error("Unknown command %s" % command)
        else:
            if testset_index < 0:
                data_parse_error("No subtask/testset is defined.")

            test_name = get_test_name(
                testset_name=testset_name,
                testset_index=testset_index,
                subtask_index=subtask_index,
                test_index=test_index,
                test_offset=test_offset,
                line=line,
            )

            visitor.on_test(testset_name, test_name, line)

            test_index += 1
            test_offset += 1


class TestsVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests = set()

    def on_test(self, testset_name, test_name, line):
        self.tests.add(test_name)

    def has_test(self, test_name):
        return test_name in self.tests


def check_test_exists(gen_data, test_name):
    tests_visitor = TestsVisitor()
    parse_data(gen_data, tests_visitor)
    if not tests_visitor.has_test(test_name):
        sys.stderr.write("Invalid test name '%s'\n" % test_name)
        exit(2)