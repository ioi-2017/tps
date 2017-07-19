# Task Preparation System (TPS)

Version 1.0

Host Technical Committee, Host Scientific Committee

IOI 2017, Tehran, Iran

# Prerequisites

It is recommended to install bash completion if it is not already installed (there is a manual for OS/X [here](http://davidalger.com/development/bash-completion-on-os-x-with-brew/)).

TPS currently supports C++, Pascal and Java. The `gcc` compiler is mandatory, and `fpc` (free pascal) and java compilers are required if there are invocations of those languages.

Python (2 or 3) is required.

The system should support make command (for Makefiles).

# TPS interfaces

The TPS has two interfaces: a git interface that is ideal for those who love terminal, and a web interface with a GUI. Currently the web interface is read-only, hence any changes to the task statement or test material should be done through the git interface. The main functionality of the web interface is to invoke solutions over the whole set of tests to see how they perform on the real contest machines, in parallel.

The following sections describe these interfaces.

# git and terminal interface

You can login to [http://tps.ioi2017.org/git](http://tps.ioi2017.org/git), go to any task and use the (SSH) address to clone the task. It is helpful to go to Settings (from the top-right corner) and add public ssh keys in `SSH Keys` tab to bypass all password prompts in the future. SSH keys can be generated using `ssh-keygen` command.

To install the TPS terminal interface, clone the common/scripts repository and install it using the following commands:

```
git clone ssh://git@tps.ioi2017.org:10022/common/scripts.git
cd scripts
./install-tps.sh
```

Windows users can download the zip file directly, extract it and run `install-tps.bat`.

To clone the task *mountains* for instance, open terminal and run:

```
git clone ssh://git@tps.ioi2017.org:10022/practice/mountains.git
```

A new folder `mountains` will be created that contains the statement and all test material of the task. Here is a brief description of files and subfolders in each task folder:


## problem.json

This file contains the general description of the task. It has several attributes:

`name`: The short name of the task.

`code`: A unique code assigned to each task in the TPS web-interface. Usually it is the same as the `name`, but is reserved in case the `name` is changed.

`title`: Task title, as appears in the task statement.

`type`: Task type, that can be `Batch`, `Communication`, `OutputOnly`, `TwoSteps`.

`time_limit`: A real number, the maximum CPU time (in seconds) of the main process (does not include CPU time of manager or IO).

`memory_limit`: the maximum memory that can be used by the main process, in MB.

`description`: An optional description of the task.

Below is a sample `problem.json`:

```
{
 "name": "mountains",
 "code": "mountains",
 "title": "Mountains",
 "memory_limit": 256,
 "time_limit": 1.0,
 "type": "Batch",
 "description": "Find maximum number of Deevs"
}
```

## gen/

All the required files for generating test data are here. 
It contains `testlib.h`, `Makefile`, and all the codes that are used to generate the test data. 
It can contain a folder `manual` that contains manually created test data, so that they can be used in `gen/data`.

## gen/data

This file contains the arguments used to generate test data, and their mapping to the subtasks. It is separated into several test-sets. Each test-set can include other test-sets by a line starting with `@include`. A test-set can be an actual subtask (`@subtask`), or just a test-set (`@testset`) that can be included in the other subtasks. Below is an example:

```
@subtask samples
manual sample-01.in
manual sample-02.in
#uses a manually generated test from manual folder

# a comment is here
@testset ABC
gencode random 2
#another comment
gencode slow_up 19 asdgs

@subtask 2^n
gencode slow_up 19 sfgrev
@include ABC
gencode wall-envlope 19
gencode semi-manual 19
gencode magic 19
manual man-01.in

@testset apple
gencode random 40 qwetf
gencode sqr 40 cefut
gencode random 40 sadfa

@subtask bt
@include 2^n apple
#inclusion is transitive, so it also includes ABC
gencode magic 40

@subtask full
@include bt
gencode random 1000 ovuef
gencode random 2000 ocewu
gencode magic 2000
```

## grader/

This folder contains the program that have the main routine, which will be compiled with a solution or contestant's source code and call its functions. It contains one folder for each programming language (cpp/pas/java), which contains a specific grader for that language. The `cpp` folder usually contains a `.h` interface file that is included in grader (and possibly in contestant's program). It contains the graders that are used by the judging system. The public grader, which is given to the contestants during the contest, can be the same as this graders, or can be automatically created from the grader by removing the secret parts, which are bounded between `// BEGIN SECRET` and `// END SECRET` lines, or can be prepared separately.

## checker/

It contains a program, `checker.cpp`, that takes the input, output and answer of a test and checks if the output is correct or wrong, or evaluates the output in partial-scoring tasks. It also contains `testlib.h` that the checker file usually uses.

## solution/

It contains all solutions that are prepared and used in develepment of the task, for different programming languages (all in the same folder). Each solution has a verdict that are listed in `solutions.json` file.

## solutions.json

The verdict of each solution. It is used by the web-interface to check if the behavior of each solution is expected on the test data. The verdicts can be `correct`, `time_limit`, `memory_limit`, `incorrect`, `runtime_error`, `failed`, `time_limit_and_runtime_error`, `partially_correct`.
Below is an example:

```
{
	"mountains-haghani-solution.cpp": {"verdict": "model_solution"},
	"mountain.cpp": {"verdict": "correct"},
	"greedy.cpp": {
		"verdict": "incorrect",
		"except": {"samples": "correct", "n2": "time_limit"}
	}
}
```

## validator/

This folder contains validators for the whole set of test data (global validators), or for each/multiple subtask(s), and a Makefile for compiling validators. It also contains `testlib.h` that the validators usually use.


## subtasks.json

It contains the list of all subtasks, the score of each subtask, and a mapping between validators and subtasks. The total scores should be 100. Below is an example:

```
{
       "global_validators": ["validator.cpp"],
       "subtasks": {
               "samples": {
                       "index": 0,
                       "score": 0,
                       "validators": []
               },
               "2^n": {
                       "index": 1,
                       "score": 20,
                       "validators": ["sub1_validator.cpp"]
               },
               "bt": {
                       "index": 2,
                       "score": 20,
                       "validators": ["sub2_validator.cpp"]
               },
               "n3": {
                       "index": 3,
                       "score": 30,
                       "validators": ["sub3_validator.cpp"]
               },
               "full": {
                       "index": 4,
                       "score": 30,
                       "validators": []
               }
       }
}
```

## statement/

This folder contains the task statement, in markdown format. The main file is `index.md`, from which html file and other formats will be created. The pictures can be placed here as well.

## tests/

After running generator (using `tps gen`) it will contain all the test data (both input and output files). It also will contain a file `mapping` that contains, for each test, a line consisting names of a subtask and a test. The same test can be mapped to multiple subtasks. This mapping is used during the validation of test cases, and also by CMS.

## sanbox/

A folder that is used to compile solutions, and run them over the test data. It is not synced with git.

## logs/

Contains all compile and run logs.

## scripts/

All the scripts used by the TPS are stored here.

## public/

All the public graders, example test data, sample source codes and compile scripts to be given to the contestant are stored here.

# TPS commands

In addition to the normal git commands (e.g. clone, pull, commit, push, merge), the TPS provides a `tps` command with bash auto-completion functionality.

Here is the usage:
```
tps <command> <arguments>...
```

Below are the list of commands that can be use with `tps`:

## analyze

This will open the TPS web interface on the same commit, to verify the directory structure, to generate the test data, and to use the other functionalities of the web interface from the left menu (e.g. invocations). It will not change from this commit, even if the other people push changes.

## compile

Given a single solution code, TPS will understand its programming language, put it in the `sandbox` folder with a new name that matches the short name of the task, puts necessary grader files in sandbox (use `-p, --public` argument to copy the public grader), compiles it, and creates `exec.sh` (that runs the program based on the programming language) and `run.sh` (which handles the required pipe-handling for interactive tasks). It also looks for `scripts/templates/post_compile.sh` and runs it if the compile process is finished successfully. The hook script `post_compile.sh` is useful in some task types; for example, in `Communication` tasks, a manager file should also be compiled and put beside the grader.

## gen

Compiles generator, model-solution , and validator, and then generates and validates the test data and check model solution on them. The other arguments are:

* `-m, --model-solution=<model-solution-path>`: change the model solution.
* `-s, --sensitive`: Terminate on the first error.
* `-t, --test=<test-name>`: run the whole process for only a single test.
* `-d, --gen-data=<gen-data-file>`: use another file rather than `gen/data`.
* `--no-gen`: do not generate the tests again.
* `--no-sol`: do not run the model-solution.
* `--no-val`: do not run the validator.
* `--no-sol-comp[ile]`: do not compile model solution.
* `-h, --help`: this help info.

## invoke

This command is used to compile one solution and checker, run the solution over the test data and check its output. Here is the usage:

```
tps invoke [options] <solution-path>
```

Below are the arguments:
* `-h, --help`: this help info.
* `-s, --sensitive`: terminate on the first error.
* `-r, --show-reason`: display the reason for not being accepted, e.g. checker output
* `-t, --test=<test-name>`: invoke a single test case.
* `-d, --gen-data=<gen-data-file>`: use alternative `gen/data` file.
* `--no-check[er]`: do not run checker.
* `--no-sol-comp[ile]`: do not compile solution.
* `--no-tle`: no time limit exceeded report.
* `--time-limit=<time-limit>`: use alternative time limit in seconds.
* `--hard-time-limit=<hard-time-limit>`: solution process will be killed after the given time in seconds. Default: `<time-limit>` + 2.

## make-public

Updates the public folder that is given to the contestant. 
It contains the public graders for each language, example test data, sample solution, the compile scripts, and input tests for the output-only tasks.
The script finally creates a file `attachment.zip` which can be directly put in CMS.
The behavior of the script is specified per file in `scripts/templates/public.files`.

## verify

Verifies the directory structure, and reports error or warning messages accordingly.

## run

Runs the compiled solution in the sandbox for a given set of arguments.

# Web Interface

You can login to [https://tps.ioi2017.org](https://tps.ioi2017.org) and go to any task. There you can see the task statement and all of test materials. The test cases are only available after they are generated. For generating the test cases you should go to the analysis page and click on the generate button. During the generation you can also see the generation state by reloading the page. You may then analyze the test data using the test cases section. You may also use invocations to evaluate solutions.
