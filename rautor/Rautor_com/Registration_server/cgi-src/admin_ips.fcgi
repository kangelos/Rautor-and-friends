#!/usr/bin/perl -w

use strict;
use warnings;


use CGI::Fast qw(:standard);
use Crypt::Tea;
my $KEY='perl -e "{print \$key}"';


$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads
use DBI();

my $VERBOSE=0;


# Main Program
CGI: while (my $query=new CGI::Fast) {
# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"rautor","\\pass",
       	                 {'RaiseError' => 0}
		);
if ( ! $dbh ) {
	print STDERR "No Mysql connection \n";
	die;
}

	print header;


        my $user=$query->param('user');
        my $pass=$query->param('pass');
        my $decpass=decrypt($pass,$KEY);


	print STDERR "$user $decpass" if ( $VERBOSE);	

        if  (
                ( ! $user ) || ( ! $pass) || ( ! $decpass)
         )  {
                print "RAUTOR:ERROR Unauthorized";
                next CGI;
        }
        print STDERR "user=$user pass=$decpass\n" if ( $VERBOSE);

        if ( $decpass ne '$RAUTORPASS' ) {
                print "RAUTOR:ERROR Unauthorized";
                next CGI;
        }

	# update session if existing;
	my $xquery="select  username,ip,lastreview from  admin_logins where lastreview >= now() -  interval 15 Minute ";
	print STDERR "query=" . $xquery . "\n" if ( $VERBOSE );
	my $sth = $dbh->prepare($xquery);
  	$sth->execute;
    	my $numRows = $sth->rows;
	my $IPS=$ENV{'SERVER_ADDR'};
	for ( my $i=1;$i<=$numRows;$i++){
		my ($user,$ip,$review) = $sth->fetchrow_array();
		$IPS=$IPS.",".$ip;
	}
	print $IPS."\r\n";

$dbh->disconnect;
}

1;

