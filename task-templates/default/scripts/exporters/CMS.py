import sys
import os
from datetime import datetime
import argparse
import tempfile
import shutil
import json
import subprocess
import glob

from util import load_json, get_bool_environ
from color_util import cprint, colors
import bash_completion as bc
from verbose import VerbosePrinter
from json_extract import navigate_json
import tests_util as tu


def make_clean_name(name):
    return name.replace(' ', '_').lower()



PROBLEM_NAME = os.environ.get('PROBLEM_NAME')
BASE_DIR = os.environ.get('BASE_DIR')
TESTS_DIR = os.environ.get('TESTS_DIR')


warnings = []

def warn(message):
    warnings.append(message)
    cprint(colors.WARN, message)


vp = VerbosePrinter()


class ExportFailureException(Exception):
    pass


def check_dir_exists(dir_name, title):
    if not os.path.exists(dir_name):
        raise ExportFailureException("{} not found: '{}'.".format(title, dir_name))
    if not os.path.isdir(dir_name):
        raise ExportFailureException("{} not a valid directory: '{}'.".format(title, dir_name))


def wrapped_run(func_name, func):
    def f(*args, **kwargs):
        try:
            return vp.run(func_name, func, *args, **kwargs)
        except (OSError, IOError):
            raise ExportFailureException("Error in calling {}".format(vp.func_repr(func_name, *args, **kwargs)))
    return f

mkdir = wrapped_run("mkdir", os.mkdir)
makedirs = wrapped_run("makedirs", os.makedirs)
copyfile = wrapped_run("copyfile", shutil.copyfile)
move = wrapped_run("move", shutil.move)
make_archive = wrapped_run("make_archive", shutil.make_archive)


