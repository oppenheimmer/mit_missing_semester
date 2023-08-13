# Scripting & Shell tools

## Elementary scripting

So far, we have seen how to execute individual commands and pipe them. However in many scenarios you will want to perform a series of commands and make use of control flow expressions, like `conditionals` or `loops`. We might also require `functions` for repetitive block of commands.

Shell scripts are the next logical step. Most shells have their own scripting syntax with variables and control flow. What makes shell scripting different from other programming languages is that it is optimized for performing shell-related tasks. Thus, creating command pipelines, saving results into files, and reading from standard input are primitives in shell scripting, which makes it easier to use than general purpose languages.

To assign variables in bash, consider this example

```console
~$ foo=bar 
~$ echo $foo
   bar
```

We access the value of the variable with `$` (i.e. `$varname`). The symbol `$` is a special token in shells and usually mean a certain value (either a built in feature or a variable). Note that `foo = bar` will not work since it is interpreted as calling program named `foo` with `=` and `bar` as arguments. In general, the space character performs argument splitting.

Strings in bash can be defined with `'` and `"` delimiters, but they are not equivalent. Strings delimited with `'` are *literal strings* and will not substitute value of the variable. Whereas `"` delimited strings will show the variable or token value, when invoked.

```console
~$ foo=bar
~$ echo "$foo" # prints bar
   bar
~$ echo '$foo' # prints $foo
   $foo
```

As with most programming languages, `bash` supports control flow techniques including `if`, `case`, `while` and `for`. Similarly, `bash` has functions that take arguments and can operate with them. Here is an example of a function that creates a directory with an input argument, and `cd` into it.

```bash
mcd () {
    mkdir -p "$1"
    cd "$1"
}
```

`$1` is the first argument to the function. Unlike other scripting languages, bash uses a variety of special variables to refer to arguments, error codes, and other relevant variables. Below is a brief list:

- `$0`      -   Name of the script
- `$1`-`$9` -   Arguments order to the script. `$1` is the first.
- `$@`      -   All the arguments
- `$#`      -   Number of arguments received
- `$?`      -   Return code of the previous command
- `$$`      -   Process identification number (PID) for the current script
- `!!`      -   Entire last command, including arguments.
- `$_`      -   Last argument from the last command.

For example,

```console
$ man top 
➜   
➜ echo $_
  top
➜ echo $?
  0
```

Custom created functions need to be *sourced* or added to `$PATH`. Commands will often return output using `STDOUT`, errors through `STDERR`, and a return code to report errors in a more script-friendly manner. The *return code* or *exit status* is the way commands communicate the execution status. A value of 0 usually means everything went OK; anything different from 0 means an error occurred. `True` will have 0 error code and `False` will always be 1.

Exit codes can be used to conditionally execute commands using `&&` (AND operator) and `||` (OR operator). These are short-circuit operators and the second condition in such statements are evaluated only depending on the first. (Always remember `false=1` and as soon as zero-error code is found, the command exits.)

> - For `OR` operator, the second command executes only if the first fails.
> - For `AND` operator, the second one executes if the first executed.

Commands can also be separated within the same line using a semicolon `;`. Let's see some examples

```bash
$ false || echo "Oops, fail"
# prints Oops, fail

$ true || echo "Will not be printed"
#

$ true && echo "Things went well"
# prints Things went well

$ false && echo "Will not be printed"
#

$ true ; echo "This will always run"
# prints This will always run

$ false ; echo "This will always run"
# prints This will always run
```

## Command and Process substitution

A common pattern is wanting to get the output of a command as a variable. This can be done with *command substitution*. Whenever you place `$(CMD)` it will execute `CMD`, get the output of the command and substitute it in place. For example,

```console
~$ for file in $(ls)
```

In this example, the shell will first call `ls` and store it in a variable. Then the loop iterates over values stored in that variable.

```console
~$ echo "We are in $(pwd)" # Double quotes expands value within
```

A lesser known similar feature is *process substitution*. `<(CMD)` will execute `CMD` and place the output in a temporary file & substitute the `<( )` with that temporary file's name. This is useful when commands expect values to be passed by file instead of by STDIN. For example, `diff <(ls .) <(ls ..)` will show differences between files in current directory and its parent.

> - `Command substitution`: Shell executes the command and places value in a variable to make use in other place, unless overwritten by similar invocation.
> - `Process substitution`: Shell executes command and places the value in a temporary file. The command then points to the temporary file instead of the location it originated in, for use by the shell.

```bash
#!/bin/bash

echo "Starting program at $(date)"  # Date will be substituted
echo "Running program $0 with $# arguments with pid $$"

for file in "$@"; do
    grep foobar "$file" > /dev/null 2> /dev/null
    # When pattern foobar not found, grep has exit status 1
    # We redirect STDOUT and STDERR to a null register since we do 
    # not care about them

    if [[ $? -ne 0 ]]; then
        echo "File $file does not have any foobar, adding one"
        echo "# foobar" >> "$file"
    fi
done
```

