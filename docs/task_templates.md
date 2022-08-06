# TPS Task Templates

The audience of this document are
 TPS users who want to create a TPS task template.

A task template is used in command `tps init`
 explained in [the main documentation](README.md).

A task template is a directory similar to a task directory
 that contains a _task template instantiation script_
 ("TTIS" in short)
 named "`task-template-instantiate.sh`".
This script initiates a new task
 using its template directory.

A TTIS should follow these steps in order:
1. Prompt user for the customization parameters
  that it needs, e.g, the task title.
1. Clone the template directory
  in the output directory.
1. Modify the output directory
  based on the prompted parameters
  (e.g. set the task title in `problem.json`).
  TPS provides some utility functions
  to make modifications easier.


There is a task template `default`
 in directory `task-templates`
 of TPS git repository.
It can be used as an example and starting point
 for new task templates.

It is advised to create a task template
 that is as customizable as possible
 to avoid creating multiple redundant templates.
For example,
 file names and contents can have unique placeholders
 which will be replaced in the third step.
As in the template `default`,
 value for `title` in `problem.json`
 is set to `__TPARAM_TASK_TITLE__`
 and will be replaced
 with the value of variable `task_title` prompted in the first step.
Another example is using multiple files (or directories) in the template,
 and then choosing the proper file (or directory)
 based on the user-specified values.

The steps are described in detail in the following sections.


## Prompting parameters

TPS provides multiple utility functions for TTIS.
Among all,
 the function `prompt`
 is very handy
 in prompting the user
 for a value
 and validating their input.

The usage looks like this:
```
prompt &lt;type&gt; &lt;var-name&gt; [&lt;description&gt;]
```

This function prompts the user
 for a text of type `<type>`
 and stores it in variable `<var-name>`.
Parameter `<var-name>` must be in identifier format.
If `<description>` is provided,
 it will be shown to the user.
This function will reject invalid values
 and repeats prompting
 until a valid value is given by the user.
Then, `<var-name>` can be used
 as a bash variable in the script.

The user prompt is skipped if the variable is defined
 using `-D`/`--define` in the command-line arguments.
The user prompt is repeated
 if the entered value
 (or the predefined)
 is not valid (according to the type).

Here is an example of using `prompt`:
```
prompt bool has_grader "Are solutions linked with graders"
```

Running the above command asks the user to enter a value
with this message:

```
Template parameter 'has_grader' (Are solutions linked with graders)...
Enter a value of type 'bool' for 'has_grader':
```

If an invalid value is provided, such as `3`,
 it will ask again, like this:
```
Invalid boolean value. Valid values: true, false, yes, no, y, n
Enter a value of type 'bool' for 'has_grader':
```

Valid variable types for `<type>`:
* `string`: any string of characters
* `identifier`: common identifier format in programming languages
* `int`, `integer`: signed integer format
* `uint`, `unsigned_integer`: unsigned integer format
* `decimal`: signed decimal format for real numbers
* `udecimal`, `unsigned_decimal`: unsigned decimal format for real numbers
* `bool`: boolean values, true (`true`,`yes`,`y`) and false (`false`,`no`,`n`)
* `enum`: enum value format.
  The keyword 'enum' must be followed by the enum values
  in a format like `'enum:value1:value2:value3'`.
  The enum values must be in identifier format.


There is also another similar utility function `general_prompt`
 which is used less frequently.
It gets a `<validation-command>` instead of the argument `<type>`.
The `<validation-command>` gets and validates the user input upon entry.


## Cloning the template directory

A TTIS should call the following function after it has
 prompted the variables from the user:

```
clone_template_directory
```

This function will copy the task template
 in the specified output directory,
 and then,
 changes the current working directory
 to that output directory.


## Modifying the output directory to create a task

At this step,
 the template is copied in the output directory,
 and TTIS should modify it
 to create the desired task structure.

TPS provides a number of utility functions
 than can be used anywhere around the TTIS:

* `errcho`

  Similar to `echo` but writes to the standard error stream.

* `error_exit <exit-code> <message>`

  Writes the `<message>` and exits.

* `variable_exists <var-name>`

  Returns 0 if the variable `<var-name>` exists.

* `variable_not_exists <var-name>`

  Returns 0 if the variable `<var-name>` does not exist.

* `set_variable <var-name> <value>`

  Sets the value of variable `<var-name>` to `<value>`.

* `increment <var-name> [<value>]`

  Increments the value of variable `<var-name>` by `<value>`.
  Default value of `<value>` is `1`.

* `pushdq` and `popdq`

  Silently run commands `pushd` and `popd`.

* `is_identifier_format <text>`

  `is_unsigned_integer_format <text>`

  `is_signed_integer_format <text>`

  `is_unsigned_decimal_format <text>`

  `is_signed_decimal_format <text>`

  Return 0 if `<text>` is in the specified format.

* `command_exists <cmd-name>`

  Returns 0 if the command `<cmd-name>` exists.

* `run_python <python-command-arguments>...`

  Runs the python command, considering the existence of
  `python3`, `python`, and environment variable `PYTHON`.

* `generate_random_string <string-length> <string-character-set> <random-seed>`

  Generates a string of length `<string-length>`
  with characters of `<string-character-set>`.
  The parameter `<string-length>` must be a nonnegative integer.
  The parameter `<random-seed>` can be any string.

* `replace_exact_text <old-text> <new-text> <text-to-change>`

  Replaces `<old-text>` with `<new-text>`
  in `<text-to-change>`
  and prints the new text
  to the standard output stream.


TPS also provides the following utility functions
 that can be used to modify the output directory,
 and thus,
 they are not allowed to be called
 before the execution of function `clone_template_directory`:

* `py_regex_replace_in_files <pattern> <substitute> <file-paths>...`

  Replaces (python) regular expression `<pattern>`
  with `<substitute>`
  in the given files.

* `replace_in_file_names <old-text> <new-text> <file-paths|root-directories>...`

  Replaces `<old-text>` with `<new-text>`
  in the file names
  in the given files and directories (and their descendant children).

* `replace_in_file_contents <old-text> <new-text> <file-paths|root-directories>...`

  Replaces `<old-text>` with `<new-text>`
  in the file contents
  in the given files and directories (and their descendant children).

* `replace_in_file_names_and_contents <old-text> <new-text> <file-paths|root-directories>...`

  Replaces `<old-text>` with `<new-text>`
  in the file names and contents
  in the given files and directories (and their descendant children).

* `move_dir_contents <source-dir> <destination-dir>`

  Moves all the contents of `<source-dir>` to `<destination-dir>`.
  The hidden files are also moved.
  The `<source-dir>` is then deleted.
  The `<source-dir>` shall not be the same as,
  or a direct/indirect parent of `<destination-dir>`.

* `select_file_by_value <selected-value> <destination-path> <value1> <file1> <value2> <file2>...`

  This function gets a `<selected-value>`,
  a `<destination-path>`,
  and multiple pairs of (`<value>`, `<file>`).
  If there is a match of the
  `<selected-value>` among the `<value>`s in the pairs,
  the corresponding `<file>` in that pair
  is moved/renamed to `<destination-path>`.
  All `<file>`s in the non-matching pairs are deleted.
