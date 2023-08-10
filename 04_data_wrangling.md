## Data wrangling:

Anything which makes one representation of data into another, including 
the format of presentation would be *data wrangling*.

Any time you use the `|` operator, you are performing some kind of
data wrangling e.g. a command like `journalctl | grep -i intel`. It
finds all system log entries that mention Intel and presents it instead 
of the original log.

Let's start from the beginning. To wrangle data, we need two things:

- Data to wrangle
- Some tool and Operation

Logs often make for a good use-case, because you often want to investigate 
things about them, and reading the whole thing isn't feasible.

```bash
ssh myserver journalctl
```

There's far too much stuff. Let's limit it to ssh daemon:

```bash
ssh myserver journalctl | grep sshd
```

Notice that we're using a pipe to stream a _remote_ file through `grep`
on our local computer! `ssh` is magical. This is still way
more stuff than we wanted though. And pretty hard to read. Let's do
better:

```bash
ssh myserver 'journalctl | grep sshd | grep "Disconnected from"' | less
```

Why the additional quoting? Our logs could be quite large, and it's
wasteful to stream it all to our computer and then do the filtering.
Instead, we can do the filtering on the remote server, and then parse
the data locally. `less` gives us a pager that allows us to scroll up
and down through the long output transmitted. 

To save some additional traffic while we debug our command-line, we can 
even stick the current filtered logs into a file so that we don't have to 
access the network while developing:

```console
$ ssh myserver 'journalctl | grep sshd | grep "Disconnected from"' > ssh.log
$ less ssh.log
```


## `sed`

`sed` is a *stream editor* that builds on top of the old `ed` editor. 
It is a full-featured programming language over the input stream given.
In it, you basically give short commands for how to modify the file, 
rather than manipulate its contents directly (although you can do that 
too). There are tons of commands, but one of the most common ones is 
`s`: substitution. For example, we can write:

```bash
ssh myserver journalctl
 | grep sshd
 | grep "Disconnected from"
 | sed 's/.*Disconnected from //'
```

What we just wrote was a simple _regular expression_; a powerful
construct that lets you match text against patterns. The `s` command is
written on the form: `s/REGEX/SUBSTITUTION/`, where `REGEX` is the
regular expression you want to search for, and `SUBSTITUTION` is the
text you want to substitute matching text with.


## Regular expressions

Regular expressions are common and useful enough that it's worthwhile to
take some time to understand how they work. Let's start by looking at
the one we used above: `/.*Disconnected from /`. Regular expressions are
usually (though not always) surrounded by `/`. Most ASCII characters
just carry their normal meaning, but some characters have "special"
matching behavior.

 - `.` means "any single character" (except newline).
 - `*` zero or more of the preceding match
 - `+` at-least one or more of the preceding match
 - `[abc]` any one character of `a`, `b`, and `c`
 - `(RX1|RX2)` either something that matches `RX1` or `RX2`
 - `^` the start of the line
 - `$` the end of the line
 - 'g' does matching globally

```console

$ echo 'bcbzac' | sed 's/[ab]//'    # exit after 1st hit
cbzac
$ echo 'bcbzac' | sed 's/[ab]//g'   # search all patterns due to 'g'
czc
$ echo 'abcaba' | sed -E 's/(ab)*//g' # search for all 'ab'
ca
$ echo 'abcaba' | sed 's/\(ab\)*//g'  # alternate way of writing
ca
$ echo 'abcabcabdc' | sed -E 's/(ab|bc)*//g' # search 'ab' or bc
ccdc
```

*Note* :
 
1. Typically, unless global flag specified, `sed` acts on the first match 
and executes. (It works along a short circuit operator: the arguments 
are executed only if the previous argument have failed, otherwise not). 
If global flag is given, it will look for all the possible ways to 
execute the program.


