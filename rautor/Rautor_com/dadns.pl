#!perl -w

#
# Script to unlock kidns.exe
# angelos@unix.gr
#
    
use common::sense;
use Win32::Process;
use Win32::TieRegistry ( Delimiter=>'/');
use Win32;
use Win32::IPConfig;
use File::Basename;

push @INC,".";
push @INC,dirname($0);
require "samtools.pm";

my $OpenDNSNameServers="208.67.222.222 208.67.220.220";
my $status=$Registry->{"LMachine/SOFTWARE/kidns.eu/STATUS"};
my $dhcpnameservers=$Registry->{"LMachine/SOFTWARE/kidns.eu/DHCPNAMESERVER"};
my $nameservers=$Registry->{"LMachine/SOFTWARE/kidns.eu/NAMESERVER"};
my $status=$Registry->{"LMachine/SOFTWARE/kidns.eu/STATUS"};
my $rkey=$Registry->{"LMachine/SYSTEM/CurrentControlSet/Services/Tcpip/Parameters/"};
my $NAMESERVERS;
my $DEBUG;	

Win32::MsgBox("Press OK to stop kinds.eu and unlock your system",0,"dadNS");

if (  defined($status) )  {	
	$Registry->{"LMachine/SOFTWARE/kidns.eu/"}={ 			
			"STATUS"	 		=> "STOP"
	};
} else {	# resort to file operations
	open (my $datafile,"<" . $ENV{APPDATA}."\\kidns.eu.nameservers");
	if ( $datafile ) {
		while(<$datafile>){
			chomp($_);
			my ($var,$val)=split(/\=/,$_);
			if ( $var eq "DHCPNAMESERVER"){
				$dhcpnameservers=$val;			
			}
			if ( $var eq "NAMESERVER"){
				$nameservers=$val;			
			}
		}
		close($datafile);	
		unlink $ENV{APPDATA}."\\kidns.eu.nameservers"; # force kidns to exit
	}
}

sleep(5);

my $pid=SamTools::Process::getpid("kidns.exe");	
if ( $pid > 0 ) {	
	Win32::MsgBox("kidns.exe is stuck\ndadns will now kill the process",0,"dadns");	
	SamTools::Process::kill("kidns.exe");	
}
			
	#global settings
if (defined($dhcpnameservers)) {			
		$rkey->{'DHCPNAMESERVER'}=$dhcpnameservers;
		$rkey->{'NAMESERVER'}="";		
		$NAMESERVERS=$dhcpnameservers;
}elsif (defined($nameservers)) {			
		$rkey->{'DHCPNAMESERVER'}="";
		$rkey->{'NAMESERVER'}=$nameservers;
		$NAMESERVERS=$nameservers;
} else {
		Win32::MsgBox("Could not find saved Name Server Data\n resorting to safe settings",0,"dadns");
		$rkey->{'NAMESERVER'}=$OpenDNSNameServers;
		$NAMESERVERS=$OpenDNSNameServers;
}
	
	Win32::MsgBox("dadns will now reset all your adapters' DNS servers",0,"dadns");
	
	# now do this for every adapter :-(	
	my $host;
    if (my $ipconfig = Win32::IPConfig->new($host)) {
		foreach my $adapter ($ipconfig->get_adapters) {									
			$adapter->set_dns(split(/\s/,$NAMESERVERS));
		}
	}		
	
	Win32::MsgBox("dadns will now stop any existing browsers",0,"dadns");
	
	for my $process ("firefox.exe","chrome.exe","opera.exe","iexplore.exe") {			
			SamTools::Process::kill($process);			
	}
		
	Win32::MsgBox("dadns will restart your system's DNS clients",0,"dadns");	
	print "Stopping Dns\n" if ( $DEBUG);
	restart($ENV{"windir"}. "\\system32\\net.exe",'net  stop "dns client"');
	
	print "Flushing Dns\n" if ( $DEBUG);
	restart($ENV{"windir"}. "\\system32\\ipconfig.exe",'ipconfig /flushdns');
	
	print "Starting Dns\n" if ( $DEBUG);
	restart($ENV{"windir"}. "\\system32\\net.exe",'net  start "dns client"'),
    
	
Win32::MsgBox("\n          Your System  is now Unlocked\n\nPlease delete dadns.exe from your hard drive",0,"dadNS");	 

#########################################################################################################
sub restart {
	my ( $exe,$cmd)=@_;
	my $ProcessObj;
	
		Win32::Process::Create($ProcessObj,
                             $exe,$cmd,0,                                                 
                             NORMAL_PRIORITY_CLASS|CREATE_NO_WINDOW,
                             ".");
	$ProcessObj->Wait(INFINITE);
}
	
	
1;