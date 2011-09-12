#!wperl.exe -w
#
# Rautor initialization stuff
# Released unde the GPLv2

use common::sense;

package Rautor;

use Win32::GUI();
use Win32::GUI::DIBitmap;
use Win32::TieRegistry ( Delimiter=>'/');
use POSIX qw(strftime);
use Net::FTPSSL;

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
our $NUMSCREENS;
our @DCs;
our @MONPATHS;



######################################################################
#sub initDebug{
#	my ( $path) =@_;
#	open(STDOUT, ">$path/DEBUG.TXT") || ($DEBUG=0);
#	return 	if ( $DEBUG==0 ) ;
#
#	open(STDERR, ">&STDOUT") || ($DEBUG=0);
#	return 	if ( $DEBUG==0 ) ;
#}

######################################################################
sub initPaths{
my ($node,$monitors)=@_;

# create the storage area(s)
my  $SRPATH=$DRIVE."\\".$AUDITDIR;
 my $now_string = strftime "%Y%m%d_%H%M%S", localtime;

	if ( ! -d $SRPATH ) {
		mkdir $SRPATH ;
	}
	
	if ( ! -d   $SRPATH . "\\" .  $user ){
		mkdir $SRPATH . "\\" .  $user;
	}
	
	my $path= $SRPATH .  "\\" . $user . "\\" .   $now_string . "_" . $node ;
	if ( ! -d $path) {
		mkdir "$path" ;
		$MONPATHS[1]=$path;
	}

	for ( my $j=2 ; $j<=$monitors; $j++) {
		my $monpath=  $SRPATH ."\\".  $user . "\\" .  $now_string .
							"_" . $node. " Monitor" .$j;
		if ( ! -d  $monpath ) {
			mkdir "$monpath";
			$MONPATHS[$j]=$monpath;
		}
	}
	
	if ( ! -d $path ) {
		return(undef);
	}
	return($path);
}



######################################################################
sub initFTPstuff {
	my ($FTPSERVER,$FTPUSER,$FTPPASS,$DEBUG)=@_;
	return(0) if ( ! defined($FTPSERVER) );
	if ( ! (  defined($FTPSERVER) && defined($FTPUSER) && defined($FTPPASS) )) {
		return undef;
	}
	if (   (length($FTPSERVER)==0) || (length($FTPUSER)==0) || (defined($FTPPASS)==0) ) {
		return undef;
	}
	
	my $ftp = Net::FTPSSL->new($FTPSERVER, Encryption => EXP_CRYPT, Timeout => 15,Debug => $DEBUG,use_SSL=>1, Port=>990);
	
	if ( ! $ftp ) {
		mylog(300,"Errror:FTP init failed");
		return undef;
	}
   	if ( ! $ftp->login($FTPUSER,$FTPPASS) ) {
		mylog(300,"Error:FTP credentials Wrong");
		return undef;
	}  
	$ftp->quit();
	return(1);				
}


################################################################################
sub init_DCs {
	my $NUMSCREENS=Count_Monitors();

	if ( $NUMSCREENS < 1) {
		&mylog(200,"Warning:No Monitors Detected, switching to singleton mode");
		$NUMSCREENS=1;
	}
	
	for (my $i=1;$i<=$NUMSCREENS;$i++){
		my $dispname="\\\\.\\Display".$i;
		$DCs[$i]=new Win32::GUI::DC("DISPLAY",$dispname);
	}
	return $NUMSCREENS;
}


################################################################################
sub Count_Monitors {
# calculate the number of screens
my $NumScreens=0;
for (my $i=0;$i<100;$i++){
	my $dispname="\\\\.\\Display".$i;
	my $Screen=new Win32::GUI::DC("DISPLAY",$dispname);
	if ( $Screen ) {
		my $image = newFromDC Win32::GUI::DIBitmap($Screen) ;
 		if ( $image ) {
			$NumScreens++;
			undef($image);
		}
		Win32::GUI::DC::ReleaseDC(0,$Screen);
	}
}
return $NumScreens;
}


################################################################################
sub initEventLog {
	my $filename=shift;
	
	my $MSGDLLPATH=getfulliconpath($filename);    	
	my $welkey  =  $Registry->{ "LMachine/System/CurrentControlSet/Services/Eventlog/" };
	my $logkey  =  $welkey->{ "Application/" };
       		$logkey->{ "$MYNAME/" }  =  {
                	"/EventMessageFile"  => $MSGDLLPATH,
                	"/TypesSupported"    => [ "0x00000007", "REG_DWORD" ],
            		};
	undef($logkey);
}

1;
