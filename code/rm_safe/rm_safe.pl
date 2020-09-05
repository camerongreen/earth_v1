#!/usr/bin/perl -w

##
#
# rm_safe
#
# Last revision : 20050225
#
# Script to provide a safe alternative to rm (typed with burnt hands)
# 
# Previously it backed everything up into one big directory, now
# by default it uses an individual user recycle directory.  This
# means it's not as cool, but it keeps files within a users quota.
#
# Written 27/01/2002 by i at camerongreen dot org 
# Use last revision data to identify script updates
#

use strict;
use Getopt::Long;
use Data::Dumper;

use constant DEFAULT_CLEAN_UP_DAYS => 31;

##
# my option declarations

my ($clean_up, $debug, $help, $user_recycle_dir, $user_undelete_extension);

##
# rm option declarations

my ($directory, $force, $recursive, $interactive, $undelete, $verbose);

##
# other declarations
#
my $recycle_dir = "~/.recycle/"; # default recycle directory
my $undelete_extension = "undeleted";


##
# get options
#
# don't know how to get getopts to handle mutliple single args
# like rf and fr etc...

GetOptions(	
	'recycle_dir=s'				=> \$user_recycle_dir,
	'debug'							=> \$debug,
	'd|fr|rf|directory'			=> \$directory,
	'c|clean_up:i'					=> \$clean_up,
	'h|help'							=> \$help,
	'f|force'						=> \$force,
	'r|recursive'					=> \$recursive,
	'u|un|undelete'				=> \$undelete,
	'ue|undelete_extension=s'	=> \$undelete_extension,
	'v|verbose'						=> \$verbose,
	'i|interactive'				=> \$interactive,
);


##
# Help
#

if ($help or (!$ARGV[0] and (not defined $clean_up)))  {
	&help();
	exit();
}

##
# set defaults for options
#

##
# set recycle directory if passed in
#
if ($user_recycle_dir) {
	$recycle_dir = &add_slash($user_recycle_dir);
}

$recycle_dir = &absolute_path($recycle_dir);

##
# if the users recycle dir doesn't exist
# make it for them
#
unless (-d $recycle_dir) {
	my $mk_recycle_dir = "mkdir $recycle_dir";

	if ($debug) {
		print ($mk_recycle_dir);
	}
	else {
		system ($mk_recycle_dir);
	}
	
	# make sure we actually made it
	unless (-d $recycle_dir) {
		die "Recycle directory does not exist : $recycle_dir";
	}
}



###
# if the user has chosen to clean up, clean up and exit
#
if (defined $clean_up) {
	if ($clean_up == 0) {
		$clean_up = DEFAULT_CLEAN_UP_DAYS;
	}

	&clean_up($recycle_dir, $clean_up, $debug);

	exit();
}


##
# set default undelete extension
#
if ($user_undelete_extension) {
	$undelete_extension = $user_undelete_extension;
}


##
# make a datestamp to put on various files 
#
my @localtime = localtime;

my $day = $localtime[3];
my $month = $localtime[4];

$day = ($day < 10 ? "0$day" : $day);
$month = (++$month < 10 ? "0$month" : $month);

my $todays_date = ($localtime[5] + 1900) . "${month}${day}";

my $date_dir = "${todays_date}/";

my $timestamp = $localtime[2] . $localtime[1] . $localtime[0];


###
# if the user has chosen to undelete, undelete each option in 
# turn and exit
#
if (defined $undelete) {
	foreach my $undel_file (@ARGV) {
		&undelete($undelete_extension, $recycle_dir, $undel_file, $debug);
	}

	exit();
}


##
# If no current folder for this day, make one
#
unless (-e "${recycle_dir}${date_dir}") {
	my $mkdir_statement = "mkdir ${recycle_dir}${date_dir}\n";
	if ($debug) {
		print ($mkdir_statement);
	}
	else {
		system ($mkdir_statement);
	}
}


##
# deal with parameters
#
my @cp_tags = ("--archive");
my @rm_tags;

