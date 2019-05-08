import os
import sys
from gen_data_parser import DataVisitor, parse_data 

class ListTestsVisitor(DataVisitor):
    def __init__(self):
        DataVisitor.__init__(self)
        self.tests = []

    def on_test(self, testset_name, test_name, line, line_number):
        self.tests.append(test_name)

    def print_tests(self, stream):
        for test in self.tests:
            stream.write("%s\n" % test)



if __name__ == '__main__':
    gen_data = sys.stdin.readlines()

    listTestsVisitor = ListTestsVisitor()
    parse_data(gen_data, listTestsVisitor)
    listTestsVisitor.print_tests(sys.stdout)
    
 
