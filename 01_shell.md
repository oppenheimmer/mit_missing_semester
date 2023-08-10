# The `shell`

## What is the `shell` ?

Computers these days have a variety of interfaces for giving them commands: graphical user interfaces, voice, and even AR/VR. These are great for the majority of use cases, but they are fundamentally restricted in what they allow you to do — you cannot press a button that isn't there or give a voice command that hasn't been programmed. To take full advantage of the tools your computer provides, we have to go old-school and drop to a textual interface: *the shell*. The shells operate on textual commands, which are composable.

Nearly all OSs you can get your hands on have a shell in one form or another, and many of them have several shells for you to choose from. While they may vary in the details, at their core they are all roughly doing the same: they allow running programs, give them input, and inspect outputs in a semi-structured way.

We will focus on the **B**ourne **a**gain **sh**ell, or `bash` for short. This is one of the most widely used shells, and its syntax is similar to what you will see in many other shells. To have a _shell prompt_ (where you can type commands), you first need a _terminal_. You might already have one installed on your computer, or you can easily install one.
 > `shell` is the textual user interface to the kernel. Shell is accessible by `shell prompt`, seen in a terminal application.

## Using the shell

When you open your terminal application, you'll see a prompt:

```console
missing:~$ 
```

This is the interface to the shell. It conveys:

- You are on the machine `missing`
- Your current working directory is `~`(or the `home`) 
- `$` tells you are not the root user. 

At this prompt, you can type commands that will execute programs (with or without arguments). The command will then be interpreted by the shell. The most basic command is to execute a program like `date`:

```console
missing:~$ date
Wed Jun  1 16:04:01 JST 2022
missing:~$ 
```

Here, we executed the `date` program, which (perhaps unsurprisingly)
prints the current date and time. The shell prompt then asks us for another
command to execute. We can execute commands with arguments too:

```console
missing:~$ echo hello
hello
```

