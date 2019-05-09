import sys


def get_test_name(task_data, testset_name, testset_index, subtask_index, test_index, test_offset, gen_line):
    return (testset_name if subtask_index < 0 else str(subtask_index)) + "-%02d" % test_offset

if __name__ == '__main__':
    if len(sys.argv) < 8:
        sys.stderr.write("Usage: python test_name.py <task_data file (problem.json)> <testset_name> " +
                         "<testset_index> <subtask_index> <test_index> <test_offset> <gen_arguments...>")
        exit(2)

    from util import load_json
    task_data = load_json(sys.argv[1])

    test_name = get_test_name(
        task_data=task_data,
        testset_name=sys.argv[2],
        testset_index=int(sys.argv[3]),
        subtask_index=int(sys.argv[4]),
        test_index=int(sys.argv[5]),
        test_offset=int(sys.argv[6]),
        gen_line=sys.argv[7:],
    )

    print(test_name)