### Notes

- In the comparison we tested whether `$?` was not equal to 0. Bash implements many comparisons of this sort - we can find a detailed list in the manpage for `test`

- When performing comparisons in bash, try to use double brackets `[[ ]]` in favor of simple brackets `[ ]`. Chances of making mistakes are lower although it won't be portable to `sh`.

- When launching scripts, often we require arguments that are similar in pattern. `bash` has ways of making this easier, expanding expressions by carrying out filename expansion. These techniques are often referred to as shell *globbing*.

- **Wildcard**: Whenever you want to perform some sort of wildcard matching, you can use `?` and `*` to match one or any amount of characters respectively. For instance, given files `foo`, `foo1`, `foo2`, `foo10` and `bar`, the command `rm foo?` will delete `foo1` and `foo2` whereas `rm foo*` will delete all but `bar`.

- **Brace expansion**: `{}` Whenever you have a common substring in a series of commands, you can use curly braces for bash to expand this automatically. This comes in very handy when moving or converting files.

```bash
convert image.{png,jpg}
# Will expand to
# convert image.png image.jpg

cp /path/to/project/{foo,bar}.sh /newpath
# Will expand to
# cp /path/to/project/foo.sh /newpath
# cp /path/to/project/bar.sh /newpath

# Globbing techniques can also be combined
mv *{.py,.sh} folder/
# Will move all *.py and *.sh files to folder

mkdir foo bar
touch {foo,bar}/{a..h}
touch foo/x bar/y
# This creates files foo/a, foo/b, ... foo/h, bar/a, bar/b, ... bar/h
# and then x under foo, and y under bar

# Show differences between files in foo and bar
diff <(ls foo) <(ls bar)
```

## Scripting Tools