In this case, we instructed shell to execute the program `echo` with the argument `hello`, which is separated by a whitespace. The `echo` program simply prints out its arguments. The shell parses the command by splitting it by whitespace and then runs the program indicated by the first word, supplying each subsequent word as an argument that the program can access. If you want to provide an argument that contains spaces or other special characters (e.g., a directory named "My Photos"), you can either quote the argument (with `'` or `"` e.g. `"My Photos"`) or use escape characters (e.g. `\` for `My\ Photos`).


```console
missing:~$ echo "Hello, world"
  Hello, world
missing:~$ echo 'Hello World'
  Hello World
missing:~$ echo Hello\ World
  Hello World
```

## How does the shell know ?

The shell is a programming environment, just like Python. It has some built-in programs, and features such as variables, conditionals, loops, and functions. When you run commands, you are really writing a snippet of code that the shell interprets. If the shell is asked to execute a command that doesn't match one of its programming keywords, it consults an _environment variable_ called `$PATH` that lists which directories the shell should search for programs. Environment variables are initialized when the shell starts up. For a list, you can run `compgen -e` for a list of exported variables.

```console
missing:~$ echo $PATH
  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
missing:~$ which echo
  /bin/echo
missing:~$ /bin/echo $PATH
  /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

When we run the `echo` command, the shell sees that it should execute the program `echo`, and then searches through the ':' separated list of directories in `$PATH` for a file by that name. When it finds it, it runs it (assuming the file is executable). We can find out which file is executed for a given program name using the `which` program. We can also bypass `$PATH` entirely by giving the _path_ to the file we want to execute.

> Commands are given on shell prompt. These commands execute programs (with or without arguments). The command are interpreted by the shell by looking the $PATH variable if any matching program exists.


## Navigating in the shell

A path on the shell is location of directory delimited by `/` (on Linux and macOS). On Linux and macOS, the `/` is the _root_ of the filesystem, under which all directories and files lie. A path that starts with `/` is called an _absolute_ path.

Conversely, any other path which depends on current working directory (instead of the top-level `/`) is a _relative_ path. Working directories can be viewed by  `pwd` and changed by `cd` commands respectively. 

> Relative paths use `.`, `..` and `~` extensively to navigate.

```console
missing:~$ pwd
/home/missing

missing:~$ cd /home
missing:/home$ pwd
/home

missing:/home$ cd ..
missing:/$ pwd
/

missing:/$ cd ./home
missing:/home$ pwd
/home

missing:/home$ cd missing
missing:~$ pwd
/home/missing

missing:~$ ../../bin/echo hello
hello

missing:/home$ cd ~
missing:~$
```

In general, when we run a program, it will operate in the current directory unless we tell it otherwise. For example, it will usually search for files there, and create new files there if it needs to. To make sure a program is found and executed - either we add it to the `$PATH` or we make creative use of absolute paths to make sure it is visible.

To see what lives in a given directory, we use the `ls` command:

 > `ls` takes a path as input.

```console
missing:~$ ls

missing:~$ cd ..
missing:/home$ ls
missing

missing:/home$ cd ..
missing:/$ ls
Applications Users        cores        home         sbin         var
Library      Volumes      dev          opt          tmp
System       bin          etc          private      usr
```

Things to remember,

- `~` always refers to the home directory and `cd` will bring you to home no matter where you are. Tildes can also be used as relative path e.g. `~/missing/classes/`.
- Dashes `-` will bring you to the previous directory, and is a handy way to toggle between the last used directory and current one.
- Unless a directory is given as its first argument, `ls` will print the contents of the current directory.

Many commands accept `flags` and `options` (i.e. flags with values) that start with `-` to modify their behavior. Usually, running a program with the `-h` or `--help` flag will print some help text that tells you what flags and options are available. For example using `ls --help.

```console
missing:~$ ls -l /home
drwxr-xr-x 1 sam  users  4096 Feb 8  2022 missing
```

This gives us a bunch more information about each file or directory present. First, the `d` at the beginning of the line tells us that the location is a directory. Conversely, absent that, it is a file.

Then follows three groups of three characters: These indicate what permissions the owner of the file (`sam`), the owning group (`users`), and everyone else (`others`) respectively have on the relevant item. A `-` indicates that the given principal does not have given permission. In above example, only the owner is allowed to modify (`w`) the `missing` directory.

For files,

- `r` -> Read permission. File can be read, if set
- `w` -> Write permission. File can be written or emptied, if set
- `x` -> Execute permission. File can be executable if set

For directories, 

- `r` -> scan permisssion. Principal can see inside the directory i.e. list.
- `w` -> edit permission. Moves, renames, deletion in the directory.
- `x` -> search permission. Principal allowed to enter the directory.
  
For e.g., if you have `rwx` on a file in a restricted directory, you can empty the file, but you cannot delete it i.e. change the directory structure.

Some other handy programs to know about at this point are:

- `mv` to rename or move a file; takes two paths as arguments
- `cp` to copy a file; takes source and destination arguments
- `rm` remove a file. `-r` makes it recursively delete everything 
- `mkdir` to make a new directory
- `rmdir` to remove empty directory

If you ever want more information about a program's arguments, inputs,
outputs, or how it works in general, give the `man` program a try. It
takes as an argument the name of a program, and shows you its manual
page.

## Connecting programs

We might want to chain different programs to make their utility more powerful. In the shell, programs have two primary control *streams*: `input stream` and `output stream`. When the program needs input, it reads from the input stream, and when it outputs, it sends to the output stream. Normally, a program's input and output are both your terminal. That is, your keyboard as input and your screen as output. However, we can also rewire those streams when we need to do complex things without involving us as intermediary.

The simplest form of redirection is angle brackets: `< file` and `> file`. These let you rewire the input and output streams of a program to files respectively:

```console
missing:~$ echo hello > hello.txt
missing:~$ cat hello.txt
hello

missing:~$ cat < hello.txt
hello

missing:~$ cat < hello.txt > hello2.txt
missing:~$ cat hello2.txt
hello
```

`cat` is a program that concatenates file contents. When given file names as arguments, it prints the contents of each of the files in sequence, to its output stream. (When `cat` is not given any arguments, it prints contents from its input stream to its output stream).

```console
missing:~$ cat hello.txt hello2.txt 
hello
hello
```

We can use `>>` to append to a file. Where this kind of input/output redirection really shines is in the use of _pipes_. The `|` operator lets you chain programs such that the output of one is the input of the next:

```console
missing:~$ ls -l / | tail -n1
drwxr-xr-x 1 root  root  4096 Jun 20  2019 var
```

These program do not know about each other's I/O. They are connected by a pipe redirection.


## A versatile and powerful tool

On most Unix-like systems, one user is special: the `root`, with user ID 0. The root user is above (almost) all access restrictions, and can create, read, update, and delete any file in the system. You will not usually log into your system as the root user though, since it's too easy to accidentally break something. Instead, you will be using the `sudo` command. As its name implies, it lets you "do" something "as su" (short for "super user", or "root"). When you get permission denied errors, it is usually because you need to do something as root with elevated permissions.

Where we might need such a thing? For e.g., you need to be root in order to write to the `sysfs` filesystem mounted under `/sys`. `sysfs` exposes a number of kernel parameters as files, so that you can easily reconfigure the kernel on the fly without specialized tools. For example, the brightness of your laptop's screen is exposed through a file called `brightness` (in Thinkpads):

```console
/sys/class/backlight
```

By writing a value into that file, we can change the screen brightness.
Your first instinct might be to do something like:

```console
$ sudo find -L /sys/class/backlight -maxdepth 2 -name '*bright*'
  /sys/class/backlight/thinkpad_screen/brightness
$ cd /sys/class/backlight/thinkpad_screen
$ cat max_brightness
  1060
$ sudo echo 3 > brightness
An error occurred while redirecting file 'brightness'
open: Permission denied
```

This error may come as a surprise! After all, we ran the command with `sudo`. This is an important thing takeaway: 

> Operations like | > and < are done by shell, not the program.

`echo` does not know about `|`. They just read from their input and write to their output, whatever it may be. In the case above, the shell (which is authenticated just as normal user) tries to open the brightness file for writing, before setting that as output of `sudo echo`. It is prevented from doing so because the shell does not run as root for writing into file. Only `echo` command ran under super-user.

We can change the shell to root to bypass this:

```console
$ su -
[sudo password]: *****

# echo 3 > brightness
```

Using our understanding of shell, we can also work around this:

```console
$ echo 1060 | sudo tee brightness
```

Since the `tee` program is the one to open the `/sys` file for writing, and is running as `root`, the permissions all work out. You can control all sorts of fun and useful things through `/sys`, such as the state of various system LEDs and keys.


**Exercise:**

- Use touch to create a new file called `semester` in `/tmp/missing`.

```console
touch /tmp/missing
```

- Write the following one line at a time:

```console
#!/bin/sh

curl --head --silent https://missing.csail.mit.edu
```
This is how to, 

```console
$ echo '#!/bin/sh' > missing
$ echo 'curl --head --silent https://missing.csail.mit.edu' >> missing
```

- Try executing the file:

> It will not work becuase 'x' bit is missing

- Does `sh missing` work? Why?

> Yes. But `./missing` will not work. It can be set to execute by `chmod +x missing`. If you make your file executable and run it with `./file`, then the kernel will see that the first two bytes are `#!`, which means it's a script-file. The kernel will then use the rest of the line as the interpreter, and pass the file as its first argument. So, it runs `/bin/bash file`. For `bash/sh/zsh` to execute the script, it only needs to be able to read the file. As long as bash script is executable, you can also run bash with the script file as argument.

> To really prohibit execution conversely, take away the read bit. When you are running `sh file.sh`, you are executing `sh` - which takes the file as argument. File permissions on `x` have effect only if you execute the script itself.


- Use pipes to write the “last modified” date

```console
./missing | grep "last" > last.txt
```

## Notes

Quoting is used to remove the special meaning of certain characters. Quoting can be used to disable special treatment for these special characters, to prevent reserved words from being recognized as such, and to prevent parameter expansion.

There are three quoting mechanisms: the escape character, single quotes, and double quotes:

- **Escape**: A non-quoted backslash \ is the Bash escape character. It preserves the literal value of the next character that follows, with the exception of newline. 

- **Single Quotes**:
Enclosing characters in single quotes preserves the literal value of 
each character within the quotes. A single quote may not occur between 
single quotes

- **Double quotes** Enclosing characters in double quotes preserves 
the literal value of all characters within the quotes, with the 
exception of `$`,`` ` ``, `\` and, when history expansion is enabled, 
``!``. The characters ``$`` and `` ` `` retain their special meaning 
within double quotes. The special parameters `*` and `@` have special 
meanings.

```console
$ echo Hello\ OK
Hello OK

$ echo Hello\\ OK
Hello\ OK

$ echo Hello\\nOK
Hello
OK

$ echo 'Hello\\r OK'
Hello\r OK

$ echo "Hello\\rOK"
OKllo

$ echo Hello\\n\\rOK
Hello
OK
```