if (($recursive) || ($directory)) {
	push @rm_tags, "-r";	
	push @cp_tags, "-R";	
}

if (($force) || ($directory)) {
	push @rm_tags, "-f";	
}

if ($verbose) {
	push @rm_tags, "-v";	
}

if ($interactive) {
	push @rm_tags, "-i";	
}

##
# Go through arguments, archive and then remove
#
foreach my $element (@ARGV) {

	# we remove a trailing slash here because bizarrely it won't
	# be recognized as a link with one
	$element =~ s/(.*)\/$/$1/;

	# if it is a symbolic link, we don't back it up
	if (-l $element) {
		my $rm_link_statement = "rm " . (join " ", @rm_tags) . " " . $element . "\n";

		if ($debug) {
			print ($rm_link_statement);
		}
		else {
			system ($rm_link_statement);
		}

		next;
	}

	# if it is a directory and not a link, we must have a
	# recursive statement
	if ((-d $element) && (!$recursive && !$directory)) {
		print "$element is a directory, requires recursion option\n";
		next;
	}
			
	if (-e $element) {
		my ($dir_path, $file_name) = &seperate_file_and_path($element);
		
		my $mod_path = &absolute_path($dir_path);
		
		my $mkdirpath_statement = "mkdir -p ${recycle_dir}${date_dir}${mod_path}\n";

		if ($debug) {
			print($mkdirpath_statement);
		}
		else {
			system($mkdirpath_statement);
		}

		# escape spaces in file names for statements
		$element =~ s/ /\\ /g;
		$file_name =~ s/ /\\ /g;

		my $cp_statement = "cp " . (join " ", @cp_tags) . " " . $element . " ${recycle_dir}${date_dir}${mod_path}${file_name}.${timestamp}\n";
		my $rm_statement = "rm " . (join " ", @rm_tags) . " " . $element . "\n";

		if ($debug) {
			print ($cp_statement);
			print ($rm_statement);
		}
		else {
			system ($cp_statement);
			system ($rm_statement);
		}
	}
	else {
		print "$element not found\n";
	}
}


############# FUNCTIONS ##############


## {{{ absolute_path()
#
# Takes any given path and converts it into 
# an absolute system path...
# faught with peril, but haven't had any problems
# yet..perhaps links will undo me
#
sub absolute_path {
	my ($path) = @_;

	# do nothing, path is absolute
	if (index($path, '/') == 0) {
		return $path;
	}

	# path starts with tilde
	if ($path =~ /^~(.*)/) {
		my $home = $ENV{'HOME'};
		$path = $home . $1;
		return $path;
	}

	# get the current directory
	my $pwd = $ENV{'PWD'};

	# path starts with pwd
	if ($path =~ /^\.(\/.*)/) {
		$path = $pwd . $1;
		return $path;
	}

	# now we deal with files with a straight relative path
	# or with parent directory operators ../
	my $tmp_path = $path;
	my @pwd_array = split('/', $pwd);
	
	# while path has parent directory operators in it
	# we pop the end of the pwd array for each one
	while ($tmp_path =~ /^\.\.\/(.*)/) {
		$tmp_path = $1;
		pop (@pwd_array);
	}

	$path = (join('/', @pwd_array)) . "/" . $tmp_path;

	return $path;
}
# }}}


## {{{ add_slash()
# 
# just makes sure path has slash on the end
# if not, puts one there for consistency
#
sub add_slash {
	my ($path) = @_;

	unless ($path =~ /(.*)\/$/) {
		$path .= "/";
	}
	
	return $path;
}
# }}}


