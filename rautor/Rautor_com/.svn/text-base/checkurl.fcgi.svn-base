#!/usr/bin/perl 


package checkurl;

use strict;
use warnings;

use DBI();
use File::Find ();
use CGI::Fast qw(:standard);
use Net::DNS;
use Data::Dumper;
use Memoize;
use Crypt::Tea;
use IPC::Cache;
sub wanted;

my $CACHE_KEY = "URLC";
my $NAMESPACE = "Rautor";

# Test creation of a cache object

my $test = 2;

my $CACHE = new IPC::Cache( { cache_key => $CACHE_KEY,
				 expires_in => 900, 
			       namespace => $NAMESPACE } );
$CACHE->clear() if ( $CACHE);

my $VERBOSE=0;
our @EXPRESSIONS;
my $KEY='perl -e "{print \$key}"';
$CGI::POST_MAX=1024 * 10; # max 10K posts
$CGI::DISABLE_UPLOADS = 1; # no uploads



my $resolver = Net::DNS::Resolver->new;
$resolver->nameservers('208.67.222.222','208.67.220.220');

# Traverse desired filesystems and read the expressions
File::Find::find({wanted => \&wanted}, '/opt/Rautor/BlackLists'); 

my $dbh = DBI->connect("DBI:mysql:database=rautor;host=localhost",
			"root","",
       	                 {'RaiseError' => 0}
		) || die  "No Mysql connection \n";

my $starttime=time;
# Main Program
my $checktime=time;
CGI: while (my $query=new CGI::Fast) {
# Connect to the database.
	print header;

	my $user=$query->param('user');
	my $pass=$query->param('pass');
	if  ( ( ! $user ) || ( ! $pass) )  {
		print "RAUTOR:UNAUTHORIZED user/pass mismatch";
		next;
	}

	my $res=auth_user($user,$pass);
        if ( $res <= 0 ){
		print "RAUTOR:UNAUTHORIZED user/pass mismatch";
		my $IP=$ENV{'REMOTE_ADDR'};
                print STDERR "Rautor Bad Connection Authorization user=$user badpass=$pass from ip=$IP\n";
                next;
        }

	my $url=$query->param('url');
	if ( ! $url) {
		print "RAUTOR:ERROR No url?";
		next;
	}
	# check the full url passed against all the expressions
	foreach  my $expression (@EXPRESSIONS) {
		if ( $url =~ m/$expression/gi ) {
			if ( $VERBOSE ) { print STDERR "$$ Found $url in expressions\n";  }
			print "RAUTOR:BLACKLISTURL $url from expression $expression\n";
			next CGI;
		}
	}
	# get rid of passed data as get parameters
	$url =~ s/\?.*$//gi;
	$url =~ s/\/cgi-bin\/.*/\/cgi-bin\//gi;

 	# get rid of the protocol;
	$url =~ s/^.*:\/\///gi;
	my @uelems=split('/',$url); # the parts of the url
	my $domain=$uelems[0];

	# do we remember it?
	my $result=$CACHE->get($domain) if ( $CACHE );
	# else check it
	if ( ! $result ) {
		$result=checkurl($url);
  		$CACHE->set($domain, $result);
	}

	# update the list
	if ( $result eq "BAD" ) {
		print "RAUTOR:BLACKLISTURL $domain\n";
	}  else {
		print "RAUTOR:CLEAR $domain";
	}
	
}

$dbh->disconnect;
print  STDERR "$$ Exiting / why ? ";

1;

#**************************************************************************
sub checkurl{
my $url=shift;

	my @uelems=split('/',$url); # the parts of the url
	my $domain=$uelems[0];
	my @domelems=split('\.',$domain); # this is the domain broken up

	my $white=checkwhitelists($domain);
	if ( $white >= 1 ){	
		print  STDERR "$domain in SQL whitelists\n" if ( $VERBOSE);
		return "CLEAR";
	}


	# now look it up in the database
	my $res=findsql_dom($domain);
	if ( $res eq "BAD" ){
		print  STDERR "$domain in SQL blacklists\n" if ( $VERBOSE);
		return $res;
	}
	# domain not found, check the full url part;
	# rebuild part of the urls;
	$res=findsql_url($url);
	if ( $res eq "BAD" ){
		print  STDERR "$url in SQL blacklists\n" if ( $VERBOSE);
		return $res;
	}
	my $domresult=DoOpenDNS($resolver,$domain);
	if ( $domresult eq "BAD" ){		# we got a baddy 
		print  STDERR "$domain in DNS blacklist\n" if ( $VERBOSE);
		return "BAD";
	}
	return "CLEAR";
}

#**************************************************************************
sub wanted {
    return if ( /CATEGORIES/);
    my $filename=$_;
    if ( ! -f $filename ){
	return;
    }
    if  (  $filename eq "expressions" )  {
	open FIN ,"<$filename" || return;
	while(<FIN>){
		chomp($_);
		push @EXPRESSIONS,$_;
	}
	close (FIN);
    }
}


