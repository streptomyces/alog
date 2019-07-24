# alog.pl

## Examples

    perl alog.pl -add
    perl alog.pl -file alog -add
    perl alog.pl -file alog -grep test

## Options

#### `-help`

Shows documentation using perldoc. Nothing else happens no matter
what other options are specified.

#### `-infile or -file`

The text file to use. Backup file name is derived from this file
name approximately as below.

    my $backbn = "." . $file . ".backup";

This is optional. The default notes file is stored in `$file`.

#### `-dayadjust`

Integer. Adjust the date by this many days. When this is used the
time component is removed from the time stamp that is written to the
file. Only negative values make sense here to write notes about
dates before today. Note that the entry is still made at the bottom
of the notes file.

    alog.pl -add -dayadj -9

#### `-add`

Add a note. An editor (vim by default) is started in the foreground to
type your note in. This note is inserted in the notes file when you
exit the editor. The current directory is already written into the
editor when it starts.

#### `-outfile`

If specified, output is written to this file. Otherwise it is
written to STDOUT.

#### `-edit`

Opens the notes file in an editor for direct editing.

#### `-grep`

Regular expression to select.

## Description

Script for inserting and viewing records in a notes file.

A record is any text separated from the next record by _//_ (two
forward slashes) on a line of its own.

## Configuration

The first line of the script is

~~~ 
#!/usr/bin/perl
~~~

If your perl binary is located elsewhere, edit this line.

Then there are the following lines.

~~~ 
my $editor_command;
$editor_command = qq(vim + -c "set tw=70 nosi filetype=pdc");
my $notesdir = ".";
my $file = "alog";
my $tempdir = qw(/tmp);
local $Text::Wrap::columns = 65;
my $template="alogghXXXXX";
~~~

In the above, you will certainly wish to change `$notesdir`. It is
best to run your editor in the foreground so that you do not get your
prompt back till you are done writing. If you use `gvim` then use the
`-f` option to prevent it from forking and detaching from shell like
it usually does. `vim` runs in the terminal and can be used as it it.
You might want to change `$file` to a file name of your liking.

## Comments

If you make this script executable and put it in your PATH then you
can call it from whatever directory you are working in and your notes
will get appended to the same notes file. It will automatically add
the current directory to your note when you add a note. The idea is to
record the time and the directory in which you were working when you
wrote the note. No structure is enforced for the notes.

## Author

govind.chandra@jic.ac.uk

