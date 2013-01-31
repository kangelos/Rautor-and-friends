#!/usr/bin/perl -w
#
# A screen grabber with an embedded Web Server
# Angelos Karageorgiou
# angelos@unix.gr
#
# remember to apt-get/ymu install scrot   
#
#
# Point your borwser to the URLs the program spirts out and you get your
# peer's screen
#

package Rautor; # look for it under sourceforge


use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use HTTP::Request;
use IO::Socket::INET;
use IO::Select;
use File::Temp qw|tempdir|;
use Fcntl qw |:flock|;
use Carp;
use Getopt::Long;

my $PORT=42000;
my $VERBOSE='';
my $format="png";
my $imgFname="screen.$format";
my $SLEEP=3;
my $GRABBER="/usr/bin/X11/scrot -z ";
my $FOCUS;
my $SCALED;


my $RepeatHeader="<HEAD><META HTTP-EQUIV=REFRESH CONTENT=$SLEEP></HEAD>\r\n
<table width='100%' height='100%' border='0' cellpadding='2' cellspacing='2' style='position:relative'>\r\n
";


if ( ! -f "/usr/bin/X11/scrot" ) {
	print "I need the scrot application, please install it\n";
	exit(2);
}

GetOptions (	"refresh=i"	=> \$SLEEP,
                "focus"		=> \$FOCUS,      
                "focused"	=> \$FOCUS,      
                "verbose"	=> \$VERBOSE,
                "scaled"	=> \$SCALED,
                "scale"		=> \$SCALED,
                "help"		=> \$HELP
	);  

if ( $HELP ) {
	print "\nUsage: ShareMyScreen.pl [--help] [--verbose] [--focus] [--refresh=seconds]
		--help:		this help
		--verbose:	verbose
		--focus[ed]:	share only the window that has the focus
		--scale[d]:	Produce scaled Image
		--refresh:	refresh every so many seconds

Defaults are: 
	Full Desktop sharing, 
	unscaled , 
	terse, 
	refresh every $SLEEP secs
";
exit(0);
}


if ( $FOCUS ) {
	$GRABBER=$GRABBER . " -u ";
}
my $sessdir = tempdir ( "sessXXXXXX", TMPDIR => 1 , CLEANUP => 1);

open(my $LOCKFILE ,">/tmp/sesslock") || carp("cannot create lock file");

$HTTP::Daemon::PROTO = "HTTP/1.0";
my $daemon  = HTTP::Daemon->new(Listen=>3,LocalPort=>$PORT, ReuseAddr=>1) || die "Cannot spawn http server, Is port $PORT in use?";
my $sel= IO::Select->new();
$sel->add($daemon);


@myips=split("\n", `ifconfig -a | grep "inet addr:" | cut -f2 -d: | awk '{print \$1}'`);

print "$0 starting\n Valid Urls are:\n";
foreach $ip (@myips) {
	next if ($ip eq "127.0.0.1");
	printf "http://$ip:$PORT\n";
}


while(my @ready = $sel->can_read()) { # 1 sec timeout
     foreach my $fh (@ready) {
         if($fh == $daemon) {
            # Create a new socket
            my $new = $daemon->accept;
            $sel->add($new);	# add it to the select list
         } else {
		my @ip = unpack("C4",$fh->peeraddr);
		my $ip=join(".",@ip);
		print "Connection from $ip\n" if ( $VERBOSE);
		process_one_req($fh,$ip);
		$sel->remove($fh);
		$fh->close;
        }
    }
  }

1;

########################################################################################
sub process_one_req {
my $connection = shift;
#my $SESSIONID=shift;
my $IP=shift;

	my $RepeatHTML=$RepeatHeader;

 	my $receiver = $connection->get_request;
	if ( ! $receiver ) {
		return;
	}
	if (! ($receiver->method eq 'GET') ){					# Method GET
       		$connection->send_error(RC_FORBIDDEN);
			return;
	}
	$receiver->url->path =~ m/^\/(.*)$/mi;
	my $path=$1;

	if ( ($path eq "monitor" ) || ($path eq "" ) ) 	{
		domonitor($connection,$RepeatHTML,$IP);
		return;
	}

    if  ($path =~ /^screen([1-9]*).$format$/ )  {	# Screen[1-9].$format

		my $scrnum=1;
		if ( $1 ) {
			$scrnum=$1;
		}
		my $res=screendumper_UNIX($scrnum);
		my $fname="screen".$scrnum.".$format";
		if ( $fname eq "screen.$format" ) {
			$fname="screen1.$format";
		}
		if ( ! -f "$sessdir/$fname" )  {
          		$connection->send_error(404,"Could not grab the screen num $scrnum");
			$connection->close;
			undef($connection);
			return;
		}
       		my $response = HTTP::Response->new(200);
		$connection->send_file_response("$sessdir/$fname");
		unlink $fname;
		return;
	}

	# no matches
	$connection->send_error(RC_FORBIDDEN);
}

######################################################################
sub domonitor{
	my ($connection,$RepeatHTML,$SESSIONID,$IP)=@_;
	my $span=2;
	my $NumScreens=1;
	my $KEYLOG="";
	for (my $i=1;$i<=$NumScreens;$i++){
		my $fname="screen".$i.".$format";
		$RepeatHTML .= "<tr><td colspan=$span>";
		if ( $SCALED ) {
			$RepeatHTML .= "<img src=\"/$fname\" width='100%' height='100%' align=center></td>\r\n";
		} else {
			$RepeatHTML .= "<img src=\"/$fname\" align=center></td>\r\n";
		}
		if ( ( $i % 2 ) == 0 ) {
			$RepeatHTML .= "</tr>\r\n<tr>";
		}
	}

	$RepeatHTML .= "</tr>";

	$RepeatHTML .= "</table>";

    my $response = HTTP::Response->new(length($RepeatHTML));
    $response->content($RepeatHTML);
	$connection->send_response($response);
	$KEYLOG=""; # reset untill next call
}

############################################################
sub screendumper_UNIX{
	my $scrnum=shift;
	lock($LOCKFILE);
	print "Calling system\n" if ( $VERBOSE );
	system($GRABBER . " ". $sessdir . "/screen" . $scrnum . ".". $format);
	print "Import done via $GRABBER" if ( $VERBOSE );
	unlock($LOCKFILE);
	return 1;
}

############################################################
sub lock {
	my ($fh) = @_;
	flock($fh, LOCK_EX) or die "Cannot lock session - $!n";
}

############################################################
sub unlock {
	my ($fh) = @_;
	flock($fh, LOCK_UN) or die "Cannot unlock session - $!n";
}
