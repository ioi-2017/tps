import sys
import os

from util import load_json


SOLUTIONS_JSON = os.environ.get('SOLUTIONS_JSON')


if __name__ == '__main__':
    solutions_data = load_json(SOLUTIONS_JSON)
    model_solutions = []
    for solution in solutions_data.keys():
        if solutions_data[solution].get('verdict') == 'model_solution':
            model_solutions.append(solution)
    if len(model_solutions) != 1:
        sys.stderr.write("There should be exactly one model solution in '%s'\n" % os.path.basename(SOLUTIONS_JSON))
        sys.exit(3)

    print(model_solutions[0])