class JSONExporter:

    def __init__(self, temp_prob_dir, protocol_version):
        self.temp_prob_dir = temp_prob_dir
        self.protocol_version = protocol_version

    def get_absolute_path(self, path):
        return os.path.join(self.temp_prob_dir, path)

    def create_directory(self, path):
        absolute_path = self.get_absolute_path(path)
        makedirs(absolute_path, exist_ok=True)

    def write_to_file(self, path, content):
        absolute_path = self.get_absolute_path(path)
        if isinstance(content, str):
            file_ = open(absolute_path, "w")
        else:
            file_ = open(absolute_path, "wb")
        file_.write(content)
        file_.close()

    def copy_file(self, file, relative_dest):
        absolute_dest = self.get_absolute_path(relative_dest)
        copyfile(file, absolute_dest)


    GRADER_DIR_NAME = "graders"
    MANAGER_DIR_NAME = GRADER_DIR_NAME
    CHECKER_DIR_NAME = "checker"
    TESTS_DIR_NAME = "tests"
    SUBTASKS_DIR_NAME = "subtasks"
    SOLUTION_DIR_NAME = "solutions"


    def _get_task_type_parameters(self, task_data, task_type):
        if self.protocol_version == 1:
            task_type_params = task_data.get("type_params", {})

            if task_type == "Communication":
                num_processes = task_data.get("num_processes")
                if num_processes is not None:
                    task_type_params["task_type_parameters_Communication_num_processes"] = num_processes

            if task_type == "Batch":
                HAS_GRADER = get_bool_environ("HAS_GRADER")
                if HAS_GRADER:
                    compilation_type = "grader"
                else:
                    compilation_type = "alone"
                task_type_params["task_type_parameters_Batch_compilation"] = compilation_type

            return json.dumps(task_type_params)

        # self.protocol_version > 1

        if "task_type_parameters" in task_data:
            # Task type parameters list is manually set in PROBLEM_JSON.
            return task_data["task_type_parameters"]

        HAS_GRADER = get_bool_environ("HAS_GRADER")
        HAS_CHECKER = get_bool_environ('HAS_CHECKER')
        evaluation_type = "comparator" if HAS_CHECKER else "diff"

        if task_type == 'Batch':
            compilation = "grader" if HAS_GRADER else "alone"
            input_filename = ""
            output_filename = ""
            return [
                compilation,
                [input_filename, output_filename,],
                evaluation_type,
            ]

        if task_type == 'Communication':
            num_processes = task_data.get("num_processes", 1)
            compilation = "stub" if HAS_GRADER else "alone"
            user_io = task_data.get("user_io", "fifo_io")
            return [
                num_processes,
                compilation,
                user_io,
            ]

        if task_type == 'TwoSteps' or task_type == 'OutputOnly':
            return [evaluation_type]

        return []


    def export_problem_global_data(self):
        json_file = "problem.json"
        vp.print("Writing '{}'...".format(json_file))
        PROBLEM_JSON = os.environ.get('PROBLEM_JSON')
        task_data = load_json(PROBLEM_JSON)

        task_type = task_data["type"]
        vp.print_var("task_type", task_type)

        problem_data_dict = {
            "protocol_version": self.protocol_version,
            "code": task_data["name"],
            "name": task_data["title"],
            "time_limit": task_data["time_limit"],
            "memory_limit": task_data["memory_limit"]*1024*1024,
            "score_precision": task_data.get("score_precision", 2),
            "task_type": task_type,
            "task_type_params": self._get_task_type_parameters(task_data, task_type),
        }

        if "score_mode" in task_data:
            problem_data_dict["score_mode"] = task_data["score_mode"]

        problem_data_str = json.dumps(problem_data_dict)
        vp.print_var(json_file, problem_data_str)
        self.write_to_file(json_file, problem_data_str)

    def export_statement(self):
        #pylint: disable=no-self-use, fixme
        # TODO
        vp.print("Statement is not exported.")

    def export_graders(self):
        HAS_GRADER = get_bool_environ('HAS_GRADER')
        if not HAS_GRADER:
            vp.print("No graders to export.")
            return
        vp.print("Exporting graders...")
        GRADER_DIR = os.environ.get('GRADER_DIR')
        check_dir_exists(GRADER_DIR, "graders directory")
        self.create_directory(self.GRADER_DIR_NAME)
        HAS_LANG_CPP = get_bool_environ('HAS_LANG_CPP')
        HAS_LANG_JAVA = get_bool_environ('HAS_LANG_JAVA')
        HAS_LANG_PASCAL = get_bool_environ('HAS_LANG_PASCAL')
        HAS_LANG_PYTHON = get_bool_environ('HAS_LANG_PYTHON')
        GRADER_NAME = os.environ.get('GRADER_NAME')
        grader_files = []
        if HAS_LANG_CPP:
            grader_files += [
                "cpp/{}.cpp".format(GRADER_NAME),
                "cpp/{}.h".format(PROBLEM_NAME),
            ]
        if HAS_LANG_JAVA:
            grader_files += [
                "java/{}.java".format(GRADER_NAME),
            ]
        if HAS_LANG_PYTHON:
            grader_files += [
                "py/{}.py".format(GRADER_NAME),
            ]
        if HAS_LANG_PASCAL:
            grader_files += [
                "pas/{}.pas".format(GRADER_NAME),
                "pas/{}lib.pas".format(GRADER_NAME),
            ]
        for grader_file in grader_files:
            grader_file_path = os.path.join(GRADER_DIR, grader_file)
            if os.path.isfile(grader_file_path):
                self.copy_file(
                    grader_file_path,
                    os.path.join(self.GRADER_DIR_NAME, os.path.basename(grader_file))
                )
            else:
                vp.print("Grader file '{}' does not exist.".format(grader_file))

    def export_manager(self):
        HAS_MANAGER = get_bool_environ('HAS_MANAGER')
        if not HAS_MANAGER:
            vp.print("No manager to export.")
            return
        vp.print("Exporting manager...")
        MANAGER_DIR = os.environ.get('MANAGER_DIR')
        check_dir_exists(MANAGER_DIR, "Manager directory")
        manager_files = []
        for p in ["*.cpp", "*.h"]:
            manager_files += glob.glob(os.path.join(MANAGER_DIR, p))
        self.create_directory(self.MANAGER_DIR_NAME)
        for f in manager_files:
            self.copy_file(f, os.path.join(self.MANAGER_DIR_NAME, os.path.basename(f)))

    def export_checker(self):
        HAS_CHECKER = get_bool_environ('HAS_CHECKER')
        if not HAS_CHECKER:
            vp.print("No checker to export.")
            return
        vp.print("Exporting checker...")
        CHECKER_DIR = os.environ.get('CHECKER_DIR')
        check_dir_exists(CHECKER_DIR, "Checker directory")
        checker_files = []
        for p in ["*.cpp", "*.h"]:
            checker_files += glob.glob(os.path.join(CHECKER_DIR, p))
        self.create_directory(self.CHECKER_DIR_NAME)
        for f in checker_files:
            self.copy_file(f, os.path.join(self.CHECKER_DIR_NAME, os.path.basename(f)))

    def export_testcases(self):
        vp.print("Copying test data...")
        try:
            test_name_list = tu.get_test_names_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))
        vp.print_var("test_name_list", test_name_list)
        available_tests, missing_tests = tu.divide_tests_by_availability(test_name_list, TESTS_DIR)
        if missing_tests:
            warn("Missing tests: "+(", ".join(missing_tests)))
        vp.print_var("available_tests", available_tests)

        self.create_directory(self.TESTS_DIR_NAME)
        for test_name in available_tests:
            clean_test_name = make_clean_name(test_name)
            self.copy_file(
                os.path.join(TESTS_DIR, "{}.in".format(test_name)),
                os.path.join(self.TESTS_DIR_NAME, "{}.in".format(clean_test_name)),
            )
            self.copy_file(
                os.path.join(TESTS_DIR, "{}.out".format(test_name)),
                os.path.join(self.TESTS_DIR_NAME, "{}.out".format(clean_test_name))
            )

    def export_subtasks(self):
        vp.print("Exporting subtasks...")
        try:
            subtasks_tests = tu.get_subtasks_tests_dict_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))

        self.create_directory(self.SUBTASKS_DIR_NAME)
        SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
        subtasks_json_data = load_json(SUBTASKS_JSON)
        subtasks_data = dict(navigate_json(subtasks_json_data, 'subtasks', SUBTASKS_JSON))
        for subtask_name, subtask_data in subtasks_data.items():
            vp.print("Export subtask: {}".format(subtask_name))
            self.write_to_file(
                os.path.join(
                    self.SUBTASKS_DIR_NAME,
                    "{subtask_index:02}-{subtask_name}.json".format(subtask_index=subtask_data['index'], subtask_name=subtask_name)
                ),
                json.dumps(
                    {
                        "score": subtask_data['score'],
                        "testcases": [
                            make_clean_name(t)
                            for t in subtasks_tests[subtask_name]
                        ]
                    }
                )
            )

    def export_solutions(self):
        vp.print("Exporting solutions...")
        self.create_directory(self.SOLUTION_DIR_NAME)
        SOLUTION_DIR = os.environ.get('SOLUTION_DIR')
        check_dir_exists(SOLUTION_DIR, "Solutions directory")
        SOLUTIONS_JSON = os.environ.get('SOLUTIONS_JSON')
        solutions_data = dict(load_json(SOLUTIONS_JSON))
        for solution_name, solution_data in solutions_data.items():
            verdict = solution_data.get("verdict", None)
            verdict_dir = make_clean_name(verdict) if verdict else "unknown_verdict"
            dest_sol_dir = os.path.join(self.SOLUTION_DIR_NAME, verdict_dir)
            self.create_directory(dest_sol_dir)
            self.copy_file(
                os.path.join(SOLUTION_DIR, solution_name),
                os.path.join(dest_sol_dir, solution_name)
            )

    def export_public_attachment(self):
        PUBLIC_DIR = os.environ.get('PUBLIC_DIR')
        if os.path.isdir(PUBLIC_DIR):
            vp.print("Exporting public data...")
            SCRIPTS = os.environ.get('SCRIPTS')
            make_public_script = os.path.join(SCRIPTS, 'make-public.sh')
            if not os.path.isfile(make_public_script):
                raise ExportFailureException("The 'make-public' script is not available: '{}'".format(make_public_script))
            vp.print("Running make-public script...")
            try:
                subprocess.run(['bash', make_public_script], check=True, capture_output=(not vp.enabled))
            except subprocess.CalledProcessError as e:
                message = "Error in making public attachment.\n{}\n".format(str(e))
                if not vp.enabled:
                    message += "make-pubic stdout:\n{}\nmake-pubic stderr:\n{}\n".format(e.stdout.decode(), e.stderr.decode())
                raise ExportFailureException(message)
            self.create_directory("attachments")
            move(
                os.path.join(BASE_DIR, "{}.zip".format(PROBLEM_NAME)),
                self.get_absolute_path("attachments")
            )
        else:
            warn("No public attachment data!")

    def export(self):
        # We don't export generators or validators. Tests are already generated/validated.
        self.export_problem_global_data()
        self.export_statement()
        self.export_graders()
        self.export_manager()
        self.export_checker()
        self.export_testcases()
        self.export_subtasks()
        self.export_solutions()
        self.export_public_attachment()



