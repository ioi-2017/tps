import sys
import os
import argparse
import tempfile
import shutil
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
OUTPUT_SIZE_LIMIT = 20  # MiB

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


class DOMjudgeExporter:

    def __init__(self, temp_prob_dir):
        self.temp_prob_dir = temp_prob_dir

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


    SOLUTION_DIR_NAME = "submissions"
    STATEMENT_DIR_NAME = "problem_statement"
    CHECKER_DIR_NAME = "output_validators"
    TESTS_DIR_NAME = "data"
    SAMPLE_TESTS_DIR_NAME = os.path.join(TESTS_DIR_NAME, "sample")
    SECRET_TESTS_DIR_NAME = os.path.join(TESTS_DIR_NAME, "secret")
    VERDICT_MAP = {
        "model_solution": "accepted",
        "correct": "accepted",
        "incorrect": "wrong_answer",
        "time_limit": "timelimit",
        "memory_limit": "run_time_error",
        "runtime_error": "run_time_error"
    }


    def export_problem_global_data(self):
        task_data = load_json(os.environ.get('PROBLEM_JSON'))

        domjudge_problem_ini_file = "domjudge-problem.ini"
        domjudge_problem_ini_content = (
            """\
timelimit='{time_limit}'
""".format(
            time_limit=task_data['time_limit']
        ))
        vp.print_var(domjudge_problem_ini_file, domjudge_problem_ini_content)
        self.write_to_file(domjudge_problem_ini_file, domjudge_problem_ini_content)

        problem_yaml_file = "problem.yaml"
        problem_yaml_content = (
            """\
name: {title}
limits:
    memory: {mem_limit}
    output: {out_limit}
{validation}\
""".format(
            title=task_data['title'],
            mem_limit=task_data['memory_limit'],
            out_limit=OUTPUT_SIZE_LIMIT,
            validation=("validation: custom\n" if get_bool_environ('HAS_CHECKER') else "")
        ))
        vp.print_var(problem_yaml_file, problem_yaml_content)
        self.write_to_file(problem_yaml_file, problem_yaml_content)

    def export_statement(self):
        vp.print("Exporting Statement ...")
        STATEMENT_DIR = os.environ.get('STATEMENT_DIR')
        pdf_files = glob.glob(os.path.join(STATEMENT_DIR, "*.pdf"))
        if len(pdf_files) == 0:
            raise ExportFailureException("There is no pdf file in the statement directory")
        elif len(pdf_files) > 1:
            raise ExportFailureException("There are more than one pdf files in the statement directory")
        else:
            self.create_directory(self.STATEMENT_DIR_NAME)
            self.copy_file(
                pdf_files[0],
                os.path.join(self.STATEMENT_DIR_NAME, "problem.pdf")
            )

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
        vp.print("Copy checker builder...")
        checker_builder = os.path.join(os.environ.get('TEMPLATES'), 'exporters', 'DOMjudge', 'checker_builder.sh')
        self.copy_file(checker_builder, os.path.join(self.CHECKER_DIR_NAME, 'build'))

    def export_testcases(self):
        vp.print("Copying test data...")
        try:
            test_name_list = tu.get_test_names_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))
        available_tests, missing_tests = tu.divide_tests_by_availability(test_name_list, TESTS_DIR)
        if missing_tests:
            warn("Missing tests: " + (", ".join(missing_tests)))
        vp.print_var("available_tests", available_tests)
        try:
            subtasks_tests = tu.get_subtasks_tests_dict_from_tests_dir(TESTS_DIR)
        except tu.MalformedTestsException as e:
            raise ExportFailureException(str(e))

        sample_tests = set()
        secret_tests = set()
        SUBTASKS_JSON = os.environ.get('SUBTASKS_JSON')
        subtasks_json_data = load_json(SUBTASKS_JSON)
        subtasks_data = dict(navigate_json(subtasks_json_data, 'subtasks', SUBTASKS_JSON))
        for subtask_name, subtask_data in subtasks_data.items():
            if subtask_data['score'] > 0:
                secret_tests = secret_tests.union(subtasks_tests[subtask_name])
            else:
                sample_tests = sample_tests.union(subtasks_tests[subtask_name])
        vp.print_var("sample tests", sample_tests)
        vp.print_var("secret tests", secret_tests)
        self.create_directory(self.TESTS_DIR_NAME)
        self.create_directory(self.SAMPLE_TESTS_DIR_NAME)
        self.create_directory(self.SECRET_TESTS_DIR_NAME)
        for output_test_dir, tests in [(self.SAMPLE_TESTS_DIR_NAME, sample_tests), (self.SECRET_TESTS_DIR_NAME, secret_tests)]:
            for test_name in tests:
                if test_name in available_tests:
                    clean_test_name = make_clean_name(test_name)
                    self.copy_file(
                        os.path.join(TESTS_DIR, "{}.in".format(test_name)),
                        os.path.join(output_test_dir, "{}.in".format(clean_test_name)),
                    )
                    self.copy_file(
                        os.path.join(TESTS_DIR, "{}.out".format(test_name)),
                        os.path.join(output_test_dir, "{}.ans".format(clean_test_name))
                    )

    def export_solutions(self):
        vp.print("Exporting solutions...")
        self.create_directory(self.SOLUTION_DIR_NAME)
        SOLUTION_DIR = os.environ.get('SOLUTION_DIR')
        check_dir_exists(SOLUTION_DIR, "Solutions directory")
        SOLUTIONS_JSON = os.environ.get('SOLUTIONS_JSON')
        solutions_data = dict(load_json(SOLUTIONS_JSON))
        for solution_name, solution_data in solutions_data.items():
            verdict = solution_data.get("verdict")
            verdict_dir = self.VERDICT_MAP.get(make_clean_name(verdict)) if verdict else None
            if not verdict_dir:
                cprint(colors.WARN, "Solution {} does not have a valid verdict.".format(solution_name))
                continue
            dest_sol_dir = os.path.join(self.SOLUTION_DIR_NAME, verdict_dir)
            self.create_directory(dest_sol_dir)
            self.copy_file(
                os.path.join(SOLUTION_DIR, solution_name),
                os.path.join(dest_sol_dir, solution_name)
            )

    def export(self, with_statement_pdf):
        # We don't export generators or validators. Tests are already generated/validated.
        self.export_problem_global_data()
        if with_statement_pdf:
            self.export_statement()
        self.export_checker()
        self.export_testcases()
        self.export_solutions()