Writing `bash` scripts can be tricky and unintuitive. There are tools like [shellcheck](https://github.com/koalaman/shellcheck) that will help you find errors in your shell scripts.

Note that scripts need not necessarily be written in bash to be called from the terminal. For instance, here's a simple Python script that outputs its arguments in reversed order:

```python
#!/usr/bin/env python
import sys
for arg in reversed(sys.argv[1:]):
    print(arg)
```

The kernel knows to execute this script with a python interpreter instead of a shell command because we included a shebang `#!`. It is good practice to write shebang lines using the `env` command that will resolve to wherever the command lives, increasing the portability. To resolve the location, `env` will make use of the `PATH` environment variable, instead of any hardcoded path. So depending on the current environment, it could point to `/usr/bin/python` or the python inside a `anaconda` or `virtualenv` binary store.

Some differences between shell functions and scripts that is worth remembering:

- Shell Functions have to follow the shell syntax , while scripts can be written in any language e.g. Python. This is why including a shebang for scripts is important.

- Functions are loaded once when their definition is read by environment (i.e. by source or $PATH initialization). Scripts are loaded every time they are executed. This makes functions slightly faster, but whenever we change them, we have to reload.

- Functions are executed in the **current shell environment** whereas scripts execute in their own separate **process**. Thus, functions can modify environment variables, e.g. change your current directory, whereas scripts can't.

- As with any programming language, functions are a powerful construct to achieve modularity, code reuse, and clarity of shell code. Often shell scripts will include their own function definitions.

## Shell Tools

### Finding flags and options

You might be wondering how to find the flags and options for the commands we use. The first-order approach is to call said command with the `-h` or `--help` flags. `--help` or `-h` is often a hallmark of `bash` and may not extend always to other shells. A more detailed approach is to use the `man` command, which usually includes the full manual and also covers the manual description for special variables and token in the OS platform. [TLDR pages](https://tldr.sh/) is a nifty complementary solution to get information faster.

### Finding files

One of the most common repetitive tasks that every programmer faces is finding files or directories. All UNIX-like systems come packaged with `find` , a great shell tool to find files. `find` will recursively search for files matching some criteria. Some examples:

```bash
# Find all directories named src
find . -name src -type d

# Find all python files that have a folder named test in their path
find . -path '*/test/*.py' -type f

# Find all files modified in the last day
find . -mtime -1

# Find all zip files with size in range 500k to 10M
find . -size +500k -size -10M -name '*.tar.gz'
```

Beyond listing files, `find` can also execute over files that match your query. This property can be incredibly helpful to simplify what could be fairly monotonous tasks.

```bash
# Delete all files with .tmp extension
find . -name '*.tmp' -exec rm {} \;

# Find all PNG files and convert them to JPG
find . -name '*.png' -exec convert {} {}.jpg \;
```

Despite `find`'s ubiquitousness, its syntax can sometimes be tricky to remember. For instance, to simply find files that match some pattern `PATTERN` you have to execute `find -name '*PATTERN*'` (or `-iname` if you want the pattern matching to be case insensitive). You could start building aliases for those scenarios, but part of the shell philosophy is that it is good to explore alternatives.

- `fd` is a complement to `find` command
- `locate` uses a database that is updated using `updatedb`. In most systems, `updatedb` is updated daily via `cron`

### Finding code

Finding files by name is useful, but quite often you want to search based on some file *content*. A common scenario is wanting to search for all files that contain some pattern, along with where in those files said pattern occurs. To achieve this, most UNIX-like systems provide `grep`, a generic tool for matching patterns from the input text.

`grep` has many flags that make it a very versatile tool.

- `-C N` for getting *context* N lines before and after the match.
- `-v` for inverting the match, i.e. print lines that do **not** match.
- `-R` for recursive searching in a directory.

For now we are sticking with ripgrep (`rg`), given how fast and intuitive it is. Some examples:

```bash
# Find all python files where I used the requests library
rg -t py 'import requests'

# Find all files (including hidden files) without a shebang line
rg -u --files-without-match "^#!"

# Find all matches of foo and print 5 following lines after match
rg foo -A 5

# Print statistics of matches (# of matched lines and files )
rg --stats PATTERN
```

### Finding shell commands

So far we have seen how to find files, but as you start spending more time in the shell, you may want to find specific commands you typed at some point. The first thing to know is that typing the up arrow will give you back your last command, and if you keep pressing it you will slowly go through your shell history.

The `history` command will let you access your command history programmatically. It will print your shell history to the standard output. If we want to search there we can pipe that output to `grep`. e.g. `history | grep find` will print commands that contain the substring "*find*".

In most shells, you can make use of `Ctrl+R` to perform backwards search through your history. After pressing `Ctrl+R`, you can type a substring you want to match for commands in your history. As you keep pressing it, you will cycle through the matches in your history.

A nice addition on top of `Ctrl+R` comes with using `fzf`. `fzf` is a general-purpose fuzzy finder that can be used with many commands. It can be used to fuzzily match through your history and present results in a convenient and visually pleasing manner.

### Directory Navigation

So far, we assumed that you are already where you need to be. But how do you go about quickly navigating directories? There are many simple ways that you could do this, such as writing shell aliases or creating symlinks with `ln -s`, but the truth is that developers have figured out several sophisticated solutions by now.

Finding frequent and/or recent files and directories can be done via:

- [`fasd`](https://github.com/clvv/fasd), which allows quick access to files and directories for POSIX shells.
- [`autojump`](https://github.com/wting/autojump), the original inspiration for `fasd`.

`fasd` ranks files and directories by *frecency* i.e. by both *frequency* and *recency*. By default, `fasd` adds a `z` command that you can use to quickly `cd` using a substring of a *frecent* directory. For example, if `/home/user/files/cool_project` is used often, using `z cool` we can jump there. Using autojump, this same change of directory could be accomplished using `j cool`. More complex tools exist to quickly get an overview of a directory structure:

- [`tree`](https://linux.die.net/man/1/tree)
- [`broot`](https://github.com/Canop/broot)
- [`ranger`](https://github.com/ranger/ranger)

## Exercises

- Read `man ls` and write an `ls` command that lists files in the following manner

  - Includes all files, including hidden files
  - Sizes are listed in human readable format
  - Files are ordered by recency
  - Output is colorized

```bash
ls -lath --color=auto
```

- Write bash functions  `marco` and `polo` that do the following. Whenever you execute `marco` the current working directory should be saved in some manner, then when you execute `polo`, no matter what directory you are in, `polo` should `cd` you back to the directory where you executed `marco`.

```bash
marco() {
    export MARCO=$(pwd)
}

polo() {
    cd "$MARCO"
}

~$ Desktop source ~/marco.sh 
~$ Desktop marco 
~$ Desktop cd ../Documents 
~$ Documents polo
~$ Desktop 
```

- Say you have a command that fails rarely. In order to debug it you need to capture its output but it can be time consuming to get a failure run. Write a bash script that runs the following script until it fails and captures its standard output and error streams to files and prints everything at the end. Bonus points if you can also report how many runs it took for the script to fail.

```bash
#!/usr/bin/env bash

count=0
until [[ "$?" -ne 0 ]];
do
  count=$((count+1))
  ./random.sh &> out.txt
done

echo "found error after $count runs"
cat out.txt
```

- As we covered in the lecture `find`'s `-exec` can be very powerful for performing operations over the files we are searching for. However, what if we want to do something with all the files, like e.g. creating a zip file. As you have seen so far commands will take input from both arguments and `STDIN`. When piping commands, we are connecting `STDOUT` to `STDIN`, but some commands like `tar` take inputs from arguments. To bridge this disconnect there's the `xargs` command which will execute a command using `STDIN` as arguments. For example `ls | xargs rm` will delete the files in the current directory. Your task is to write a command that recursively finds all HTML files in the folder and makes a zip with them. Note that your command should work even if the files have spaces.

```bash
find . -type f -name "*.html" -print0 | xargs -0 zip -r html_files.zip
```

`xargs -0` takes the null-separated file names from `find`` and passes them as arguments to the next command.

- Listing files by recency?

```bash
ls -alc
```