def create_export_file_name():
    return "{prob_name}-{export_format}-{date}".format(
        prob_name=PROBLEM_NAME,
        export_format="CMS",
        date=datetime.now().strftime("%y-%m-%d-%H-%M-%S%z")
    )


NO_ARCHIVE_FORMAT = 'none'

def get_archive_formats():
    return [(NO_ARCHIVE_FORMAT, "No archiving; export as a directory")] + shutil.get_archive_formats()

def get_archive_format_names():
    return [f[0] for f in get_archive_formats()]


def export(file_name, archive_format, protocol_version):
    """
    returns the export file name
    """
    vp.print("Exporting '{}' with archive format '{}'...".format(file_name, archive_format))
    vp.print_var("protocol_version", protocol_version)
    with tempfile.TemporaryDirectory(prefix=file_name) as temp_root:
        vp.print_var("temp_root", temp_root)
        temp_prob_dir_name = PROBLEM_NAME
        temp_prob_dir = os.path.join(temp_root, temp_prob_dir_name)
        mkdir(temp_prob_dir)

        JSONExporter(temp_prob_dir, protocol_version).export()

        if archive_format == NO_ARCHIVE_FORMAT:
            final_export_file = move(
                temp_prob_dir,
                os.path.join(BASE_DIR, file_name),
            )
        else:
            archive_full_path = make_archive(
                os.path.join(temp_root, file_name),
                archive_format,
                root_dir=temp_root,
                base_dir=temp_prob_dir_name,
            )
            final_export_file = move(archive_full_path, BASE_DIR)
        vp.print_var("final_export_file", final_export_file)
        return final_export_file


