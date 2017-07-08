import json
import os
import sys

SOLUTIONS_JSON = os.environ.get('solutions_json')


if __name__ == '__main__':
    with open(SOLUTIONS_JSON, 'r') as f:
        data = json.load(f)
        model_solutions = [solution for solution in data.keys() if data[solution]['verdict'] == 'model_solution']
    if len(model_solutions) != 1:
        sys.stderr.write("There should be exactly one model solution in '%s'" % os.path.basename(SOLUTIONS_JSON))
        exit(3)

    print(model_solutions[0])
