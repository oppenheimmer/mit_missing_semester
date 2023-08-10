Writing English words and writing code are very different activities. 
When programming, you spend more time switching files, reading, navigating,
and editing code compared to writing a long stream. It makes sense that 
there are different types of programs for writing English words versus 
code (e.g. Microsoft Word versus Visual Studio Code).

# Vim

All the instructors of this class use Vim as their editor. Vim has a 
rich history; it originated from the Vi editor (1976), and it's still 
being developed today. Vim has some really neat ideas behind it, and for 
this reason, lots of tools support a Vim emulation mode. 

## Philosophy of Vim

When programming, you spend most of your time reading/editing, not writing.
For this reason, Vim is a _modal_ editor: it has different operation modes 
for inserting text vs. manipulating text. Vim is programmable (with 
Vimscript and also other languages like Python), and Vim's interface 
itself is a programming language: keystrokes (with mnemonic names) are 
commands, and these commands are composable. Vim avoids the use of the 
mouse, because it's too slow; Vim even avoids using the arrow keys because 
it requires too much movement. The end result is an editor that can match
the speed at which you think.

## Modal editing

Vim's design is based on the idea that a lot of programmer time is spent
reading, navigating, and making small edits, as opposed to writing long 
streams of text. For this reason, Vim has multiple operating modes.

|Mode		| Function                                              |
|---------------|-------------------------------------------------------|
|Normal 	| Moving around a file and making edits. Deafult mode   |
|Insert		| For inserting text.                                   |
|Replace	| For replacing text.                                   | 
|Visual		| (plain, line, or block), For selecting blocks of text |
|Command	| For running a command                                 |


Keystrokes have different meanings in different operating modes. For 
example, the letter `x` in Insert mode will just insert a literal 
character 'x', but in Normal mode, it will delete the character under the 
cursor, and in Visual mode, it will delete the selection.

In its default configuration, Vim shows the current mode in the bottom left.
The initial/default mode is Normal mode. You'll generally spend most of your
time between Normal mode and Insert mode.

You change modes by pressing `<ESC>` (the escape key) to switch from any 
mode back to Normal mode. From Normal mode, enter Insert mode with `i`, 
Replace mode with `R`, Visual mode with `v`, Visual Line mode with `V`, 
Visual Block mode with `<C-v>` (Ctrl-V, sometimes also written `^V`), and 
Command-line mode with `:`.


## Basics

### Inserting text

From Normal mode, press `i` to enter Insert mode. Now, Vim behaves like any
other text editor, until you press `<ESC>` to return to Normal mode. This,
along with the basics explained above, are all you need to start editing 
files using Vim.


### Buffers, tabs, and windows

Vim maintains a set of open files, called `buffers`. A Vim session has a 
number of tabs, each of which has a number of windows (split panes). Each 
window shows a single buffer. Unlike other programs you are familiar with, 
like web browsers, there is not a 1-to-1 correspondence between buffers 
and windows; windows are merely views. A given buffer may be open in 
_multiple_ windows, even within the same tab. This can be quite handy, 
for example, to view two different parts of a file at the same time.
By default, Vim opens with a single tab, which contains a single window.


### Command-line

Command mode can be entered by typing `:` in Normal mode. Your cursor will 
jump to the command line at the bottom of the screen upon pressing `:`. 
This mode has many functionalities, including opening, saving, and closing 
files & quitting Vim 

|Key		| Function                       |
|---------------|--------------------------------|
|:q 		| Quit the window                |
|:w		| For writing text.              |
|:wq		| For replacing text.            | 
|:ls		| Show open buffers              |
|:e {filename}	| Edit file with given name      |
|:help {topic}	| Help for a topic               |


## Vim as a programming language

The most important idea in Vim is that Vim's interface itself is a 
programming language. Keystrokes (with mnemonic names) are commands, 
and these commands _compose_. This enables efficient movement and edits, 
especially once the commands become muscle memory.

### Movement

You should spend most of your time in Normal mode, using movement commands 
to navigate the buffer. Movements in Vim are also called `nouns`, because 
they refer to chunks of text.


|Function	| Key                                    |
|---------------|----------------------------------------|
|Basic Movement |`h-l` & `j-k` (L-R, U-D)                |
|Word		| `w` next word                          | 
|		| `b` beginning of word                  |
|		| `e` end of word                        |
|Lines		| `0`: beginning of line.                | 
|               | `^`: first non blank   	         |
|		| `$`: end of line                       |
|Screen		| `H`: top of screen                     |
|		| `M`: middle of screen                  |
|		| `L`: bottom of screen                  |
|Scroll		| `ctrl-u` (up), `ctrl-d` (down)         |
|File		| `gg` : beginning of file               | 
|		| `G`: end of file		         |
|Line Number	| `:set number`                          |
|Misc		| `%` correspoding item                  |
|Find		| `f{character}, t{character}`           |
|		| `F{character}, T{character}`           |
|               | `,` & `;` for navigating matches       |
|Search		| `/{regex}`, then `n / N` for navigating|