def bash_completion_list(argv):
    current_token_info = bc.extract_current_token_info(argv)
    return bc.simple_argument_completion(
        current_token_info=current_token_info,
        available_options=[
            "--help",
            "--verbose",
            "--output-name=",
            "--archive-format=",
        ],
        enable_file_completion=False,
        option_value_completion_functions={
            ("-o", "--output-name"):
                bc.empty_completion_function,
            ("-a", "--archive-format"):
                bc.simple_option_value_completion_function(get_archive_format_names),
        },
    )


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--bash-completion':
        sys.argv.pop(1)
        bc.print_all(bash_completion_list(sys.argv))
        sys.exit(0)

    parser = argparse.ArgumentParser(
        prog="tps export CMS",
        description="Exporter for CMS -- Contest Management System for IOI.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        'protocol_version',
        metavar='<protocol-version>',
        type=int,
        choices=[1, 2],
        help="""\
The protocol version of the exported package
Currently available versions:
1  The traditionally-used protocol (used up to 2022).
2  Supports more flexible setting of task type parameters (defined in 2022).
Make sure the target CMS server supports the specified protocol version.
"""
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Prints verbose details on values, decisions, and commands being executed.",
    )
    parser.add_argument(
        "-o", "--output-name",
        metavar="<export-output-name>",
        help="Creates the export output with the given name.",
    )
    parser.add_argument(
        "-a", "--archive-format",
        metavar="<archive-format>",
        choices=get_archive_format_names(),
        default="zip",
        help="""\
Creates the export archive with the given format.
Available archive formats:
{}
Default archive format is '%(default)s'.
""".format("\n".join(["  {} {}".format(f[0].ljust(10), f[1]) for f in get_archive_formats()])),
    )
    args = parser.parse_args()

    vp.enabled = args.verbose
    file_name = args.output_name if args.output_name else create_export_file_name()

    try:
        export_file = export(file_name, args.archive_format, args.protocol_version)
        if warnings:
            cprint(colors.WARN, "Successfully exported to '{}', but with warnings.".format(export_file))
        else:
            cprint(colors.SUCCESS, "Successfully exported to '{}'.".format(export_file))
    except ExportFailureException as e:
        cprint(colors.FAIL, "Exporting failed: {}".format(e))


if __name__ == '__main__':
    main()