## {{{ seperate_file_and_path()
#
# takes a path and returns array
# first element is path
# second element is file
#
sub seperate_file_and_path {
	my ($path) = @_;

	$path =~ /^(.*?)([^\/]*)\/*$/;

	my @return_val = ($1, $2);
	
	return @return_val;
}
# }}}


## {{{ undelete()
# 
# Undelete a deleted file
# 
# string: undelete extension
# string: recycle dir
# string: file name
# int(bool): debug
#
sub undelete {
	my ($undelete_extension, $recycle_dir, $file, $debug) = @_;

	my $find = "find $recycle_dir -regex '.*\\.*$file.*'";

	if ($debug) {
		print "$find\n";
	}

	my $find_results = `$find`;

	my @find_elements = split /\n/, $find_results;
	my %find_hash;

	my $num_elements = @find_elements;

	if ($num_elements == 0) {
		print "No elements matching filename : $file\n";
		exit();
	}

	my $counter = 0;
	my %friendly_count_hash = ();

	for (my $key = 0; $key < $num_elements; $key++) {
		my $tmp_display_dir = substr($find_elements[$key], length($recycle_dir));
		if ($tmp_display_dir =~ /^(\d{8})(.*)\.(\d+)$/) {

			printf "%-" . (length($num_elements)) . "i > %i %s %i\n", (++$counter), $1, $2, $3;
			$find_hash{$key}{"recycle_file"} = $find_elements[$key];
			$find_hash{$key}{"original_file"} = $2;
			$find_hash{$key}{"time_stamp"} = $3;
			$friendly_count_hash{$counter} = $key;
		}
		elsif ($debug) {
			print "Date not matched: $find_elements[$key] ($tmp_display_dir)\n";
		}
	}

	printf "%-" . (length($num_elements)) . "s > %s\n", "q", "quit";

	my $response = <STDIN>;
	chop($response);

	if ($response !~ /([0-9]+|q)/) {
		print "Invalid Choice.\n";
		exit();
	}

	if ($response eq "q") {
		print "Quitting\n";
		exit();
	}

	$response =~ /([0-9]+)/ ;

	my $int_response = $friendly_count_hash{$1};

	if (!$int_response || ($int_response > $num_elements)) {
		print "Invalid index into options.\n";
		exit();
	}

	# if the original file already has the undeleted extension
	# don't add it again
	if ($find_hash{$int_response}{"original_file"} =~ /\.$undelete_extension$/) {
		$undelete_extension = "";
	}	

	my $mv_statement = "mv " . $find_hash{$int_response}{"recycle_file"} . " " . $find_hash{$int_response}{"original_file"} . ($undelete_extension eq "" ? "" : ".${undelete_extension}");

	if ($debug) {
		print ($mv_statement . "\n");
	}
	else {
		system ($mv_statement);
	}
	
}
# }}}


## {{{ clean_up()
# 
# Remove old files
# 
# string: recycle dir
# string: remove days
# bool: debug
#
sub clean_up {
	my ($recycle_dir, $remove_days, $debug) = @_;

	my $find_statement = "find $recycle_dir -ctime +$remove_days -type d 2> /dev/null | egrep -e '[2-3][0-9][0-9][0-9][01][0-9][0-3][0-9]'";
	my $rm_statement = "xargs \\rm -fr\n";

	if ($debug) {
		print($find_statement . " | " . $rm_statement);
		system ($find_statement);
	}
	else {
		system($find_statement . " | " . $rm_statement);
	}
	
}
# }}}


## {{{ help()
#
# show some help
#
#
sub help {

	my $default_clean_up_days = DEFAULT_CLEAN_UP_DAYS;

	print qq^
Usage : 
	rm_safe.pl --help --debug --clean_up[=i] --recycle_dir {other...} 
 
Options :
	undelete|u : 
		retrieve file from (unzipped) directory

	clean_up : optional integer
		Remove files older than this number of days (default is $default_clean_up_days) 

	recycle_dir : string
		directory to save files, default is ~/recycle

	debug : boolean
		print out system commands rather than execute
		
	help : boolean
		help!
		
	other
		as per rm man page

Note :
	put the --clean_up option in your cron to regularly clean up your directory
	use \\rm to access original rm
	some multiple args will need to be seperate attribs ie -xyz -> -x -y -z
^;
}
# }}}
