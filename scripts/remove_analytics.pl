#!/user/bin/perl -w

use strict;
use warnings FATAL => 'all';

my $start_text = '<script src="http://www.google-analytics.com/urchin';
my $end_text = '</script>';

my $removing = 0;
my $found_script = 0;

open my $file, $ARGV[0] or die "Unable to open $!";

my @output;

while (my $line = <$file>) {
  if (index($line, $start_text) == 0) {
    $removing = 1;
  }
  elsif ($removing) {
    $line =~ s/\s$//g;

    # There are two script tags.
    if ($line eq $end_text) {
      if (!$found_script) {
        $found_script = 1;
      }
      else {
        $removing = 0;
      }
    }
  }
  else {
    push @output, $line;
  }
}

close $file;

open my $write_file, '>', $ARGV[0] or die "Unable to open 2 $!";
print $write_file @output;
close $write_file;
