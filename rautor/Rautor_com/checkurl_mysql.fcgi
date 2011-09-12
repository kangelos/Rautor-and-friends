#!/usr/bin/perl -w

#use strict;
use File::Find ();
use CGI::Fast qw(:standard -nph);
$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads
use DBI();



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



# Traverse desired filesystems and read the expressions
File::Find::find({wanted => \&wanted}, '/opt/Rautor/ActiveLists'); 

# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"root","",
                         {'RaiseError' => 1}
			);

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
	$url =~ s/\/cgi-bin\/.*/\/cgi-bin\//gi;

	my @uelems=split(/\//,$url);
	# rebuild part of the urls;
	my $newurl="";
	my $found=0;
	my $iters=0;
	for (my $i=2;($i<=$#uelems)&&($i<5);$i++){ # 3 levels deep
		$iters++;
		$newurl .= $uelems[$i];
		my $sqlquery = sprintf("SELECT from blacklists where url='%s';",$newurl);
		my $sth = $dbh->prepare($sqlquery);
    		$sth->execute;
    		my $numRows = $sth->rows;
		if ( $numRows > 0 ){
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
    if  (  $filename eq "expressions" )  {
	open FIN ,"<$filename" || return;
	$category++;
	while(<FIN>){
		chomp($_);
		push @EXPRESSIONS,$_;
	}
	close (FIN);
    }
}


