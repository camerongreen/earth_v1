#!/user/bin/perl -w

$start_text = '<script src="http://www.google-analytics.com/urchin';
$end_text = '</script>';

$removing = 0;
$found_script = 0;

while (<>) {
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
    print $_;
  }
}
