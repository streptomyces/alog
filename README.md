# alog.pl

## Example

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

#### `-dayadjust`

Integer. Adjust the date by this many days. When this is used the
time component is removed from the time stamp that is written to the
file. Only negative values make sense here to write notes about
dates before today. Note that the entry is still made at the bottom
of the notes file.

    alog.pl -add -dayadj -9

#### `-add`

Add a note. An editor is started in the foreground to type your note
in. This note is inserted in notes when you exit the editor.

#### `-outfile`

If specified, output is written to this file. Otherwise it is
written to STDOUT. This is affected by the -outdir option described
below.

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
my $editor_command = qq(gvim -f -c "set t_vb=" -c "set background=dark);
$editor_command .= qq( tw=70 nosmartindent filetype=pdc");
my $notesdir = ".";
my $file = "alog";
my $tempdir = qw(/tmp);
local $Text::Wrap::columns = 65;
my $template="alogghXXXXX";
~~~

You will certainly wish to change `$notesdir` and `$editor_command`.
Note that the `$editor_command` is spread over two lines. It is best
to run your editor in the foreground so that you do not get your
prompt back till you are done writing. I use the `-f` option to `gvim`
to prevent it from forking and detaching from shell like it usually
does. `vim` runs in the terminal and can be used as it it. You might
want to change `$file` to a file name of your liking.

