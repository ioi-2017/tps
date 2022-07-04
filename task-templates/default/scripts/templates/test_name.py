
def get_test_name(task_data, testset_name, testset_index, subtask_index, test_index, test_offset, gen_line): #pylint: disable=too-many-arguments
    #pylint: disable=unused-argument
    if task_data['type'] == "OutputOnly":
        return "%02d" % test_index
    return (testset_name if subtask_index < 0 else str(subtask_index)) + "-%02d" % test_offset
