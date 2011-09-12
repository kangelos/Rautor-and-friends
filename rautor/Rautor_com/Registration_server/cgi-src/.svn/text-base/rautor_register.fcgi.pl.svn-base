#!/usr/bin/perl -w

use strict;
use warnings;


use CGI::Fast qw(:standard);
use Crypt::Tea;
use DBI();
use LWP::UserAgent;


$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads
my $ua = new LWP::UserAgent;
$ua->agent("$0/0.1 " . $ua->agent);
$ua->agent("Mozilla/8.0"); # pretend we are very capable browser
my $KEY='perl -e "{print \$key}"';
my $RAUTORPASS='$RAUTORPASS';
my @SESSIONS;
my $VERBOSE=1;
my $category=0;
my $MAXLICENSES=10;
my $query;
my $sth;
my $result;

# Main Program
CGI: while (my $cgi=new CGI::Fast) {
my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"rautor","\\pass",
       	                 {'RaiseError' => 0}
		) || die "No Mysql connection\n";

	print header;
	my $user=$cgi->param('user');
	my $pass=$cgi->param('pass');
	my $decpass=decrypt($pass,$KEY);
	my $path=$cgi->param('path'); $path =~ s/\\/\\\\/gi;
	my $IP=$ENV{'REMOTE_ADDR'};
	my $node=$cgi->param('node');
	my $domain=$cgi->param('domain');
	my $status=$cgi->param('status');

	if ( $IP ) {
		if ( $IP eq "80.76.38.68" ) { $IP="10.10.11.162"; }
	}


	if  ( 
		( ! $user ) || ( ! $pass) || ( ! $path) || ( ! $decpass)
	 )  {
		print "RAUTOR:ERROR Unauthorized";
		next CGI;
	}
	print STDERR "user=$user pass=$decpass path=$path ip=$IP status=$status\n" if ( $VERBOSE);

	if ( $decpass ne $RAUTORPASS ) {
		print STDERR "RAUTOR:ERROR Unauthorized";
		print "RAUTOR:ERROR Unauthorized";
		next CGI;
	}

	# first check for valid license
 	$query="select distinct node,domain,username from rautor_sessions where lastping >= date_sub(now(),interval 1 minute);";
	print STDERR "query=" . $query . "\n" if ( $VERBOSE );
	$sth = $dbh->prepare($query);
  	$result=$sth->execute;
	if ( ! $result) {
		print "RAUTOR:ERROR could not count sessions";
		print STDERR "RAUTOR:ERROR could not count sessions" if ( $VERBOSE);
		next CGI;
	}
	my $numRows = $sth->rows;
	$sth->finish;
	if ( $numRows > $MAXLICENSES) { 
		print "RAUTOR:ERROR out of licenses\r\n";
		print STDERR "RAUTOR:ERROR out of licenses\r\n" if ( $VERBOSE);
		next CGI;
	}




	# insert new session
	if ( $status eq "START" ) {
		$query="insert into rautor_sessions (username,path,starttime,lastping,ipaddress,node,domain,status) values ('$user',\"$path\",now(),now(),'$IP','$node','$domain','$status')";
		print STDERR "query=" . $query . "\n" if ( $VERBOSE );
		$sth = $dbh->prepare($query);
  		$result=$sth->execute;
		$sth->finish;
		if ( ! $result) {
			print "RAUTOR:ERROR could not insert session";
			print STDERR "Rautor cannot insert path:$path from ip=$IP\n";
			next CGI;
		}
		print "RAUTOR:Registration OK\r\n";
		print STDERR "$$ Rautor Registered path=$path ip=$IP user=$user\n" if ( $VERBOSE);
		next CGI;
	}



	# update a session
	if ( $status eq "ALIVE" ) {
		$query="update rautor_sessions set status='ALIVE',lastping=now() where path=\"$path\" and username='$user' and node='$node' and domain='$domain'; ";
		print STDERR "query=" . $query . "\n" if ( $VERBOSE );
		my $sth = $dbh->prepare($query);
  		my $result=$sth->execute;
		$sth->finish;
		if ( ! $result) {
			print "RAUTOR:ERROR could not update session";
			print STDERR "Rautor could not update session path=$path\n";
			next CGI;
		}
		print "RAUTOR:Registration OK\r\n";
		print STDERR "$$ Rautor updated path=$path ip=$IP user=$user\n" if ( $VERBOSE);
		next CGI;
	}
	
$dbh->disconnect;
}


1;