def export(file_name, with_statement_pdf):
    """
    returns the export file name
    """
    vp.print("Exporting '{}'.zip ...".format(file_name))
    with tempfile.TemporaryDirectory(prefix=file_name) as temp_root:
        vp.print_var("temp_root", temp_root)
        temp_prob_dir_name = PROBLEM_NAME
        temp_prob_dir = os.path.join(temp_root, temp_prob_dir_name)
        mkdir(temp_prob_dir)

        DOMjudgeExporter(temp_prob_dir).export(with_statement_pdf)

        archive_full_path = make_archive(
            os.path.join(temp_root, file_name),
            "zip",
            root_dir=temp_prob_dir,
        )
        final_export_file = move(archive_full_path, BASE_DIR)
        vp.print_var("final_export_file", final_export_file)
        return final_export_file

def check_zip_format_exists():
    return any(archive_format[0].lower() == 'zip' for archive_format in shutil.get_archive_formats())

def bash_completion_list(argv):
    current_token_info = bc.extract_current_token_info(argv)
    return bc.simple_argument_completion(
        current_token_info=current_token_info,
        available_options=[
            "--help",
            "--verbose",
            "--with-statement-pdf",
            "--output-name=",
        ],
        enable_file_completion=False,
        option_value_completion_functions={
            ("-o", "--output-name"):
                bc.empty_completion_function,
        },
    )


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--bash-completion':
        sys.argv.pop(1)
        bc.print_all(bash_completion_list(sys.argv))
        sys.exit(0)

    parser = argparse.ArgumentParser(
        prog="tps export DOMjudge",
        description="Exporter for DOMjudge -- Contest Management System for ICPC.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Prints verbose details on values, decisions, and commands being executed.",
    )
    parser.add_argument(
        "--with-statement-pdf",
        action="store_true",
        help="Upload statement pdf file (If only one pdf file exists in `statement` directory).",
    )
    parser.add_argument(
        "-o", "--output-name",
        metavar="<export-output-name>",
        help="Creates the export output with the given name.",
    )
    args = parser.parse_args()

    if not check_zip_format_exists():
        cprint(colors.FAIL, "Exporting failed: ZIP format is not available")
        return

    vp.enabled = args.verbose
    task_data = load_json(os.environ.get('PROBLEM_JSON'))
    file_name = args.output_name if args.output_name else task_data['name']

    try:
        export_file = export(file_name, args.with_statement_pdf)
        if warnings:
            cprint(colors.WARN, "Successfully exported to '{}', but with warnings.".format(export_file))
        else:
            cprint(colors.SUCCESS, "Successfully exported to '{}'.".format(export_file))
    except ExportFailureException as e:
        cprint(colors.FAIL, "Exporting failed: {}".format(e))


if __name__ == '__main__':
    main()
