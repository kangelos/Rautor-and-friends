#!perl.exe -w

package Rautor;
use common::sense;
use Win32::TieRegistry ( Delimiter=>'/');
use File::Copy;
push @INC,'.';
require "rot13.pl";

my $VERBOSE=1;


sub strip{
    #usage: $str=strip($str);
    #info: strips off beginning and endings returns, newlines, tabs, and spaces
    my $str=shift;
    return if ( ! $str);
    if(length($str)==0) { return ; }

    $str=~s/^[\r\n\s\t]+//s;
    $str=~s/[\r\n\s\t]+$//s;

    return $str;
}


sub setProxy{
    my ($PROXY,$enable,$DIRECTSITES)=@_;
    #Set access to use proxy server (IE)
    #http://nscsysop.hypermart.net/setproxy.html
   
    my ( $server,$port)=split(/:/,$PROXY);

    if (
	    ( ! defined($server) ) || ( ! defined($port) ) 
    ) {
	    	print STDERR "No Proxy settings ? \n";
	    	return;
    }
    my $override="";
    if (! $DIRECTSITES  ) {
	    print STDERR "No Direct Sites ? \n" if ( $VERBOSE );
	    $override="127.0.0.1;<local>";
    } else {
    	$override=$DIRECTSITES;
    }


    setIE($server,$port,$enable,$override);
    setmozilla($server,$port,$enable,$override);
	LockMozilla();
    setopera($server,$port,$enable,$override);
}
1;

#
## ***********************************
#
sub setIE {
	my ($server,$port,$enable,$override)=@_;

	my $rkey=$Registry->{"CUser/Software/Microsoft/Windows/CurrentVersion/Internet Settings"};
	$rkey->SetValue( "ProxyServer"   , "$server\:$port"  , "REG_SZ"    );
	$rkey->SetValue( "ProxyEnable"   , pack("L",$enable) , "REG_DWORD" );
	$rkey->SetValue( "ProxyOverride" , $override         , "REG_SZ"  );
	undef($rkey);
}

#
## ***********************************
#
sub setopera{
	my ($server,$port,$enable,$override)=@_;
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

	#Change operaprefs.ini file
	# this modification is mine
	if(! -d "$ENV{APPDATA}\\Opera\\Opera"){
	    return;
    	}
	my @lines=();
	$override=~s/;/,/g;
            
	# delete settings if exist
        if(! open(FH,"$ENV{APPDATA}\\Opera\\Opera\\operaprefs.ini")){ 
		return -1;
	}
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
        if(!open(FH,">$ENV{APPDATA}\\Opera\\Opera\\operaprefs.ini")){
		  return(-1);
		}
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
      close(FH);                        
      return(1);
}


#
## ***********************************
##Change prefs.js file for mozilla
#http://www.mozilla.org/support/firefox/edit
sub setmozilla{
 my ($server,$port,$enable,$override)=@_;

 my %Prefs=(	"network\.proxy\.http" => "\"$server\"",
             	"network\.proxy\.http_port" => $port,
             	"network\.proxy\.type" => 1,
				"network.proxy.no_proxies_on" => "\"$override\"",
				"network.proxy.share_proxy_settings"=>'true',             );

 my @userchromeLines=(	"\@namespace url(\"http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul\");",
			"#tools-menu { display: none !important; }"		);

         
 	
    if(! -d "$ENV{APPDATA}\\Mozilla\\Firefox\\Profiles"){	# mozilla not installed ?
		print "Mozzila not installed ? \n" if ( $VERBOSE);
	    return;
    }

    my $mozdir="$ENV{APPDATA}\\Mozilla\\Firefox\\Profiles";
    opendir(DIR,$mozdir) || return;
     my @pdirs=grep(/\w/,readdir(DIR));
     close(DIR);

     foreach my $pdir (@pdirs){
         next if !-d "$mozdir\\$pdir";
         next if $pdir !~/\.default$/is;
         my @lines=();
         print " =======> $mozdir\\$pdir\\prefs.js" . "\n" if ( $VERBOSE);
         if(!open(FH,"$mozdir\\$pdir\\prefs.js")){
		 return(-1);
	 }
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
	  # apply new settings
         if(!open(FH,">$mozdir\\$pdir\\prefs.js")){
		return -1;
	}
        binmode(FH);
        foreach my $line (@lines){
         	$line=strip($line);
           	print FH "$line\r\n";
         }
         foreach my $key (sort(keys(%Prefs))){
             	print FH qq|user_pref("$key",$Prefs{$key});\r\n|;
	}
        close(FH);
	# now remove the tools menu altogether !!
	if ( ! -d "$mozdir\\$pdir\\chrome" ) {
		mkdir("$mozdir\\$pdir\\chrome");
	}
	if (	( -f "$mozdir\\$pdir\\chrome\\userChrome.css" ) &&
		(! -f "$mozdir\\$pdir\\chrome\\userChrome.css.rautor" ) ){
		copy("$mozdir\\$pdir\\chrome\\userChrome.css","$mozdir\\$pdir\\chrome\\userChrome.css.rautor");
	}

	if (open(CHROME,">$mozdir\\$pdir\\chrome\\userChrome.css")){
		binmode(CHROME);
		foreach my $line (@userchromeLines) {
			print CHROME $line . "\r\n";
		}
		close(CHROME);
	}
      }
return(1);
}


#
## ***********************************
#
sub LockMozilla{
my @allgreprefs;
my %MozDirs;
my @ALLlines;
my @torotlines=("//","lockPref(\"network.proxy.type\", 1);");
my $rot13 = new Crypt::Rot13;
 
 
	#Find all installed instances of firefox
    my $Progdir="$ENV{ProgramFiles}";
    opendir(DIR,$Progdir) || return;
     my @pdirs=grep(/\w/,readdir(DIR));
     close(DIR);
	 foreach my $dir (@pdirs) {
		next if ( $dir !~ /Firefox/gi);		
		push @allgreprefs,$Progdir."\\".$dir."\\greprefs";
			$MozDirs{$Progdir."\\".$dir."\\greprefs"}=$Progdir."\\".$dir;
	 }
	 
	 # which ones have the all.js fine in them ?
	 foreach my $dir (@allgreprefs){
		next  if (! -f  $dir ."\\"."all.js") ;
		# got it	
		print $dir . "\n" . $MozDirs{$dir} ."\n" if ( $VERBOSE);
		if ( open(ALL,"<$dir\\local-settings.js") ){
			while(<ALL>){		
				next if ( /general\.config\.filename.*mozilla\.cfg/gi ); # unlock !!
				push @ALLlines,$_;
			}
			close(ALL);
		}
		
		# relock
		open(ALL,">$dir\\local-settings.js") || return(-1);
		binmode(ALL);
		foreach my $line (@ALLlines){
			$line=strip($line);
			print ALL "$line\r\n";			
		}
		print ALL 'pref("general.config.filename", "mozilla.cfg");' ."\r\n";
		close(ALL);
		 
		# Ok we got all.js fixed up . now create the mozilla.cfg file one dir up
		open(CFG,">$MozDirs{$dir}\\mozilla.cfg") || return ( -1);
		binmode(CFG);
		foreach my $rotline ( @torotlines) {
			$rot13->charge($rotline);
			print CFG $rot13->rot13();
			print CFG "\r\n";			
		}
		close(CFG);
	}		 
}


#setmozilla('proxy.vivodinet.gr',9000,1,"*.unix.gr;127.0.0.1");

1;
