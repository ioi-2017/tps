import sys


def get_test_name(testset_name, testset_index, subtask_index, test_index, test_offset, line):
    return (testset_name if subtask_index < 0 else str(subtask_index)) + "-%02d" % test_offset

if __name__ == '__main__':
    if len(sys.argv) < 7:
        sys.stderr.write("Usage: python test_name.py <testset_name> <testset_index> <subtask_index> " +
                         "<test_index> <test_offset> <gen_arguments...>")
        exit(2)

    test_name = get_test_name(
        testset_name=sys.argv[1],
        testset_index=int(sys.argv[2]),
        subtask_index=int(sys.argv[3]),
        test_index=int(sys.argv[4]),
        test_offset=int(sys.argv[5]),
        line=sys.argv[6:],
    )

    print(test_name)
