#!/usr/bin/perl -w

#use strict;
use File::Find ();
use CGI::Fast qw(:standard -nph);
$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads


my $VERBOSE=0;
our %BADURLS;
our @EXPRESSIONS;
my $category=0;

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;



# Traverse desired filesystems and fill in @badurls
# threads->create(sub { 
#	File::Find::find({wanted => \&wanted}, '/opt/Rautor/ActiveLists'); 
#	})->detach();
File::Find::find({wanted => \&wanted}, '/opt/Rautor/ActiveLists'); 

#@BADURLS=sort(@BADURLS);

print STDERR "$$ URL Checker Ready\n";
# Main Program
while (my $query=new CGI::Fast) {
	print header;

	my $user=$query->param('user');
	my $pass=$query->param('pass');
	if  ( ( ! $user ) || ( ! $pass) )  {
		print "RAUTOR:ERROR Unauthorized";
		next;
	}
	if (	( $user ne "angelos" ) || ( $pass ne "xarmosyno" ) ) {
		print "RAUTOR:ERROR Unauthorized";
		next;
	}

	my $url=$query->param('url');
	if ( ! $url) {
		print "RAUTOR:ERROR No url?";
		next;
	}
	# check the full url passed against all the expressions
	foreach $expression (@EXPRESSIONS) {
		if ( $url =~ m/$expression/i ) {
			if ( $VERBOSE ) { print STDERR "$$ Found $newurl in blacklist\n";  }
			print "RAUTOR:BLACKLISTURL $newurl from expression $expression\n";
			last;
		}
	}
	# get rid of passed data as get parameters
	$url =~ s/\?.*$//gi;

	my $newdomain=cleanupUrl($url);
#	$uelems[2]=$newdomain;	# put it back ! really ?

	# rebuild part of the urls;
	my $newurl="";
	my $found=0;
	my $iters=0;
	for (my $i=2;($i<=$#uelems)&&($i<5);$i++){ # 3 levels deep
		$iters++;
		$newurl .= $uelems[$i];
#		print STDERR "$$ -- " . $newurl. " --  " . $BADURLS{$newurl} ."\n" if ( $VERBOSE );
		if (defined($BADURLS{$newurl})) {#	for use with hash tables
#		my $loc= bsearch($newurl,@BADURLS);
#		if ( $loc >= 0 ) {
#			if ( $VERBOSE ) { print STDERR "$$ Found $newurl in blacklist pos:$loc\n";  }
			print "RAUTOR:BLACKLISTURL $newurl\n";
			$found++;
			last;
		}
		# check the expressions now
		$newurl .= "/";
	}
	# get rid of final slash if added
	$newurl =~ s/\/$//gi if ( $iters  > 0 );
	# nothing found
	print "RAUTOR:CLEAR $newurl" if ( $found == 0 ) ;
}

print  STDERR "$$ Exiting / why ? ";

1;

#**************************************************************************
sub wanted {
    return if ( /CATEGORIES/);
    $filename=$_;
    if ( ! -f $filename ){
	return;
    }
    if  ( ( $filename eq "domains" ) || ( $filename eq "urls" ) ) {
	print STDERR "$$ Reading: $name\n" if ( $VERBOSE);
	open FIN ,"<$filename" || return;
	$category++;
	while(<FIN>){
		chomp($_);
#		push @BADURLS, $_;
		$BADURLS{$_}=$category;
	}
	close (FIN);
   }
    if  (  $filename eq "expressions" )  {
#	print STDERR "$$ Reading: $name\n" if ( $VERBOSE);
	open FIN ,"<$filename" || return;
	$category++;
	while(<FIN>){
		chomp($_);
		push @EXPRESSIONS,$_;
	}
	close (FIN);
    }
}

#**************************************************************************
sub bsearch {
    my ($x, @a) = @_;         # search for x in array a
    my ($l, $u) = (0, $#a);   # lower, upper end of search interval
    my $i;                    # index of probe
    while ($l <= $u) {
	$i = int(($l + $u)/2);
	if ($a[$i] lt $x) {
	    $l = $i+1;
	}
	elsif ($a[$i] gt $x) {
	    $u = $i-1;
	} 
	else {
	    return $i; # found
	}
    }
    return -1;         # not found
}


sub cleanupUrl{
	my $url=shift @_;

	my @uelems=split(/\//,$url);
        my @domparts=split(/\./,$uelems[2]);
        my $newdomain="";# clean up the domain part
        if ( $#domparts > 1 ) {
                for (my $i=1;$i<=$#domparts;$i++){
                        $newdomain .= $domparts[$i] . ".";
                }
        } else {
                $newdomain=$uelems[2];
        }
        $newdomain =~ s/\.$//g;
        $newdomain =~ s/:[0-9]*$//g;
        $newdomain =~ s/\/$//g;
	return $newdomain;
}