### Selection

Visual modes:

| Type	       | Key   |
|--------------|-------|
| Visual plain | `v`   |
| Visual Line  | `V`   |
| Visual Block | `^v`  |


### Edits

Everything that you used to do with the mouse, you now do with the 
keyboard using editing commands that compose with movement commands. 
Here's where Vim's interface starts to look like a programming language. 
Vim's editing commands are also called `verbs`, because verbs act on 
`nouns`.

| Key	        | Meaning                                |
|---------------|----------------------------------------|
| `i` 	 	| Insert Mode                            |
| `o`/`O`	| Insert line below or above             |
| `d`{noun}`	| `dw` : delete word                     |
|		| `d$` : delete to end of line           |
|		| `d0` : delete to start of line         |
| `c{noun}`	| `cw` : change word                     |
|		|  followed by an auto insert mode       |
| `x`		| delete character, equivalent to `dl`   |
| `s`		| substitute charcter, equivalent to `xi`|
| Visual modify	| Use visual mode to select text         |
|		| - `d`:  delete                         |
|		| - `c`: change                          |
| `u` & `^r` 	| undo and redo                          |
| `y` 		| "yank" or copy                         | 
| `p` 		| Paste                                  |
| `~`		| Flips the case of a character          |



### Counts

You can combine nouns and verbs with a count, which will perform a given 
action a number of times.

- `3w` move 3 words forward
- `5j` move 5 lines down
- `7dw` delete 7 words

### Modifiers

You can use modifiers to change the meaning of a noun. Some modifiers are 
`i`, which means "inner" or "inside", and `a`, which means "around".

- `ci(` change the contents inside the current pair of parentheses
- `ci[` change the contents inside the current pair of square brackets
- `da'` delete a single-quoted string, including the single quotes

## Customizing Vim

Vim is customized through a plain-text configuration file in `~/.vimrc`
(containing Vimscript commands). There are probably lots of basic settings 
in that you want to turn on.


## Extending Vim

There are tons of plugins for extending Vim. Contrary to outdated advice 
that you might find on the internet, you do _not_ need to use a plugin 
manager for Vim (since Vim 8.0). Instead, you can use the built-in package 
management system. Simply create the directory `~/.vim/pack/vendor/start/`, 
and put plugins in there (e.g. via `git clone`).

Here are some of our favorite plugins:

- [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim): fuzzy file finder
- [ack.vim](https://github.com/mileszs/ack.vim): code search
- [nerdtree](https://github.com/scrooloose/nerdtree): file explorer

Check out [Vim Awesome](https://vimawesome.com/) for more awesome Vim 
plugins. 

## Vim-mode in other programs

Many tools support Vim emulation. The quality varies from good to great;
depending on the tool, it may not support the fancier Vim features, but most
cover the basics pretty well.

## Search and replace

`:s` is the substitute command & can be used with regex to do powerful 
search and replace.

| Pattern                 | Meaning			                |
|-------------------------|---------------------------------------------|
|`%s/foo/bar/g`           | replace foo with bar globally               |
|`%s/\[.*\](\(.*\))/\1/g` | replace named Markdown links with plain URLs|


## Multiple windows
`:sp` / `:vsp` to split windows; Can have multiple views of the same 
buffer.


## Macros

- `q{character}` to start recording a macro in register `{character}`
- `q` to stop recording
- `@{character}` replays the macro
- Macro execution stops on error
- `{number}@{character}` executes a macro {number} times
- Macros can be recursive
    - first clear the macro with `q{character}q`
    - record the macro, with `@{character}` to invoke the macro recursively
    (will be a no-op until recording is complete)
- Example: convert xml to json ([file](/2020/files/example-data.xml))
    - Array of objects with keys "name" / "email"
    - Use a Python program?
    - Use sed / regexes
        - `g/people/d`
        - `%s/<person>/{/g`
        - `%s/<name>\(.*\)<\/name>/"name": "\1",/g`
        - ...
    - Vim commands / macros
        - `Gdd`, `ggdd` delete first and last lines
        - Macro to format a single element (register `e`)
            - Go to line with `<name>`
            - `qe^r"f>s": "<ESC>f<C"<ESC>q`
        - Macro to format a person
            - Go to line with `<person>`
            - `qpS{<ESC>j@eA,<ESC>j@ejS},<ESC>q`
        - Macro to format a person and go to the next person
            - Go to line with `<person>`
            - `qq@pjq`
        - Execute macro until end of file
            - `999@q`
        - Manually remove last `,` and add `[` and `]` delimiters

# Resources

- `vimtutor` is a tutorial that comes installed with Vim 
- [Vim Adventures](https://vim-adventures.com/) is a game to learn Vim
- [Vim Tips Wiki](http://vim.wikia.com/wiki/Vim_Tips_Wiki)
- [Vim Golf](http://www.vimgolf.com/) 
