Basic Unix
==========

.. raw:: html

    <div style="position: relative; padding-bottom: 60%; height: 0; overflow: hidden; max-width: 100%; height: auto;">
        <iframe src="https://www.youtube.com/embed/dFUlAQZB9Ng" frameborder="0" allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe>
    </div>

Streams
~~~~~~~
Before going into commands, it is useful to understand how data can flow between commands. There are three input and output streams in the shell:

* stdin - Standard input for most commands will look here for input.  Defaults to the keyboard.
* stdout - Standard output location for data. By default, this will be streamed to the terminal and thus be displayed.
* stderr - Standard error.  Used for error messages. While this also is streamed to the terminal (unless redirected), it is a separate stream from stdout.  Usually used for log files.

The Pipe
--------
Unix has the ethos that all programs should simply do one thing and do it well; complexity is built up by redirecting - or *piping* the output stream of one command into the input stream of another. This pipe is represented by the character `|` (the vertical bar usually found above the enter key) For example, you might have a compressed FASTQ file that you would like to examine the first few lines of for the presence of some gene name. Instead of completely decompressing the file to disk, opening the file in a text editor, and searching for that gene, you could::

    user@computer:~/$ gzip --decompress example_fastq.gz | head --lines 100 | grep "gene_name"

This will use `gzip` to decompress the FASTQ; pipe that output to `head`, which will read in the first 100 lines (and then stop gzip from decompressing any further); and then pipe that output to `grep`, which will search those 100 lines for the text of interest.

* `|` - the pipe. Used to move data between commands.
* `>` - redirects output to a files. Overwrites any existing file.
* `>>` - appends output to a file. Places at the end.
* `&1` - stdout. It can be useful in some cases to explicitly redirect output to stdout.
* `&2` - stderr.
* `&&` - and. If the previous command terminated successfully, run the subsequent command; otherwise stop.


Unix commands
~~~~~~~~~~~~~~
Most unix commands have 2/3 letter name and do one thing related to that name. Some of the more useful common commands are listed below:

* `cat` - *c*\ onc\ *at*\ enate.  While this is frequently used to display text, its actual purpose is to glue files together by directing the contents of several files to `stdout`. For example::

    cat file1 file2 > file3

  will sequentially read the contents of files 1 and 2, place the data from file 2 at the end of file 1, and save the data to the new file 3.
* `curl`/`wget` - while there are some major differences between the two, but both are used to download files from http(s) and ftp servers.
* `cd` - *c*\ hange *d*\ irectory
* `cp` - *c*\ o\ *p*\ y files
* `du` - Display the amount of *d*\ isk *u*\ sed.  More helpful when the `-h` argument is passed so that sizes are displayed in human-readable terms.
* `grep` - *g*\ lobally search a *r*\ egular *e*\ xpression and *p*\ rint.  Regular expressions are one of the most useful things you can learn when it comes to computers - they allow you to find and capture very specific patterns of text; it, however, can be a challanging topic to learn.  See these links for a `tutorial <https://regexone.com/>`_ here and an `interactive sandbox <https://regexr.com/>`_.
* `gzip`/`bzip`/`xz` - compression/decompression utilities.  Handes files ending in `.gz`, `.bz`, and `.xz`, respectively (though, technically the file format is what is important, not just the file name extension)
* `head`/`tail` - display the first or last lines of a files.  By default, shows 50 lines.

  - `-n` display *n* lines
  - `-f` have tail *f*\ ollow the end of the file.  Useful for watching a log file.

* `less` - Display a portion of a file, with the ability to move forward several lines by pusing the `space bar` or `enter`
* `ln` - create a *l*\ i\ *n*\ k to a file.  By default, creates a *hard* link, which associates a name with a file. More often, a *soft* link is what is desired, which is a shortcut to a target file or directory (also a file in UNIX).  Soft links are useful because they are typically transparent (so if one program is looking for libraries in a particular location but the distrobution happens to put them somewhere else, a soft link can fix the issue) and because the target does not have to exist when the link is created.  Usage is easy to mix up, but takes the form of::

    ln -s target_file name_of_shortcut

  - `-s` creates a soft link

* `ls` - *l*\ i\ *s*\ t the files in a directory

  - `-l` display in list format, with file sizes and permissions
  - `-a` display all files (including hidden)
  - `-h` display with human readable sizes

* `man` - *man*\ ual.  Display information about a command
* `mv` - *m*\ o\ *v*\ e files. Is also used to rename files (by moving them from one name to another.
* `pwd` - shows the *p*\ resent *w*\ orking *d*\ irectory
* `rm` - *r*\ emo\ *v*\ e a file

  - `-fr` forces the removal of a file. Is also a necessary argument when attempting to delete a folder.

.. warning::
    Deletion is **PERMANENT**, there is no "recycling bin" or "trash can" from which files can be recovered.

* `sed` - *s*\ tream *ed*\ itor that is *very* fast at finding and replacing text using Perl-style regular expressions but can be somewhat confusing to use.  There are, however, many `guides <https://www.grymoire.com/Unix/Sed.html>`_ to its use.
* `sort`
* `tar` - *t*\ ape *ar*\ chive
* `wc` - *w*\ ord *c*\ ount.  Perhaps most useful when used with the `-l` flag, which causes it to count the number of *l*\ ines.

