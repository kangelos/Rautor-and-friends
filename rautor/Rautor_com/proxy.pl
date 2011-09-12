#!/usr/bin/perl -w
use strict;
use warnings;


package Rautor;

# Proxy stuff
use HTTP::Proxy qw( :log );
use HTTP::Proxy::Engine;
use HTTP::Proxy::Engine::Legacy;
use HTTP::Proxy::Engine::NoFork;
use HTTP::Proxy::HeaderFilter::simple;
use Getopt::Long;
use Carp;

use URI;
use vars qw( $re );

# cgi calling stuff
use CGI::Util qw  (escape unescape);
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;


my $VERBOSE='';
# remember a bit
my @BADURLS;	
my @GOODURLS;



my $no = HTTP::Response->new( 200 );
$no->content_type('text/html');
$no->content('.');



my $forbidden = HTTP::Response->new( 200 );
$forbidden->content_type('text/html');
$forbidden->content('
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html> <head>
<title>Forbidden</title>
<meta http-equiv="REFRESH" content="0;url=http://rautor.microbase.net.gr/verbotten.php">
</HEAD> </HTML>
');

my $error = HTTP::Response->new( 200 );
$error->content_type('text/html');
$error->content('
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html> <head>
<title>Filter Error</title>
<h3> RautorProxy could not clear your browsing request<h3>
because a network error occured<br>
Please try again
</HEAD> </HTML>
');


my $nocomm = HTTP::Response->new( 200 );
$nocomm->content_type('text/html');
$nocomm->content('
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html> <head>
<title>Communications Error</title>
<h3> Cannot communicate with the URL clearing house</h3>
Please try again
</HEAD> </HTML>
');

my $ua = new LWP::UserAgent(
			timeout=>5,
			agent=>'RautorProxy',
		);

sub cleanupUrl;

my $filter = HTTP::Proxy::HeaderFilter::simple->new( sub {
   my ( $self, $headers, $message ) = @_;
   my $str = $message->uri;

   	# first see if you rememember anything;
	print STDERR "Checking:$str\n" if ( $VERBOSE );
	my $cleanUrl=cleanupUrl($str);
	foreach my $url (@GOODURLS){
		if (  $cleanUrl =~ /^$url/gi ) {
			print STDERR "REMEMBERED:GOODURL $url\n\n" if ( $VERBOSE);
			return;
		}
	}
	foreach my $url (@BADURLS){
		if ( $cleanUrl =~ /$url/gi ) {
			print STDERR "REMEMBERED:BADURL $url\n\n" if ( $VERBOSE);
			return;
		}
	}


	# check against our engine
	print STDERR "CGI URLChecking:$str\n" if ( $VERBOSE);
      	my $req = $ua->post('http://rautor.microbase.net.gr/cgi-bin/checkurl.fcgi',
                    [ 
		    	url => $str,
		        user => 'angelos',
			pass => 'xarmosyno',	
		    	errors => 1 
		]);
 	if (! $req->is_success) {
		 $self->proxy->response( $nocomm );
		 print STDERR "ERROR:COMMUNICATIONS failed\n\n" if ( $VERBOSE );
		 return;
 	}
		
	my $response=$req->content;
	if ( ! $response ) {
		 $self->proxy->response( $nocomm );
		 print STDERR "ERROR:COMMUNICATIONS failed\n\n" if ( $VERBOSE );
		 return;
	}


	print STDERR "<<" . $response ."\n" if ( $VERBOSE);
	if (
	       	( $response =~ /RAUTOR:ERROR/ ) ||
	       	( $response =~ /\serror[\s]/ )  ||
		( $response !~ /RAUTOR/) 
	){
		 print STDERR "ERROR: $response\n\n" if ( $VERBOSE);
		 $self->proxy->response( $error );
		 return;
	}

	if ( $response =~ /RAUTOR:BLACKLISTURL/ ) {
		my ($temp,$url)=split (/ /,$response);
		push @BADURLS,$url;
		print STDERR "SAVING:BADURL $url\n\n" if ( $VERBOSE);
		 $self->proxy->response( $forbidden );
		 return;
	 }

	 # we made it this far, it must be a good url
	if ( $response =~ /RAUTOR:CLEAR/ ) {
		my ($temp,$url)=split (/ /,$response);
		push @GOODURLS,$url;
		print STDERR "SAVING:GOODURL $url\n\n" if ( $VERBOSE);
		# let is pass through it's good
	 }

} );


my $logfile='';
GetOptions ( 
	'logfile=s' => \$logfile ,
	'verbose'   => \$VERBOSE,
);

if ($logfile) {
	open(STDERR,">$logfile") or carp "Failed to redirect STDERR";
}


my $proxy = HTTP::Proxy->new( 	port => 8080,
				timeout => 15,
			) || carp "Could not create proxy";
$proxy->push_filter( request => $filter );
$proxy->start;
1; # all done

sub cleanupUrl{
	my $url=shift @_;

	my @uelems=split(/\//,$url);
        my @domparts=split(/\./,$uelems[2]);
	return $uelems[2];

	# the following code creates back doors;
	#
	#
        my $newdomain="";# clean up the domain part getting rid of the first component
        if ( $#domparts > 1 ) {
                for (my $i=1;$i<=$#domparts;$i++){
                        $newdomain .= $domparts[$i] . ".";
                }
        } else {
                $newdomain=$uelems[2];
        }
        $newdomain =~ s/\.$//g;
        $newdomain =~ s/:[0-9]*$//g;
        $newdomain =~ s/\/$//g;
	return $newdomain;
}

