#!/usr/bin/perl -w

use strict;
use warnings;
my $VERBOSE=0;

use DBI();
use LWP::UserAgent;
my $ua = new LWP::UserAgent;
$ua->agent("$0/0.1 " . $ua->agent);
$ua->agent("Mozilla/8.0"); # pretend we are very capable browser


my @SESSIONS;

my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"root","banana",
       	                 {'RaiseError' => 0}
		);
if ( ! $dbh ) {
	print STDERR "No Mysql connection \n";
	die;
}

cleardeadsessions($dbh) if (finddeadsessions($dbh));

$dbh->disconnect;

sub finddeadsessions {
my $dbh=shift;
	my $query="select  username,sessionid,ipaddress,timestamp,port,node,domain from  sessions where status='START'; ";
	my $sth = $dbh->prepare($query);
  	$sth->execute;
    	my $numRows = $sth->rows;
	if ( $numRows <= 0 ){
#			print "No active  sessions detected\r\n";
			return undef;
	}
	for ( my $i=1;$i<=$numRows;$i++){
		my ($user,$sessionid,$ipaddress,$timestamp,$port,$node,$domain) = $sth->fetchrow_array();
		my $href="http://" . $ipaddress . ":$port/" . $sessionid . "/monitor";
		my $req = new HTTP::Request 'GET' => $href;
      		$req->header('Accept' => 'text/html');
		my      $res = $ua->request($req);

      	# check the outcome
      	if (! $res->is_success) {
			push @SESSIONS,$sessionid;
		}
	}
	$sth->finish;
	return 1;
}

sub cleardeadsessions {
my $dbh=shift;

	foreach my $session (@SESSIONS) {
		my $query="update sessions set   clearedtime=now(),status='END' where sessionid='$session'; ";
		print STDERR "query=" . $query . "\n" if ( $VERBOSE );
		my $sth = $dbh->prepare($query);
  		$sth->execute;
		$sth->finish;
	}

}


1;


1;

