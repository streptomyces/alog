# alog.pl

## Example

    perl alog.pl -add
    perl alog.pl -file alog -add
    perl alog.pl -file alog -grep test

## Options

#### `-help`

Shows documentation using perldoc. Nothing else happens no matter
what other options are specified.

#### `-infile|file`

The text file to use. Backup file name is derived from this file
name approximately as below.

    my $backbn = "." . $file . ".backup";

#### `-dayadjust`

Integer. Adjust the date by this many days. When this is used the
time component is removed from the time stamp that is written to the
file. Only negative values make sense here to write notes about
dates before today. Note that the entry is still made at the bottom
of the notes file.

    alog.pl -file domestic -add -dayadj -9

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
