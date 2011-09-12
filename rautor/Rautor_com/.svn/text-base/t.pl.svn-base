my $gifname = "daemon.ico";
open(GIF, "<". $gifname)         or die "can't open $gifname: $!";

binmode(GIF);               # now DOS won't mangle binary input from G +IF
binmode(STDOUT);            # now DOS won't mangle binary output to ST +DOUT

my $packstring="c"x1024;
while (read(GIF, $buff,1024)) {
	    print pack($packstring, $buff);
	    print "\n";
    }

