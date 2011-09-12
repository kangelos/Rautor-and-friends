#!wperl.exe -w
#
# Rautor initialization stuff
# Released unde the GPLv2

use common::sense;

package Rautor;

use Win32::TieRegistry ( Delimiter=>'/');
use POSIX qw(strftime);

our $DRIVE;
our $AUDITDIR;
our $FTPSERVER;
our $FTPUSER;
our $FTPPASS;
our $KEEPFILES;
our $SLEEP;
our $QUANTUM;
our @WINDOWSNAMES;
our $TRIGGER;
our $LICENSE;
our $KEYLOGGER;
our $SCREENDUMPER;
our $SCREENSCRAPER;
our $FULLSCRAPE;
our $VERBOSE;
our $LEGALWARNING;
our $DEBUG;
our $DEMO;
our $DECSN;
our $STARTYEAR;
our $ENDYEAR;
our $ENDMONTH;
our $MYNAME;
our $OPENDNS;
our $DIRECTSITES;
our $PROXY;
our $PROXYSERVER;
our $PROXYPORT;
our $PROXYLOCK;
our $path;
our $user;
our $Node;
our $domain;
our $FTPQueue;
our $MSGDLLPATH;



######################################################################
sub initDebug{
	
	if ( $DEBUG ) {
		open(STDOUT, ">$path/DEBUG.TXT") || ($DEBUG=0);
	}
   	if ( $DEBUG==0 ) {
    		return;
    	}
	if ( $DEBUG ) {
		open(STDERR, ">&STDOUT") || ($DEBUG=0);
	}
   	if ( $DEBUG==0 ) {
    		return;
    	}
    	select(STDERR); $| = 1;     # make unbuffered
  	select(STDOUT); $| = 1;     # make unbuffered
}

######################################################################
sub initPaths{
my $node=shift(@_);
# create the storage area
my  $SRPATH=$DRIVE."\\".$AUDITDIR;
 my $now_string = strftime "%Y%m%d_%H%M%S", localtime;

	if ( ! -d $SRPATH ) {
		mkdir $SRPATH ;
	}
	
	if ( ! -d   $SRPATH . "\\" .  $user ){
		mkdir $SRPATH . "\\" .  $user;
	}
	
	if ( ! -d   $SRPATH . "\\" .  $user ."\\" . $node ){
		mkdir $SRPATH . "\\" .  $user . "\\" . $node;
	}
	my $path= $SRPATH .  "\\" . $user . "\\" . $node . "\\" .  $now_string;
	if ( ! -d $path) {
		mkdir $path ;
	}
	
	
	if ( ! -d $path ) {
		my $string="Could Not Create audit log path ".$path . "\n Rautor is Exiting";
		mylog(500,"Error:"+$string);
		&getout;
	}
	return($path);
}



######################################################################
sub initFTPstuff {
	if ( ! (  defined($FTPSERVER) && defined($FTPUSER) && defined($FTPPASS) )) {
		mylog(100,"Info:No setup for the FTP uploader");
		return(0);
	}
	if (   (length($FTPSERVER)==0) || (length($FTPUSER)==0) || (defined($FTPPASS)==0) ) {
		mylog(100,"Info:No setup for the FTP uploader");
		return(0);
	}
	if ( ! defined($FTPQueue) ) {
		mylog(300,"Error:FTP queue init failed");
		return(0);
	} 
	my $ftp = Net::FTP->new($FTPSERVER, Debug => $DEBUG);
	if ( ! $ftp ) {
		mylog(300,"Errror:FTP init failed");
		return(0);
	}
       	if ( ! $ftp->login($FTPUSER,$FTPPASS) ) {
		mylog(300,"Error:FTP credentials Wrong");
		return(0);
	}  
	$ftp->quit();
	return(1);				
}


################################################################################
sub initEventLog {
#
# If using perlapp to compile
#    my $filename = PerlApp::extract_bound_file("msg.dll");
#    die "msg.dll not bound to application\n" unless defined $filename;
#
	my $filename="msg.dll";

	$MSGDLLPATH=$filename;
    if ($ENV{'PAR_TEMP'}) {
	    $MSGDLLPATH=$ENV{'PAR_TEMP'}. "\\" . $filename;
	} else {
	    $MSGDLLPATH= ".\\" . $filename;
	}

    my $welkey  =  $Registry->{ "LMachine/System/CurrentControlSet/Services/Eventlog/" };
    my $logkey  =  $welkey->{ "Application/" };
       $logkey->{ "$MYNAME/" }  =  {
                "/EventMessageFile"  => $MSGDLLPATH,
                "/TypesSupported"    => [ "0x00000007", "REG_DWORD" ],
            };
}


1;
