#!C:\Perl510\bin\perl.exe -w

# Machine Signature

use strict;
use warnings;

#===vptk user code before tk===< THE CODE BELOW WILL RUN BEFORE TK STARTED >===

use Tk;
use Tk::Button;
use Tk::Entry;
use Tk::Message;
use Tk::Pane;
use Win32::OLE qw (in);
use Win32;
use Win32::GUI::SplashScreen;


BEGIN {
# Uncomment the following two liner if running form source
# my ($DOS) = Win32::GUI::GetPerlWindow();
#    Win32::GUI::Hide($DOS);

my $SPLASHFILE="SPLASH.bmp";
        if ($ENV{'PAR_TEMP'}) {
                $SPLASHFILE=$ENV{'PAR_TEMP'}. "\\inc\\" . $SPLASHFILE;

        }
        Win32::GUI::SplashScreen::Show(
                -file => $SPLASHFILE,
                -info => "The Rautor Auditing System",
                -copyright => "(c) 2009 Angelos Karageorgiou" ,
        );
}


my $SN=serialnum(Win32::NodeName(),'Win32_BaseBoard');
if ( ! defined $SN ) {
	$SN="..!FQ135TX..";
}
if ( $SN eq " " ) {
	$SN="..!FQ135TX..";
}

my $CSN=$SN;
$CSN=~ s/[0-9]/X/gi;
$CSN=~ s/[^A-Z]/Q/gi;

my $user=Win32::LoginName();
my $system=Win32::NodeName();
my $machine=Win32::NodeName();
my $session=$ENV{'SESSIONNAME'};
my $thread=Win32::GetCurrentThreadId();
my $uniq=Win32::GuidGen();
my $domain = " " x 1024;
my $sid = " " x 1024;
my $sidtype = " " x 1024;
Win32::LookupAccountName($system, $user, $domain, $sid, $sidtype);


my $SALT="$domain,$machine,$SN";


sub serialnum{
  my $Computername = $_[0];
  my $Win32_Class = $_[1];
  my $Class = "WinMgmts://$Computername";
  my $Wmi = Win32::OLE->GetObject ($Class);
  if ($Wmi) {
    my $Computers = $Wmi->ExecQuery("SELECT * FROM $Win32_Class");
    if (scalar(in($Computers)) lt "1") {
      return undef;
    }

    my $sn=undef;
    foreach my $node (in ($Computers)) {
  	foreach my $object (in $node->{Properties_}) {
	  	if ($object->{Name} =~ 'SerialNumber' ){
			$sn=$object->{Value};
		}
    }
	if ( defined ($sn) ) { return $sn;}
    }
  } else {
	  return undef;
  }
}


my $mw=MainWindow->new(-title=>'Your PC');
#===vptk widgets definition===< DO NOT WRITE UNDER THIS LINE >===
use Tk::Balloon;
my $vptk_balloon=$mw->Balloon(-background=>"lightyellow",-initwait=>550);
use vars qw/$SALT/;

my $w_Pane_004 = $mw -> Pane ( -background=>'LightSkyBlue', -width=>400, -relief=>'raised' ) -> pack(-fill=>'x', -side=>'top');
my $What = $w_Pane_004 -> Message ( -background=>'LightSkyBlue', -foreground=>'black', -width=>300, -borderwidth=>4, -justify=>'center', -relief=>'flat', -text=>'Please Copy and Email us this ID.   We will sign it and send you back your official  yearly Rautor License', -font => 'Arial,14', -aspect=>3 ) -> pack(-fill=>'x', -side=>'top');
my $Salt = $w_Pane_004 -> Entry ( -selectforeground=>'White', -validate=>'none', -width=>60, -state=>'readonly', -takefocus=>1, -justify=>'left', -relief=>'sunken', -textvariable=>\$SALT ) -> pack(-anchor=>'n', -side=>'top');
my $Dismiss = $w_Pane_004 -> Button ( -activebackground=>'DarkOrange2', -overrelief=>'raised', -command=>\&quit, -state=>'normal', -borderwidth=>4, -relief=>'raised', -text=>'Dismiss', -compound=>'none' ) -> pack(-anchor=>'n', -side=>'top', -expand=>1);

MainLoop;

#===vptk end===< DO NOT CODE ABOVE THIS LINE >===
sub quit {
	exit 1;
}
1;
