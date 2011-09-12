#!C:\Perl510\bin\perl.exe -w

# S.Ox. /pci compliance for rdesktop users Angelos Karageorgiou angelos@unix.gr summer of 2009Mungle Rautor's registry settingsReleased under the GPLv2A comm

use strict;

#===vptk user code before tk===< THE CODE BELOW WILL RUN BEFORE TK STARTED >===
use Win32::TieRegistry ( Delimiter=>'/');
our $Registry;
use Win32::GUI();
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
our $TRIGGER=1;
our $LICENSE="";
our $KEYLOGGER=1;
our $SCREENDUMPER=1;
our $VERBOSE=0;
our $LEGALWARNING=0;
our $DEBUG=0;
our $FULLSCRAPE=0;
our $OPENDNS=0;
our $DIRECTSITES="127.0.0.1;<local>;*.unix.gr;*.googlesyndication.com";
our $PROXY=undef;
our $PROXYSERVER=undef;
our $PROXYPORT=undef;
our $PROXYLOCK=0;
our $TRAYICON=1;
our $WEBSERVER=0;
our $WEBPORT=2222;
our $UPLOADOLDFILES=0;

our $KEYPATH="LMachine/Software";
our $RAUTORPATH="LMachine/Software/$MYNAME";
our %reg;
require "Rreg.pl";
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

my $mw=MainWindow->new(-title=>'Rautor Settings');
#===vptk widgets definition===< DO NOT WRITE UNDER THIS LINE >===
use Tk::Balloon;
my $vptk_balloon=$mw->Balloon(-background=>"lightyellow",-initwait=>550);
use vars qw/$TRIGGER $WINNAMES $LICENSE $LEGALWARNING $TRAYICON $DRIVE $AUDITDIR $VERBOSE $DEBUG $WEBSERVER $WEBPORT $KEYLOGGER $SCREENDUMPER $SCREENSCRAPER $FULLSCRAPE $OPENDNS $PROXYLOCK $PROXYSERVER $PROXYPORT $KEEPFILES $UPLOADOLDFILES $FTPSERVER $FTPUSER $FTPPASS $SLEEP $QUANTUM/;

