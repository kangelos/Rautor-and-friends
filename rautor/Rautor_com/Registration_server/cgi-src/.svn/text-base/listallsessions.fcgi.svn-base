#!/usr/bin/perl -w

use strict;
use warnings;


use CGI::Fast qw(:standard);
use Crypt::Tea;
use DBI();
use LWP::UserAgent;


my $KEY='perl -e "{print \$key}"';

$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads

my $ua = new LWP::UserAgent;
$ua->agent("$0/0.1 " . $ua->agent);
$ua->agent("Mozilla/8.0"); # pretend we are very capable browser

my $VERBOSE=0;

my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"root","banana",
       	                 {'RaiseError' => 0}
		);
if ( ! $dbh ) {
	print STDERR "No Mysql connection \n";
	die;
}

CGI: while (my $query=new CGI::Fast) {
	print header;

	my $period=$query->param('period');

	# update session if existing;
	my $query;
	if ( $period eq "today" ) {
		$query="select  username,sessionid,ipaddress,timestamp,port,node,domain from  sessions 
				order by timestamp,username
		";
	} else {
		$query="select  username,sessionid,ipaddress,timestamp,port,node,domain from  sessions ";
}
	print STDERR "query=" . $query . "\n" if ( $VERBOSE );
	my $sth = $dbh->prepare($query);
  	$sth->execute;
    	my $numRows = $sth->rows;
	if ( $numRows <= 0 ){
			print "No current session detected\r\n";
			next CGI;
	}
		print "<table border=1>";
		print "<tr><th>domain:node\\\\user</th>\n";
		print "<th>timestamp</th>\n<th>URL</th>\n";
		print "</tr>\n";
	for ( my $i=1;$i<=$numRows;$i++){
		my ($user,$sessionid,$ipaddress,$timestamp,$port,$node,$domain) = $sth->fetchrow_array();
		my $href="http://" . $ipaddress . ":$port/" . $sessionid . "/monitor";

		if ( ( $i %2) == 0 ) {
			print "<tr>";
		} else {
			print "<tr bgcolor=\"#878787\">";
		}
		print "<td>$domain:$node\\\\$user</td>";
		print "<td>$timestamp</td>";
		my $req = new HTTP::Request 'GET' => $href;
      		$req->header('Accept' => 'text/html');

		      # send request
		my      $res = $ua->request($req);

      	# check the outcome
      	if ($res->is_success) {
			print "<td><a href=\"$href\" target=\"$user\">Monitor</a></td>";
		} else {
			print "<td></td>";
		}
		print "</tr>\n";
	}
	$sth->finish;

print "</table>";
#	print "<table width=\"100%\" height=\"100%\" cellspacing=0 cellpadding=\"0\" border=\"1\"><tr><td>";
#	print "<!--Latest session id:$sessionid seen at $timestamp from IP $ipaddress -->";
#	print "<IFRAME SRC=\"$href\" width=\"100%\" height=\"100%\">
#		If you can see this, your browser doesn't 
#		understand IFRAME.  However, we'll still 
#		connect you<A HREF=\"$href\">to your PC</A> 
#		</IFRAME>
#		";
#	print "</td></tr></table>\r\n";
}

$dbh->disconnect;
print  STDERR "$$ Exiting / why ? ";

1;

