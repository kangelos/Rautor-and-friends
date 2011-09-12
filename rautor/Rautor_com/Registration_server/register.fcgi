#!/usr/bin/perl -w

use strict;
use warnings;


use CGI::Fast qw(:standard);
use Crypt::Tea;
my $KEY='perl -e "{print \$key}"';
my $RAUTORPASS='$RAUTORPASS';

$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads
use DBI();
use LWP::UserAgent;
my $ua = new LWP::UserAgent;
$ua->agent("$0/0.1 " . $ua->agent);
$ua->agent("Mozilla/8.0"); # pretend we are very capable browser


my @SESSIONS;



my $VERBOSE=5;
our %BADURLS;
our @EXPRESSIONS;
my $category=0;




my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"root","banana",
       	                 {'RaiseError' => 0}
		);
if ( ! $dbh ) {
	print STDERR "No Mysql connection \n";
	die;
}

print STDERR "$$ URL Checker Ready\n";
# Main Program
CGI: while (my $query=new CGI::Fast) {
# Connect to the database.

	print header;

	my $user=$query->param('user');
	my $pass=$query->param('pass');
	my $decpass=decrypt($pass,$KEY);
	my $session=$query->param('session');
	my $IP=$ENV{'REMOTE_ADDR'};
	my $node=$query->param('node');
	my $port=$query->param('port');
	my $domain=$query->param('domain');
	my $status=$query->param('status');

	if ( $IP ) {
		if ( $IP eq "80.76.38.68" ) { $IP="10.10.11.162"; }
	}


	if  ( 
		( ! $user ) || ( ! $pass) || ( ! $session) || ( ! $decpass)
	 )  {
		print "RAUTOR:ERROR Unauthorized";
		next CGI;
	}
	print STDERR "user=$user pass=$decpass session=$session ip=$IP\n" if ( $VERBOSE);

	if ( $decpass ne $RAUTORPASS ) {
		print "RAUTOR:ERROR Unauthorized";
		next CGI;
	}

	cleardeadsessions($dbh) if (finddeadsessions($dbh,$user,$domain));
	# insert new session
	$query="insert into sessions (username,sessionid,timestamp,ipaddress,port,node,domain,status,clearedtime) values ('$user','$session',now(),'$IP','$port','$node','$domain','$status',null)";
	print STDERR "query=" . $query . "\n" if ( $VERBOSE );
	my $sth = $dbh->prepare($query);
  	my $result=$sth->execute;
	$sth->finish;
	if ( ! $result) {
		print "RAUTOR:ERROR could not insert session id";
		print STDERR "Rautor cannot insert sessionid=$session from ip=$IP\n";
	}
	print "RAUTOR:Registration OK\r\n";
	print STDERR "Rautor Registered session=$session ip=$IP user=$user\n" if ( $VERBOSE);
}

$dbh->disconnect;
print  STDERR "$$ Exiting / why ? ";

1;


sub finddeadsessions {
my $dbh=shift;
my $user=shift;
my $domain=shift;

	my $query="select  sessionid,ipaddress,port from  sessions where status='START' and username='$user' and domain='$domain'; ";
	my $sth = $dbh->prepare($query);
  	$sth->execute;
    	my $numRows = $sth->rows;
	if ( $numRows <= 0 ){
			print STDERR  "No  other sessions detected for user $user\r\n";
			return undef;
	}
	for ( my $i=1;$i<=$numRows;$i++){
		my ($sessionid,$ipaddress,$port) = $sth->fetchrow_array();
		my $href="http://" . $ipaddress . ":$port/" . $sessionid . "/monitor";
		my $req = new HTTP::Request 'GET' => $href;
      		$req->header('Accept' => 'text/html');
		my      $res = $ua->request($req);

      	# check the outcome
      	if ($res->is_success) {
			print "$sessionid is active\n";
		} else {
			push @SESSIONS,$sessionid;
		}
	}
	$sth->finish;
	return 1;
}

sub cleardeadsessions {
my $dbh=shift;

	foreach my $session (@SESSIONS) {
		print $session . "\n";
		my $query="update sessions set   clearedtime=now(),status='Logged Out' where sessionid='$session'; ";
		print STDERR "query=" . $query . "\n" if ( $VERBOSE );
		my $sth = $dbh->prepare($query);
  		$sth->execute;
		$sth->finish;
	}

}