2. `sed`'s regular expressions are somewhat weird, and will require you to
put a `\` before most of these to give them their special meaning. Or
you can pass `-E`. (Refer 3rd and 4th example above).

So, looking back at `/.*Disconnected from /`, we see that it matches
'any character followed by any number of characters which precedes the
literal string "Disconnected from ". What if someone tried to log in with 
the username "Disconnected from"? We'd have a log entry as:

```
Jan 17 03:13:00 thesquareplanet.com sshd[2631]: Disconnected from invalid user Disconnected from 46.97.239.16 port 55920 [preauth]
```

`*` and `+` are, by default, 'greedy'. They will match as much text as 
they can. So, in the above, we'd end up with just

```
46.97.239.16 port 55920 [preauth]
```

Which may not be what we really wanted. In some regular expression
implementations, you can just suffix `*` or `+` with a `?` to make them
non-greedy, but sadly `sed` doesn't support that. We _could_ switch to
perl's command-line mode though, which _does_ support that construct:

```bash
perl -pe 's/.*?Disconnected from //'
```

We'll stick to `sed` for the rest of this, because it's by far the more
common tool for these kinds of jobs. Going further, we also have a suffix 
we'd like to get rid of. How might we do that? It's a little tricky to 
match just the text that follows the username, especially if the username 
can have spaces and such! What we need to do is match the _whole_ line:

```bash
cat sshdlog
| grep "Disconnected from" 
| sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$//'
```

Lets use a [regex debugger](https://regex101.com/). The start is still
as before. Then, we're matching any of the "connection" variants (there are
two prefixes in the logs) once. Then we're matching on any string of
characters where the username is. Then we're matching on any single word
(`[^ ]+`; any non-empty sequence of non-space characters). Then the word
"port" followed by a sequence of digits. Then possibly the suffix
`[preauth]`, and then the end of the line.

There is one problem with this though, and that is that the entire log
becomes empty (because it is substituted with nothing in the expression). 
We want to _keep_ the username after all. For this, we can use 'capture 
groups'. Any text matched by a regex surrounded by parentheses is stored 
in a numbered capture group. These are available in the substitution as 
`\1`, `\2`, `\3`, etc. So:

```bash
cat sshdlog 
| grep "Disconnected from" 
| sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/'
```

Regular expressions are notoriously hard to get right, but they are also
very handy to have in your toolbox.

## Back to data wrangling

Lets count the number of unique infiltrants to the server:

```bash
cat sshdlog 
| grep "Disconnected from" 
| sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/' 
| sort 
| uniq 
| wc -l
```

- `sort` will sort alphabetically. `-n` : numeric sort, `-k` selects 
   whitespace separated column to sort by, tuple `n,n` indicated sort 
   by n-th column and end with the n-th column

   `sort -n` will sort in numeric (instead of lexicographic) order. `-k1,1`
   means "sort by only the first whitespace-separated column". The `,n`
   part says "sort until the `n`th field, where the default is the end of
   the line. `sort -r` will sort in reverse order.

- `uniq` will find uniqe occurences in the piped input. `-c` keeps count.

- `wc` does word counting (`-l` option indicated lines)

-  Top of the list can be accessed by `head -nN`, and the bottom by 
   `tail -nN`, where N is the number to show. N usually has a default 
   value unless specified. 

Let us look for most common login attempts:


```bash
cat sshdlog | grep "Disconnected from" | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/' | sort | uniq -c| sort -nk1,1 | tail -n10  
```

This gives a list of 10 common usernamess and the number of times they have 
attempted to login to the system. But what if we'd like these extract only 
usernames as a flat list instead of one per line?

```bash
cat sshdlog | grep "Disconnected from" | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/' | sort | uniq -c| sort -nk1,1 | tail -n10 | awk '{print $2}' | xargs
```





## `awk` : POSIX  editor

`awk` is a programming language that just happens to be really good at
processing text streams. There is _a lot_ to say about `awk` if you were
to learn it properly, but as with many other things here, we'll just go
through the basics.

First, what does `{print $2}` do? Well, `awk` programs take the form of
an optional pattern plus a block saying what to do if the pattern
matches a given line. The default pattern here matches all lines. Inside 
the block, `$0` is set to the entire line's contents, and `$1` through 
`$n` are set to the `n`th _field_ of that line, when separated by the 
`awk` field separator (whitespace by default, change with `-F`). In this 
case, we're saying that, for every line, print the contents of the second 
field, which happens to be the username.

Let's see if we can do something fancier. Let's compute the number of
single-use usernames that start with `c` and end with `e`:

```bash
cat sshdlog | grep "Disconnected from" | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/' | sort | uniq -c| sort -nk1,1 | awk '$1 == 1 && $2 ~ /^c[^ ]*e$/ { print $2 }'
```

There's a lot to unpack here. First, notice that we now have a pattern. 
The pattern says that the first field of the line should be equal to 1 
(that's the count from `uniq -c`), and that the second field should match 
the given regular expression. And the block just says to print the username.

However, `awk` is a programming language, remember?

```awk
BEGIN { rows = 0 }
$1 == 1 && $2 ~ /^c[^ ]*e$/ { rows += $1 }
END { print rows }
```

`BEGIN` is a pattern that matches the start of the input (and `END`
matches the end). Now, the per-line block just adds the count from the
first field (although it'll always be 1 in this case), and then we print
it out at the end.



## Analyzing data

You can do math directly in your shell using `bc`, a calculator that can 
read from `STDIN`. For example, add the numbers on each line together by 
concatenating them together, delimited by `+`:

```bash
cat sshdlog | grep "Disconnected from" | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/' | sort | uniq -c| sort -nk1,1 | tail -n10 | awk '{print $1}' | gpaste -sd+ | bc -l
```

Or produce more elaborate expressions:

```bash
echo "2*($(data | gpaste -sd+))" | bc -l
```

You can get stats in a variety of ways. This uses `R` to produce a summary 
statistics:

```bash
ssh myserver journalctl
 | grep sshd
 | grep "Disconnected from"
 | sed -E 's/.*Disconnected from (invalid |authenticating )?user (.*) [^ ]+ port [0-9]+( \[preauth\])?$/\2/'
 | sort | uniq -c
 | awk '{print $1}' | R --no-echo -e 'x <- scan(file="stdin", quiet=TRUE); summary(x)'
