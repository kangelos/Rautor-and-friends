#!C:\Perl510\bin\perl.exe -w

# S.Ox. /pci compliance for rdesktop users Angelos Karageorgiou angelos@unix.gr summer of 2009Mungle Rautor's registry settingsReleased under the GPLv2A comm

use strict;

#===vptk user code before tk===< THE CODE BELOW WILL RUN BEFORE TK STARTED >===
use Win32::TieRegistry ( Delimiter=>'/');
our $Registry;
package Rautor;


BEGIN {
# Uncomment the following two liner if running form source
# my ($DOS) = Win32::GUI::GetPerlWindow();
#    Win32::GUI::Hide($DOS);
}


our $MYNAME="Rautor";
our $AUTHOR="Angelos Karageorgiou http://www.unix.gr";
our $DRIVE="C:";
our $AUDITDIR="Audit"; 	
our $FTPSERVER=undef;
our $FTPUSER=undef;
our $FTPPASS=undef;
our $KEEPFILES=1;
our $SCREENSCRAPER=1;
our $DEFSLEEP=3;		#seconds
our $SLEEP=$DEFSLEEP; 		
our $DEFQUAN=130;	#milisecs that sleep time is broken into quanta :-)
our $QUANTUM=$DEFQUAN; 
our @WINDOWSNAMES;
our $LICENSE="";
our $KEYLOGGER=1;
our $SCREENDUMPER=1;
our $VERBOSE=0;
our $LEGALWARNING=0;
our $DEBUG=0;
our $FULLSCRAPE=0;
our $DIRECTSITES="127.0.0.1;<local>;*.unix.gr;*.googlesyndication.com";
our $PROXY=undef;
our $PROXYSERVER=undef;
our $PROXYPORT=undef;
our $PROXYLOCK=0;
our $TRAYICON=1;
our $WEBSERVER=0;
our $REGSERVER="rautor";
our $UPLOADOLDFILES=0;
our $SLIDESBITS=16;

our $KEYPATH="LMachine/Software";
our $RAUTORPATH="LMachine/Software/$MYNAME";
our %reg;
push @INC ,"..\\common";
require "rreg.pl";
&doRegistry();

our $WINNAMES=join(',',@WINDOWSNAMES);
use Tk;
use Tk::Button;
use Tk::Checkbutton;
use Tk::LabEntry;
use Tk::LabFrame;
use Tk::Label;
use Tk::Pane;
use Tk::Scale;
use Tk::Balloon;
use Crypt::Tea;

my $KEY='perl -e "{print \$key}"';
my $RAUTORPASS='$RAUTORPASS';

my $mw=MainWindow->new(-title=>'Rautor Settings' , -width => "300" , -height=>'500' );
my $vptk_balloon=$mw->Balloon(-background=>"cyan",-initwait=>550);
use vars qw/$WINNAMES $LICENSE $LEGALWARNING $TRAYICON $DRIVE $AUDITDIR $VERBOSE $DEBUG $WEBSERVER $REGSERVER $KEYLOGGER $SCREENDUMPER $SCREENSCRAPER $FULLSCRAPE $PROXYLOCK $PROXYSERVER $PROXYPORT $KEEPFILES $UPLOADOLDFILES $FTPSERVER $FTPUSER $FTPPASS $SLEEP $QUANTUM $DIRECTSITES $SLIDESBITS/;
#my $Master_Pane = $mw ->Pane( -sticky => 'nswe', -gridded => 'xy',  -relief=>'raised', -borderwidth=> 1 ) -> pack(-expand  => 1, -fill => 'both' );
my $Master_Pane = $mw ->Scrolled('Pane',  -width => 500,
                      -height => 600,
	                     -scrollbars => 'osoe',
	                      -sticky => 'nswe',
	 		      -gridded => 'xy',  -relief=>'flat', -borderwidth=> 0 ) -> pack(-expand  => 1, -fill => 'both' );




