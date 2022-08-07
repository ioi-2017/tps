# TPS Technical Documentation

The audience of this document are developers and maintainers of TPS codes.
The purpose is sharing the technical experience, code styles, etc.
We assume that
 the audience has already studied [the general documentation](README.md)
 and is familiar with the task directory structure and TPS commands.



## Python code style

For python codes,
 our approach is to follow PEP 8
 wherever possible.


## Bash code style

### Indentation

In the current code style,
 the bash scripts are indented with tabs.
We would use spaces for indentation
 if we had the current experience.
But let's keep the current indentation style consistent.
We may later change this policy.


### Error handling

We usually start the bash scripts with
```
set -euo pipefail
```
This helps a lot in detecting programming errors in bash.


We use `||` instead of `if !`
 whenever the code becomes more elegant.
For example, instead of this:
```
if ! [ -d "a_dir" ]; then
    mkdir "a_dir"
fi
```
we use this (note the line breaking and indentation):
```
[ -d "a_dir" ] ||
    mkdir "a_dir"
```

But we do **NOT** use `&&` instead of `if`.
Because it may cause some problems.
Here is an example:
```
set -euo pipefail
function delete_if_needed {
    [ -f "a_file" ] &&
        rm "a_file"
}
delete_if_needed
echo "This line of code is not reached."
```




### Strings and Variables

We put many string values in quotation marks,
 although technically not needed:
```
echo "hi" > "/dev/null"
```

Our style for referring bash variables is in this form:
```
echo "${a_var_name}"
```
It is discouraged to use these forms,
 although working:
```
echo $a_var_name
echo ${a_var_name}
echo "$a_var_name"
```

An exception is when
 we want to split a string by white space.
Example:
```
l="a b c"
for x in ${l}; do
    echo "${x}"
done
```


Array variables are a little tricky.
In some (older) versions of bash,
 empty array variables are considered undefined
 and produce unbound error with `set -u`
 if being iterated or passed as arguments.
Here is an example:
```
set -euo pipefail
my_arr=()
# my_arr+=('aa')
```
This style does not work in all environments:
```
echo "${my_arr[@]}"
for x in "${my_arr[@]}"; do
  echo "${x}"
done
```
This style works in all environments:
```
echo ${my_arr[@]+"${my_arr[@]}"}
for x in ${my_arr[@]+"${my_arr[@]}"}; do
  echo "${x}"
done
```

We make constant variables `readonly`:
```
readonly x="abc"
# or
x="abc"
readonly x
```

Make sure to use `local` for variables
 that are private to functions:
```
function f {
  local x="abc"
  # or
  local x
  x="abc"
}
```

Use both `local` and `readonly` together when possible:
```
function f {
  local -r x="abc"
  # or
  local x
  x="abc"
  readonly x
}
```

Our general method for using function arguments
 is to first extract them as local variables
 using the pattern
 `local -r arg_name="$1"; shift`.
Example:
```
function file_exists {
	local -r file_path="$1"; shift
  [ -f "${file_path}" ]
}
```

### Subshells

We use parentheses instead of back-quotes
 for command substitution.
Here is an example:
```
# Use this:
x="$(echo "abc")"
# Do NOT use this:
x=`echo abc`
```
Note the quotation marks around `$(...)`.
It helps keeping a correct value of the string
 in case of white spaces in the value.


In order to leverage `set -e`,
 we try to avoid multiple subshells
 in a single line of bash script.
So, instead of these:
```
echo "$(command_a)"

export b="$(command_b)"

echo "abc" | command_c

function f {
    local -r x="$(command_a)"
}
```
we use these:
```
result_a="$(command_a)"
echo "${result_a}"

b="$(command_b)"
export b

command_c <<< "abc"

function f {
    local x
    x="$(command_a)"
    readonly x
}
```
so that the exit code of each command is verified by bash.
Note that pipes also create subshells.