#**************************************************************************
sub dnsquery{
my $resolver=shift;
my $domain=shift;
my $type=shift;

	my $query = $resolver->search($domain);
        if (! $query) {
		return undef;
	}
	my @results=();
        foreach my $rr ($query->answer) {
              	if ($rr->type eq $type ){
              		push (@results , $rr->address)	if ( ( $rr->type eq "A" )   && ($rr->address)) ;			
              		push (@results , $rr->ptrdname)	if ( ( $rr->type eq "PTR" ) && ($rr->ptrdname));
		}
        }
	return @results;
}


#**************************************************************************
sub DoOpenDNS{
my ($resolver,$domain)=@_;
	# first do an opendns check !
	my @result=();
	eval {
       		local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
        	alarm 3;

		@result=dnsquery($resolver,$domain,"A");

        	alarm 0;
    	};
    	if ($@) {
        	die unless $@ eq "alarm\n";   # propagate unexpected errors
    	}

	if ( ! @result ) { # continue if an error has occured
		return "Oh go ahead";
	}

	if ( $VERBOSE ) {
		print STDERR "IP for $domain is:";
		foreach my $ipa ( @result ) {
			print STDERR $ipa ;
		}
		print STDERR "\n";
	}


	
	foreach my $address ( @result ) {
		my @rev=();
		eval {
       			local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
        		alarm 3;
			# do a reverse lookup
			@rev=dnsquery($resolver,$address,"PTR");
        		alarm 0;
    		};
	    	if ($@) {
        		die unless $@ eq "alarm\n";   # propagate unexpected errors
    		}
		foreach my $reverse (@rev){
			next if ( ! $reverse);
			print STDERR "Reverse of $address is $reverse\n" if ( $VERBOSE);
			return "BAD" if ( $reverse =~ /hit-.*\.opendns\.com/gi );
			return "BAD" if ( $reverse =~ /block\.opendns\.com/gi );
		}

	}

	return "CLEAR";
}


#*********************************************
sub findsql_dom{
my $domain=shift;

	my @domelems=split('\.',$domain); # this is the domain broken up

	#Find just the domain in the blacklists
	for (my $i=$#domelems-1;$i>=0;$i--){
		my $partdom=join('.',@domelems[$i .. $#domelems]);
		my $domquery="SELECT url from blacklists where 	url='$partdom'";
		print STDERR  $domquery . "\n" if ( $VERBOSE > 1 );
		my $sth = $dbh->prepare($domquery);
  		$sth->execute;
    		my $numRows = $sth->rows;
		if ( $numRows > 0 ){
			print STDERR "$partdom is in SQL blacklist\n" if ( $VERBOSE);
			return "BAD";
		}
	
	}
	return "CLEAR";
}

#*********************************************
sub findsql_url{
my $url=shift;

	my @uelems=split('/',$url); # the parts of the url
	my $domain=$uelems[0];
	my @domelems=split('\.',$domain); # this is the domain broken up
	my $iters=0;
	my $newurl=$domain;
	for (my $i=1;$i<=$#uelems;$i++){
		$iters++;
		$newurl =~ s/^www\.//gi; # get rid of the www prefix;
		$newurl .= "/" . $uelems[$i];
		$newurl =~ s/\/\//\//g;
		my $sqlquery = sprintf("SELECT url from blacklists where url='%s';",$newurl);
		print STDERR $sqlquery."\n" if ( $VERBOSE > 1);
		my $sth = $dbh->prepare($sqlquery);
    		$sth->execute;
    		my $numRows = $sth->rows;
		if ( $numRows > 0 ){
			print STDERR "$newurl is in SQL blacklist\n" if ( $VERBOSE);
			return "BAD";
		}
	}
	return "CLEAR";
}

#*********************************************
sub auth_user{
my ( $user,$pass)=@_;

        # first authenticate the user;
	my $dec=decrypt($pass,$KEY);

	if ( ( $user eq "FREE" )  && ( $dec eq "arakataka" ) ) {
		return 1;
	}
	# this is not a freee user
        my $dbquery="SELECT username from users where username='$user' and password='$dec'";
        print STDERR $dbquery . "\n" if ( $VERBOSE );
        my $sth = $dbh->prepare($dbquery);
        $sth->execute;
        my $numRows = $sth->rows;
        $sth->finish;
	return $numRows;
}

#*********************************************
sub checkwhitelists{
my $domain=shift;
	my @domelems=split('\.',$domain); # this is the domain broken up

	#Find just the domain in the blacklists
	for (my $i=$#domelems-1;$i>=0;$i--){
		my $partdom=join('.',@domelems[$i .. $#domelems]);
		my $domquery="SELECT url from whitelists where 	url='$partdom'";
		print STDERR  $domquery . "\n" if ( $VERBOSE > 1 );
		my $sth = $dbh->prepare($domquery);
  		$sth->execute;
    		my $numRows = $sth->rows;
		$sth->finish;
		if ( $numRows > 0 ){
			return $numRows;
		}
	
	}
	return 0;
}

