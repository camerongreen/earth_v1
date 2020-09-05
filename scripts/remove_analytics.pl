#!/user/bin/perl -w

my $start_text = '<script src="http://www.google-analytics.com/urchin';
my $end_text = '</script>';

my $removing = 0;
my $found_script = 0;

open my $file, '<', $ARGV[1] or die "Unable to open $!";

my @output;

while (<$file>) {
  if (index($_, $start_text) == 0) {
    $removing = 1;
  }
  elsif ($removing) {
    my $line = $_;
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
  } else {
    push @output, $_;
  }

  close $file;

  open my $file, '>', $1 or die "Unable to open 2 $!";
  print $file @output;
  close $file;
}
