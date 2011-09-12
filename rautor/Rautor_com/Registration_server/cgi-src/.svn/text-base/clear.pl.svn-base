#!/usr/bin/perl -w

use strict;
use warnings;


use Crypt::Tea;
use DBI();
use LWP::UserAgent;
use Getopt::Long;

my $VERBOSE;

my $res = GetOptions ( "verbose"  => \$VERBOSE);  # flag


# Main Program
my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"rautor","\\pass",
       	                 {'RaiseError' => 0}
		) || die "No Mysql connection \n";


	# first check for valid license
 	my $query="update sessions set clearedtime=now(),status='DEAD' where 
		( status='ALIVE' or status='START' ) and lastping<date_sub(now(),interval 5 minute); ";
	my $sth = $dbh->prepare($query);
  	my $result=$sth->execute;
	my $numRows = $sth->rows;
	print STDERR "Found $numRows dead Sessions\n" if ( $VERBOSE);
	$sth->finish;

$dbh->disconnect;

1;