```


**Exercises**

1. Find the number of words (in `/usr/share/dict/words`) that contain at 
least three `a`-s and don’t have a `'s` ending.

```bash
cat /usr/share/dict/words | grep ".*a.*a.*a"
cat /usr/share/dict/words | grep ".*a.*a.*a" | grep -v ".*\'s" | wc -l
```

2. What are 3 most common last two characters in these words?

```bash
cat /usr/share/dict/words 
| tr {{A-Z}} {{a-z}} 
| grep ".*a.*a.*a" 
| grep -v ".*\'s" 
| sed -E 's/.*(..)/\1/' 
| sort 
| uniq -c 
| sort -rk1,1 
| head -n3
```

3. How many such last-two character unique combinations are there?

```bash
cat /usr/share/dict/words 
| tr {{A-Z}} {{a-z}} 
| grep ".*a.*a.*a" 
| grep -v ".*\'s" 
| sed -E 's/.*(..)/\1/' 
| sort 
| uniq -c 
| sort -rk1,1 
| awk '{print $1}' 
| gpaste -sd+ 
| bc -l 
```

4. To do in-place substitution it is quite tempting to do something like 
`sed s/REGEX/SUBSTITUTION/ input.txt > input.txt`. However this is a bad 
idea. Why? Is this particular to sed? 

Bash processes the redirects (`>`) first, so, by the time the `sed` 
command is executed, the file is empty, making the regex substitution 
not possible. To solve this issue, one can use the `-i` option:

```bash
sed -E -i 's/REGEX/SUBSTITUTION/' input.txt
```

5. Find summary statistics of boot up time from `journalctl`. Requires R:

```bash
journalctl | grep 'systemd\[1\]: Startup finished in' | sed -E "s/.* \(userspace\) = (.*)s\./\1/" | R --slave -e 'x <- scan(file="stdin"); summary(x)'
```