my $MSG = $mw -> Label ( -foreground=>'Maroon', -justify=>'left', -text=>'Rautor Operation', -font=>'$font' ) -> pack(-fill=>'x');
my $w_Pane_007 = $mw -> Pane ( -width=>310, -relief=>'raised' ) -> pack(-fill=>'x');
my $Activity = $mw -> LabFrame ( -label=>'Program Activation', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack();
my $Trigger = $Activity -> Checkbutton ( -highlightbackground=>'DarkOrange2', -activebackground=>'DarkOrange2', -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -width=>65, -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Turn Rautor\s Auditing features ON', -variable=>\$TRIGGER, -selectcolor=>'LightSkyBlue' ) -> pack();
my $Wnames = $Activity -> LabEntry ( -background=>'White', -label=>'Windows Names', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>50, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$WINNAMES ) -> pack(-anchor=>'e'); $vptk_balloon->attach($Wnames,-balloonmsg=>"Comma separated list of Application(windows) names that will trigger rautor.\nFor example Firefox,cmd.exe");
my $License = $Activity -> LabEntry ( -background=>'White', -label=>'License', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>50, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$LICENSE ) -> pack(-anchor=>'e');
my $Legalese = $w_Pane_007 -> LabFrame ( -label=>'Legalese', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $LegalW = $Legalese -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Display Legal Warning on Startup', -variable=>\$LEGALWARNING ) -> pack(-side=>'left'); $vptk_balloon->attach($LegalW,-balloonmsg=>"Display a warning that the session is being logged\nRautor will force a logoff if denied");
my $w_Checkbutton_039 = $Legalese -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Show Tray Icon', -variable=>\$TRAYICON ) -> pack(-anchor=>'e', -side=>'right');
my $Locations = $w_Pane_007 -> LabFrame ( -label=>'Location of Audit FIles', -width=>300, -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $w_Button_030 = $Locations -> Button ( -activebackground=>'DarkOrange2', -overrelief=>'raised', -command=>\&pickdir, -state=>'normal', -relief=>'raised', -text=>'Browse Folders', -compound=>'none' ) -> pack(-anchor=>'w', -side=>'left');
my $disk = $Locations -> LabEntry ( -background=>'White', -label=>'Destination', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>2, -state=>'readonly', -justify=>'left', -relief=>'sunken', -textvariable=>\$DRIVE ) -> pack(-anchor=>'s', -side=>'left');
my $AuditDIR = $Locations -> LabEntry ( -background=>'White', -label=>'\\', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>25, -state=>'disabled', -justify=>'left', -relief=>'sunken', -textvariable=>\$AUDITDIR ) -> pack(-anchor=>'s', -fill=>'x', -side=>'left');
my $Logging = $w_Pane_007 -> LabFrame ( -label=>'Logging', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Verbose = $Logging -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Verbose Session Logging', -variable=>\$VERBOSE ) -> pack(-anchor=>'nw', -side=>'left'); $vptk_balloon->attach($Verbose,-balloonmsg=>"Increases Verbosity");
my $Debug = $Logging -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Enable full Debugging', -variable=>\$DEBUG ) -> pack(-anchor=>'e'); $vptk_balloon->attach($Debug,-balloonmsg=>"Increases Verbosity further");
my $SubSystems = $w_Pane_007 -> LabFrame ( -label=>'Auditing Subsystems', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Web_server_frame = $w_Pane_007 -> LabFrame ( -label=>'Embedded Web Server', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Web_But = $Web_server_frame -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Enable WebServer', -variable=>\$WEBSERVER ) -> pack(-side=>'left');
my $Web_Port = $Web_server_frame -> LabEntry ( -background=>'White', -label=>'Listening Port', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>6, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$WEBPORT ) -> pack();
my $KeyLogger = $SubSystems -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Keyboard Logger', -variable=>\$KEYLOGGER ) -> pack(-anchor=>'center', -side=>'left'); $vptk_balloon->attach($KeyLogger,-balloonmsg=>"Enable the keylogger");
my $ScreenDumper = $SubSystems -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'right', -relief=>'flat', -offrelief=>'raised', -text=>'Screen Dumper', -variable=>\$SCREENDUMPER ) -> pack(-side=>'left'); $vptk_balloon->attach($ScreenDumper,-balloonmsg=>"Take screen shots");
my $ScreenScraper = $SubSystems -> Checkbutton ( -anchor=>'w', -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Screen Scraper', -variable=>\$SCREENSCRAPER ) -> pack(-anchor=>'w', -side=>'left'); $vptk_balloon->attach($ScreenScraper,-balloonmsg=>"Scrape screen for any text available\nContents can be used for searches from the viewer");
my $w_Checkbutton_031 = $SubSystems -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -offrelief=>'raised', -relief=>'flat', -text=>'Full Scrape', -variable=>\$FULLSCRAPE ) -> pack(-anchor=>'w'); $vptk_balloon->attach($w_Checkbutton_031,-balloonmsg=>"Scrape the contents of inactive windows also");
my $ProtectionSubs = $w_Pane_007 -> LabFrame ( -label=>'Child Protection Subsystems', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $use_Opendns = $ProtectionSubs -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Use Opendns.org? Requires account with opendns.com', -variable=>\$OPENDNS ) -> pack(-anchor=>'w'); $vptk_balloon->attach($use_Opendns,-balloonmsg=>"Forces use of opendns.org name servers\nMust have an account on opendns.org for finer control");
my $ProxyLock = $ProtectionSubs -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Enforce a Proxy Server for content filtering', -variable=>\$PROXYLOCK ) -> pack(-anchor=>'w');
my $Proxyserver = $ProtectionSubs -> LabEntry ( -background=>'White', -label=>'Proxy Server Name/IP', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>25, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$PROXYSERVER ) -> pack(-side=>'left');
my $ProxyPort = $ProtectionSubs -> LabEntry ( -background=>'White', -label=>'Port Number:', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>8, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$PROXYPORT ) -> pack(-anchor=>'w', -side=>'right');
my $FTPSettings = $w_Pane_007 -> LabFrame ( -label=>'FTP Upload Settings', -borderwidth=>2, -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $KeepFiles = $FTPSettings -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Keep a local copy of the files if FTP is active', -variable=>\$KEEPFILES ) -> pack(-anchor=>'w', -side=>'top'); $vptk_balloon->attach($KeepFiles,-balloonmsg=>"Or delete the local files after they have been uploaded");
my $Upl_old = $FTPSettings -> Checkbutton ( -overrelief=>'raised', -indicatoron=>1, -state=>'normal', -justify=>'left', -relief=>'flat', -offrelief=>'raised', -text=>'Find and Upload older Session FIles ?', -variable=>\$UPLOADOLDFILES ) -> pack(-anchor=>'w', -side=>'top');
my $ftpserver = $FTPSettings -> LabEntry ( -background=>'White', -label=>'FTP Server/ IP', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>40, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$FTPSERVER ) -> pack(-anchor=>'nw'); $vptk_balloon->attach($ftpserver,-balloonmsg=>"IP or FQDN of ftp server");
my $FTPUser = $FTPSettings -> LabEntry ( -background=>'White', -label=>'FTP Username', -labelPack=>[-side=>'left',-anchor=>'e'], -width=>15, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$FTPUSER ) -> pack(-anchor=>'s', -side=>'left'); $vptk_balloon->attach($FTPUser,-balloonmsg=>"Username for Ftp service");
my $FTPPassword = $FTPSettings -> LabEntry ( -background=>'White', -label=>'Password', -labelPack=>[-side=>'left',-anchor=>'n'], -width=>15, -state=>'normal', -justify=>'left', -relief=>'sunken', -textvariable=>\$FTPPASS ) -> pack(-anchor=>'s', -side=>'left'); $vptk_balloon->attach($FTPPassword,-balloonmsg=>"Passowrd for FTP service");
my $Times = $w_Pane_007 -> LabFrame ( -label=>'Timers', -width=>330, -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-fill=>'x');
my $Sleep = $Times -> Scale ( -label=>'Rauror Periodicity', -orient=>'horizontal', -state=>'normal', -showvalue=>1, -from=>1, -relief=>'flat', -to=>5, -variable=>\$SLEEP ) -> pack(-anchor=>'w', -side=>'left'); $vptk_balloon->attach($Sleep,-balloonmsg=>"How otten is a screenshot taken.");
my $Quantum = $Times -> Scale ( -bigincrement=>10, -label=>'Keylogger Trigger in msecs', -orient=>'horizontal', -state=>'normal', -showvalue=>1, -digits=>3, -from=>50, -relief=>'flat', -variable=>\$QUANTUM, -to=>500 ) -> pack(-fill=>'x'); $vptk_balloon->attach($Quantum,-balloonmsg=>"Keylogger  inter keypress timeout.\nAdjust to avoid duplicates");
my $OKPANEL = $mw -> Pane ( -background=>'gray80', -borderwidth=>2, -height=>50, -relief=>'flat', -gridded=>'x' ) -> pack(-fill=>'x');
my $OK = $OKPANEL -> Button ( -activebackground=>'DarkSeaGreen', -background=>'DarkSeaGreen', -overrelief=>'raised', -command=>\&SaveRegistry, -state=>'normal', -relief=>'raised', -text=>'Apply These Settings', -compound=>'none' ) -> pack(-side=>'left');
my $Quit = $OKPANEL -> Button ( -activebackground=>'Red', -overrelief=>'raised', -command=>\&quit, -state=>'normal', -relief=>'raised', -text=>'Quit', -compound=>'none' ) -> pack(-ipadx=>30, -side=>'right');

MainLoop;

#===vptk end===< DO NOT CODE ABOVE THIS LINE >===

######################################################################

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
			"/TRIGGER"		=> $TRIGGER,
			"/SLEEP"		=> $SLEEP,
			"/QUANTUM"		=> $QUANTUM,
			"/VERBOSE"		=> $VERBOSE,
			"/DEBUG"		=> $DEBUG,
			"/FTPSERVER"		=> $FTPSERVER,
			"/FTPUSER"		=> $FTPUSER,
			"/FTPPASS"		=> $FTPPASS,
			"/KEEPFILES"		=> $KEEPFILES,
			"/SCREENDUMPER"		=> $SCREENDUMPER,
			"/SCREENSCRAPER"	=> $SCREENSCRAPER,
			"/FULLSCRAPE"		=> $FULLSCRAPE,
			"/KEYLOGGER"		=> $KEYLOGGER,
			"/WINDOWSNAMES"		=> $WINNAMES,
			"/LEGALWARNING"		=> $LEGALWARNING,
			"/OPENDNS"		=> $OPENDNS,
			"/PROXYLOCK"		=> $PROXYLOCK,
			"/PROXY"		=> $PROXY,
			"/DIRECTSITES"		=> $DIRECTSITES,
			"/TRAYICON"		=> $TRAYICON,
			"/WEBSERVER"		=> $WEBSERVER,
			"/WEBPORT"		=> $WEBPORT,
			"/UPLOADOLDFILES"	=> $UPLOADOLDFILES,
		}
	   } || Win32::MsgBox("Cannot save settings", 48, "$MYNAME");

	   Win32::MsgBox("Settings Saved", 64, "$MYNAME");
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
