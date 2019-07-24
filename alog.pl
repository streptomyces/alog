#!/usr/bin/perl
use 5.14.0;
use Carp;
use File::Basename;
use File::Copy;
use File::Temp qw(tempfile tempdir);
use File::Spec;
use Text::Wrap;
use Cwd qq(abs_path);
use Getopt::Long;
use Fcntl qw(:flock);

# Below, a few lines of configuration.
my $editor_command;
# $editor_command = qq(gvim -f -c "set t_vb=" -c "set background=dark");
# $editor_command .= qq( -c "set tw=70 nosmartindent filetype=pdc");
$editor_command = qq(vim + -c "set tw=70 nosi filetype=pdc");
my $notesdir = ".";
my $file = "alog";
my $tempdir = qw(/tmp);
local $Text::Wrap::columns = 65;
my $template="alogghXXXXX";
# End of configuration lines.

# {{{ Getopt::Long stuff
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

=item -infile|file

The notes file to use. Backup file name is derived from this file
name approximately as below.

 my $backbn = "." . $file . ".backup";

This is optional. The default notes file is stored in C<$file>.

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

=head2 Description

Script for inserting and viewing records in a notes file.

A record is any text separated from the next record by C<//> (two forward
slashes) on a line of its own.

=head2 Configuration

The first line of the script is

 #!/usr/bin/perl

If your perl binary is located elsewhere, edit this line.

Then there are the following lines.

 my $editor_command;
 $editor_command = qq(vim + -c "set tw=70 nosi filetype=pdc");
 my $notesdir = ".";
 my $file = "alog";
 my $tempdir = qw(/tmp);
 local $Text::Wrap::columns = 65;
 my $template="alogghXXXXX";

In the above, you will certainly wish to change C<$notesdir>. It is
best to run your editor in the foreground so that you do not get your
prompt back till you are done writing. If you use C<gvim> then use the
C<-f> option to prevent it from forking and detaching from shell like
it usually does. C<vim> runs in the terminal and can be used as it it.
You might want to change C<$file> to a file name of your liking.

=head2 Author

govind.chandra@jic.ac.uk


=cut


# }}}


my $backbn = "." . $file . ".backup";
my $notesFile = File::Spec->catfile($notesdir, $file);
my $backFile = File::Spec->catfile($notesdir, $backbn);
my $curdir = abs_path();


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
  flock($nh, LOCK_EX);
  my $ts = localtime();
  if($dayadj) {
    my $tt = time();
    my $at = $tt + ($dayadj * 24 * 60 *60);
    $ts = localtime($at);
    $ts =~ s/\d+:\d+:\d+\s+//;
  }
  chomp($ts);
  print($nh "\n### $ts\n\n");
  print($nh "Directory: $curdir\n");
  print($nh "$wrapped\n");
  print($nh "//\n");
  $add = 0;
  flock($nh, LOCK_UN);
  close($nh);
}
# }}}

# {{{ add a note
if($add) {
  copy($notesFile, $backFile);
  my($fh, $fn)=tempfile($template, DIR => $tempdir, SUFFIX => '.tmp');
  print($fh "Directory: $curdir:\n\n");
  close($fh);
  system("$editor_command $fn");
  if(-f $fn and -s $fn) {
    open(my $nh, ">>", $notesFile);
    flock($nh, LOCK_EX);
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
    close($th);
    flock($nh, LOCK_UN);
    close($nh);
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

