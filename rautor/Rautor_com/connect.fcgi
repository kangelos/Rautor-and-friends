#!/usr/bin/perl -w

use strict;
use warnings;


use CGI::Fast qw(:standard);
use Crypt::Tea;
my $KEY='perl -e "{print \$key}"';


$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads
use DBI();



my $VERBOSE=1;
our %BADURLS;
our @EXPRESSIONS;
my $category=0;




my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"root","",
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
	my $IP=$ENV{'REMOTE_ADDR'};



	if  ( ( ! $user ) || ( ! $pass ))  {
		print "RAUTOR:ERROR Unauthorized";
		next CGI;
	}

	# first authenticate the user;
	my $query="SELECT username from users where username='$user' and password='$pass'";
	print STDERR "query=" . $query . "\n" if ( $VERBOSE );
	my $sth = $dbh->prepare($query);
  	$sth->execute;
    	my $numRows = $sth->rows;
	$sth->finish;
	if ( $numRows <= 0 ){
		print "RAUTOR:ERROR Unauthorized \r\n";
		print STDERR "Rautor Bad Connection Authorization user=$user badpass=$pass from ip=$IP\n";
		next CGI;
	}

	# update session if existing;
	$query="select  sessionid,ipaddress,timestamp from  sessions  where username='$user'";
	print STDERR "query=" . $query . "\n" if ( $VERBOSE );
	$sth = $dbh->prepare($query);
  	$sth->execute;
    	$numRows = $sth->rows;
	if ( $numRows <= 0 ){
			print "No current session detected\r\n";
	}
	my ($sessionid,$ipaddress,$timestamp) = $sth->fetchrow_array();
	$sth->finish;
	my $href="http://" . $ipaddress . ":42000/" . $sessionid . "/monitor";

#	print "<table width=\"100%\" height=\"100%\" cellspacing=0 cellpadding=\"0\" border=\"1\"><tr><td>";
	print "<!--Latest session id:$sessionid seen at $timestamp from IP $ipaddress -->";
	print "<IFRAME SRC=\"$href\" width=\"100%\" height=\"100%\">
		If you can see this, your browser doesn't 
		understand IFRAME.  However, we'll still 
		connect you<A HREF=\"$href\">to your PC</A> 
		</IFRAME>
		";
#	print "</td></tr></table>\r\n";
}

$dbh->disconnect;
print  STDERR "$$ Exiting / why ? ";

1;

