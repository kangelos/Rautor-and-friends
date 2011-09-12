

use LWP::Simple;



my $DNS= get("http://www.unix.gr/kidns.txt");

if ( $DNS ) { 
	print $DNS;
} else { 
		print "nada\n";
	}