my $SubSystems = $Master_Pane -> LabFrame (  -font => 'Bold', -label=>'Subsystems', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $KeyLogger = $SubSystems -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Keyboard Logger', -variable=>\$KEYLOGGER ) -> pack(-anchor=>'center', -side=>'left'); $vptk_balloon->attach($KeyLogger,-balloonmsg=>"Enable the keylogger");
my $ScreenDumper = $SubSystems -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'right', -relief=>'flat', -offrelief=>'raised', -text=>'Screen Dumper', -variable=>\$SCREENDUMPER ) -> pack(-side=>'left'); $vptk_balloon->attach($ScreenDumper,-balloonmsg=>"Take screen shots");
my $ScreenScraper = $SubSystems -> Checkbutton ( -anchor=>'w', -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Screen Scraper', -variable=>\$SCREENSCRAPER ) -> pack(-anchor=>'w', -side=>'left'); $vptk_balloon->attach($ScreenScraper,-balloonmsg=>"Scrape screen for any text available\nContents can be used for searches from the viewer");
my $ScrapeAll = $SubSystems -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Scrape Invisibles', -variable=>\$FULLSCRAPE ) -> pack(-anchor=>'w'); $vptk_balloon->attach($ScrapeAll,-balloonmsg=>"ALso Scrape the contents of windows that are hidden or inactive");

#my $Legalese = $Master_Pane -> LabFrame ( -font => "bold" ,  -label=>'User Interaction', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
#my $LegalW = $Legalese -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Display Legal Warning and Force Logoff if denied', -variable=>\$LEGALWARNING ) -> pack(-side=>'left'); $vptk_balloon->attach($LegalW,-balloonmsg=>"Display a warning that the session is being logged\nRautor will force a logoff if denied");
#my $w_Checkbutton_039 = $Legalese -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Show Tray Icon', -variable=>\$TRAYICON ) -> pack(-anchor=>'e', -side=>'right');

my $Locations = $Master_Pane -> LabFrame ( -font => 'Bold',  -label=>'Audit Files & Slides', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $disk = $Locations -> LabEntry ( -background=>'White', -label=>'Destination', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>2, -state=>'readonly', -justify=>'left', -relief=>'sunken', -textvariable=>\$DRIVE ) -> pack(-anchor=>'s', -side=>'left');
my $AuditDIR = $Locations -> LabEntry ( -background=>'White', -label=>'\\', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>30, -state=>'disabled', -justify=>'left', -relief=>'sunken', -textvariable=>\$AUDITDIR ) -> pack(-anchor=>'s', -fill=>'x', -side=>'left');
my $w_Button_030 = $Locations -> Button ( -activebackground=>'DarkOrange2', -overrelief=>'raised', -command=>\&pickdir, -state=>'normal', -relief=>'raised', -text=>'Browse Folders', -compound=>'none' ) -> pack(-anchor=>'w', -side=>'left');
my $tlabel=$Locations->Label(-text => "Image bits: ")->pack(-side => 'left');

my $bitsmenu = $Locations -> Optionmenu (  -variable=>\$SLIDESBITS ,-options=> [8,16],
 -state=>'normal', -relief=>'raised', -text=>'Slide Quality', -compound=>'none' ) -> pack(-anchor=>'w');

my $Activity = $Master_Pane -> LabFrame ( -font => "bold", -label=>'Activation Settings', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Wnames = $Activity -> LabEntry ( -background=>'white', -label=>'Windows Names', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>50, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$WINNAMES ) -> pack(-anchor=>'w',-fill=>'x'); $vptk_balloon->attach($Wnames,-balloonmsg=>"Comma separated list of Application(windows) names that will trigger rautor.\nFor example Firefox,cmd.exe\nLeave empty for always active");
#my $License = $Activity -> LabEntry ( -background=>'white', -label=>'Program License', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>50, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$LICENSE ) -> pack(-anchor=>'w',-fill=>'x');
my $Logging = $Master_Pane -> LabFrame (  -font => 'Bold', -label=>'Logging', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Verbose = $Logging -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Verbose Session Logging', -variable=>\$VERBOSE ) -> pack(-anchor=>'nw', -side=>'left'); $vptk_balloon->attach($Verbose,-balloonmsg=>"Increases Verbosity");
my $Debug = $Logging -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Enable full Debugging', -variable=>\$DEBUG ) -> pack(-anchor=>'e'); $vptk_balloon->attach($Debug,-balloonmsg=>"Increases Verbosity further");

my $Times = $Master_Pane -> LabFrame (  -font => 'Bold', -label=>'Operational Timers',  -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Sleep = $Times -> Scale ( -label=>'Rauror Periodicity', -orient=>'horizontal', -state=>'normal', -showvalue=>1, -from=>1, -relief=>'flat', -to=>5, -variable=>\$SLEEP ) -> pack(-anchor=>'w', -side=>'left'); $vptk_balloon->attach($Sleep,-balloonmsg=>"How otten is a screenshot taken.");
my $Quantum = $Times -> Scale ( -bigincrement=>10, -label=>'Keylogger Trigger in msecs', -orient=>'horizontal', -state=>'normal', -showvalue=>1, -digits=>3, -from=>50, -relief=>'flat', -variable=>\$QUANTUM, -to=>500 ) -> pack(-fill=>'x'); $vptk_balloon->attach($Quantum,-balloonmsg=>"Keylogger  inter keypress timeout.\nAdjust to avoid duplicates");

my $Web_server_frame = $Master_Pane -> LabFrame ( -font => 'Bold',-label=>'Licensing', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
#my $jLable = $Web_server_frame -> Label (  -justify=>'left', -text=>"Start Monitoring Web Server") ->  pack(-anchor=>'w' ,-side=>'left');
#my $Web_But = $Web_server_frame -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -text=>"", -relief=>'flat', -offrelief=>'raised',  -variable=>\$WEBSERVER) ->  pack(-anchor=>'w' ,-side=>'left');
my $URL_ent = $Web_server_frame -> LabEntry ( -background=>'White', -label=>'Registration Server:', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>30, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$REGSERVER ) -> pack(-anchor=>'w' ,-side=>'left');
$vptk_balloon->attach($URL_ent,-balloonmsg=>"The registration server\'s IP or name ");


my $ProtectionSubs = $Master_Pane -> LabFrame ( -font=>"Bold",-label=>'Proxy Enforcing', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $ProxyLock = $ProtectionSubs -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Enforce a Proxy Server for content filtering', -variable=>\$PROXYLOCK ) -> pack(-anchor=>'w');
my $Proxyserver = $ProtectionSubs -> LabEntry ( -background=>'White', -label=>'Proxy Server:', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>25, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$PROXYSERVER ) -> pack(-anchor=>'w');
$vptk_balloon->attach($Proxyserver,-balloonmsg=>"The Fully Qualified domain name of the proxy Server\nOr its IP address");
my $ProxyPort = $ProtectionSubs -> LabEntry ( 
	-background=>'White', -label=>'Port Number:', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>8, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$PROXYPORT
) -> pack(-anchor=>'w');
$vptk_balloon->attach($ProxyPort,-balloonmsg=>"The port the proxy server is listening at");
my $Dirsites = $ProtectionSubs -> LabEntry (
	-background=>'White', -label=>'  Direct Sites:', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>50, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$DIRECTSITES )
-> pack(-anchor=>'w' , -fill=>'x');
$vptk_balloon->attach($Dirsites,-balloonmsg=>"Semicolon separated list of web sites that are NOT accessible via the proxy server");
my $FTPSettings = $Master_Pane -> LabFrame (  -font => 'Bold', -label=>'SSL FTP Upload Settings', -borderwidth=>2, -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $KeepFiles = $FTPSettings -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Keep a local copy of the files if FTP is active', -variable=>\$KEEPFILES ) -> pack(-anchor=>'w', -side=>'top'); $vptk_balloon->attach($KeepFiles,-balloonmsg=>"Or delete the local files after they have been uploaded");
#my $Upl_old = $FTPSettings -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Find and Upload older Session FIles ?', -variable=>\$UPLOADOLDFILES ) -> pack(-anchor=>'w', -side=>'top');
my $ftpserver = $FTPSettings -> LabEntry ( -background=>'White', -label=>'FTP Server/ IP', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>40, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$FTPSERVER ) -> pack(-anchor=>'nw'); $vptk_balloon->attach($ftpserver,-balloonmsg=>"IP or FQDN of ftp server\nSet it to enable uploading of files");
my $FTPUser = $FTPSettings -> LabEntry ( -background=>'White', -label=>'FTP Username', -labelPack=>[-side=>'left',-anchor=>'e'], -width=>15, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$FTPUSER ) -> pack(-anchor=>'s', -side=>'left'); $vptk_balloon->attach($FTPUser,-balloonmsg=>"Username for Ftp service");
my $FTPPassword = $FTPSettings -> LabEntry ( -background=>'White', -label=>'Password', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>15, -state=>'normal', -justify=>'left', -show=>'*', -relief=>'sunken', -textvariable=>\$FTPPASS ) -> pack(-anchor=>'s', -side=>'left'); $vptk_balloon->attach($FTPPassword,-balloonmsg=>"Passowrd for FTP service");


my $OKPANEL = $Master_Pane -> Pane (  -borderwidth=>1, -sticky=>'s',  -relief=>'ridge', -gridded=>'x',-background=>'white' ) -> pack(-fill=>'both');

my $OK = $OKPANEL -> Button ( -activebackground=>'DarkSeaGreen', -background=>'DarkSeaGreen', -overrelief=>'raised', -command=>\&SaveRegistry, -state=>'normal', -relief=>'raised', -text=>'   Apply These Settings   '. ' ' x 10, -compound=>'none'  ) -> pack(-fill=>'both');

MainLoop;

#===vptk end===< DO NOT CODE ABOVE THIS LINE >===

######################################################################
# do registry is creation specific
sub SaveRegistry{
	if ( defined($PROXYSERVER) && defined ($PROXYPORT) ){
		$PROXY=$PROXYSERVER.":".$PROXYPORT;
	} else {
		$PROXY="";
		$PROXYLOCK=0;
	}
	$Registry->{"$KEYPATH/"}={
		$MYNAME => {
			"/LICENSE"		=> "",
			"/DRIVE"		=> $DRIVE,
			"/AUDITDIR"		=> $AUDITDIR,
			"/SLEEP"		=> $SLEEP,
			"/QUANTUM"		=> $QUANTUM,
			"/VERBOSE"		=> $VERBOSE,
			"/DEBUG"		=> $DEBUG,
			"/FTPSERVER"		=> $FTPSERVER,
			"/FTPUSER"		=> $FTPUSER,
			"/FTPPASS"		=> encrypt($FTPPASS,$KEY),
			"/KEEPFILES"		=> $KEEPFILES,
			"/SCREENDUMPER"		=> $SCREENDUMPER,
			"/SCREENSCRAPER"	=> $SCREENSCRAPER,
			"/FULLSCRAPE"		=> $FULLSCRAPE,
			"/KEYLOGGER"		=> $KEYLOGGER,
			"/WINDOWSNAMES"		=> $WINNAMES,
			"/LEGALWARNING"		=> $LEGALWARNING,
			"/PROXYLOCK"		=> $PROXYLOCK,
			"/PROXY"		=> $PROXY,
			"/DIRECTSITES"		=> $DIRECTSITES,
			"/TRAYICON"		=> $TRAYICON,
			"/WEBSERVER"		=> $WEBSERVER,
			"/REGSERVER"		=> $REGSERVER,
			"/UPLOADOLDFILES"	=> $UPLOADOLDFILES,
			"/SLIDESBITS"		=> $SLIDESBITS,
		}
	   } || $mw->messageBox(-message=>"Could not save Settings   ", -title=>"Rautor",-type => "ok",-icon=>'error');
	   
	   $mw->messageBox(-message=>"Settings Saved       ", -title=>"Rautor" , -type => "ok",-icon=>'info');	  

}


sub quit{
	exit 1;
}

sub pickdir {
 	my $dir = $mw->chooseDirectory;
	if ($dir) {
		($DRIVE,$AUDITDIR)=split(':',$dir);
		$DRIVE=$DRIVE. ":";
		$AUDITDIR =~ s:^\\::;
		$AUDITDIR =~ s:^/::;
	}
}
