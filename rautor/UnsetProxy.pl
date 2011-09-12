#!/bin/perl.exe -w
#
# Undo Rautor's proxy stuff !
# Angelos Karageorgiou


use common::sense;

use Win32::TieRegistry ( Delimiter=>'/');



&UnsetProxy();


sub UnsetProxy{
    #Set access to use proxy server (IE)
    #http://nscsysop.hypermart.net/setproxy.html
   
    my $enable=0; 
    #unset IE Proxy
    my $server="No such";
    my $port="No Such";
    my $override="127.0.0.1";

    my $rkey=$Registry->{"CUser/Software/Microsoft/Windows/CurrentVersion/Internet Settings"};
    $rkey->SetValue( "ProxyEnable"   , pack("L",$enable) , "REG_DWORD" );


######################################################################
# this code I stole from ssloyd from perlmonks to force the browser's proxy
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
		   #	Write out the rest of the stuff
            if(open(FH,">$mozdir\\$pdir\\prefs.js")){
            	binmode(FH);
            	foreach my $line (@lines){
                	$line=strip($line);
                   	print FH "$line\r\n";
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

	    # rewrite the file
            if(open(FH,">$ENV{APPDATA}\\Opera\\Opera\\operaprefs.ini")){
              binmode(FH);
              foreach my $line (@lines){
                $line=strip($line);
                   print FH "$line\r\n";
                }
            	close(FH);
    	    }
      }
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

