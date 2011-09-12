
$domain="secure.penthouse.com";

print STDERR "UELEMS $domain\n";
        $domain=~s/^(.*)?\.//; # throw away the domains first part
#        $domain=~s/^www\.//; # throw away the www part
print STDERR "UELEMS $domain\n";


$domain="secure.penthouse.com";
 @domparts=split(/\./,$domain);

print $#domparts;

        our $newdomain="";                      # clean up the domain part
        for (my $i=1;$i<=$#domparts;$i++){

print "$i $newdomain\n";
                $newdomain .= $domparts[$i] . ".";
        }
        $newdomain =~ s/\.$//g;


print $newdomain;


print "\\n\n\n\n\n\n";
$url="http://secure.penthouse.com";
@uelems=split("/",$url);
@domparts=split(/\./,$uelems[2]);

        our $newdomain="";# clean up the domain part
        for (my $i=1;$i<=$#domparts;$i++){
                $newdomain .= $domparts[$i] . ".";
        }
        $newdomain =~ s/\.$//g;

print STDERR "New domain $newdomain\n";

