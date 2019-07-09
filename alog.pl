#!/usr/bin/perl
use 5.14.0;
use Carp;
use lib qw(/home/sco /home/sco/perllib);
use File::Basename;
use File::Copy;
use File::Temp qw(tempfile tempdir);
use File::Spec;
use Text::Wrap;
my $template="alogghXXXXX";
local $Text::Wrap::columns = 65;
use Getopt::Long;

# Below, 3 lines of configuration.
my $editor_command = qq(gvim -f -c "set t_vb=" -c "set background=dark tw=70 nosmartindent filetype=pdc");
my $notesdir = ".";
my $tempdir = qw(/tmp);

# {{{ Getopt::Long stuff
my $file = "alog";
my $dayadj;
my $outfile;
my $edit;
my $add;
my $help;
my $regex;
my $sep;
GetOptions (
"outfile:s" => \$outfile,
"infile|file:s" => \$file,
"notesdir:s" => \$notesdir,
"add" => \$add,
"dayadjust:i" => \$dayadj,
"edit" => \$edit,
"grep|regex=s" => \$regex,
"help" => \$help,
"separator" => \$sep,
);
# }}}

if($help) {
exec("perldoc $0");
exit;
}


# {{{ POD 

=head1 Name

note.pl

=head2 Example

 perl note.pl -add
 perl note.pl -file notes -add
 perl note.pl -file notes -grep test

=head2 Options

=over 2

=item -help

Shows documentation using perldoc. Nothing else happens no
matter what other options are specified.

=item -infile|file|notesfile

The notes file to use. Backup file name is derived from this file
name approximately as below.

 my $backbn = "." . $file . ".backup";

=item -dayadjust

Integer. Adjust the date by this many days. When this is used
the time component is removed from the time stamp that is written
to the file. Only negative values make sense here to write notes
about dates before today. Note that the entry is still made at the
bottom of the notes file.

Example

 note.pl -file domestic -add -dayadj -9

=item -add

Add a note. An editor is started in the foreground to type
your note in. This note is inserted in notes when you exit the
editor.

=item -outfile

If specified, output is written to this file. Otherwise it
is written to STDOUT. This is affected by the -outdir option
described below.

=item -edit

Opens the notes file in an editor for direct editing.

=item -grep

Regular expression to select.

=back

=head2 Getting HTML

To get HTML of all the notes

 /home/sco/bin/notes2html

The above will write /home/sco/temp/notes.html on n51958.

To get HTML of the output of a specific grep.

 note.pl -o matt.md -grep 'matt'
 notes2html matt.md

The above will write /home/sco/temp/mattNotes.html on n51958.


=head2 Description

Meant for inserting and viewing records in a notes file.

A record is any text separated from the next record by "//"
(two forward slashes) on a line of its own.

=cut


# }}}


my $backbn = "." . $file . ".backup";
my $notesFile = File::Spec->catfile($notesdir, $file);
my $backFile = File::Spec->catfile($notesdir, $backbn);


my $ofh;
# {{{ unless we are adding a note we open file to write to.
unless($add) {
if($outfile) {
    open($ofh, ">$outfile");
}
else {
    open($ofh, ">-");
}
select($ofh);
}
# }}}

# {{{ add a note provided as argument.
if(@ARGV) {
  copy($notesFile, $backFile);
  my $wrapped = wrap("", "", @ARGV);
  open(my $nh, ">>", $notesFile);
  my $ts = localtime();
  if($dayadj) {
    my $tt = time();
    my $at = $tt + ($dayadj * 24 * 60 *60);
    $ts = localtime($at);
    $ts =~ s/\d+:\d+:\d+\s+//;
  }
  chomp($ts);
  print($nh "\n### $ts\n\n");
  print($nh "$wrapped\n");
  print($nh "//\n");
  $add = 0;
  close($nh);
}
# }}}

# {{{ add a note
if($add) {
  copy($notesFile, $backFile);
  my($fh, $fn)=tempfile($template, DIR => $tempdir, SUFFIX => '.tmp');
  close($fh);
  system("$editor_command $fn");
  if(-f $fn and -s $fn) {
    open(my $nh, ">>", $notesFile);
    open(my $th, "<", $fn);
    my $ts = localtime();
    if($dayadj) {
      my $tt = time();
      my $at = $tt + ($dayadj * 24 * 60 *60);
      $ts = localtime($at);
      $ts =~ s/\d+:\d+:\d+\s+//;
    }
    chomp($ts);
    print($nh "\n### $ts\n\n");
    while(<$th>) {
      print($nh $_);
    }
    print($nh "//\n");
    close($th); close($nh);
  }
  unlink($fn);
}
# }}}

# {{{ edit the notes file
if($edit) {
copy($notesFile, $backFile);
system("$editor_command $notesFile");
}
# }}}

# {{{ regex
elsif($regex) {
  $regex =~ s/ +/\\s\+/g;
  outbyregex($regex);
}
# }}}

# {{{ Default to printing the whole notes file
else {
open(my $nh, "<", $notesFile);
while(<$nh>) {
print($_);
}
close($nh);
}
# }}}

if($ofh) {
close($ofh);
}

exit;


# {{{ sub outbyregex
sub outbyregex {
  my $regex = shift(@_);
  $regex =~ s/ +/\\s\+/g;
my @rec = ();
my $recMatch = 0;
my $ofh;
if($outfile) {
    open($ofh, ">$outfile");
}
else {
  open($ofh, ">-");
}
select($ofh);

open(my $nh, "<", $notesFile);
local $/ = "\n//\n"; # For reading multiline records.
# Note that the record separator is not discarded.
while(my $rec = readline($nh)) {
if($rec =~ m/$regex/is) {
print("$rec");
}
}
close($nh);
print(STDERR "\nREGEX is: $regex\n");
}
# }}}

