#!wperl.exe -w
#
# S.Ox. /pci compliance for rdesktop users 
# Angelos Karageorgiou angelos@unix.gr Nov 2007 
# Major Rework Summer 2009
# Save pngs of screen shots, text contents of well behaved windows,
# and keyboard logging under c:\Audit
# 
# Released unde the GPLv2

use common::sense;

package Rautor;

use Win32::TieRegistry ( Delimiter=>'/');

our $DRIVE;
our $AUDITDIR;
our $FTPSERVER;
our $FTPUSER;
our $FTPPASS;
our $KEEPFILES;
our $SLEEP;
our $QUANTUM;
our @WINDOWSNAMES;
our $TRIGGER;
our $LICENSE;
our $KEYLOGGER;
our $SCREENDUMPER;
our $SCREENSCRAPER;
our $FULLSCRAPE;
our $VERBOSE;
our $LEGALWARNING;
our $DEBUG;
our $DEMO;
our $DECSN;
our $STARTYEAR;
our $ENDYEAR;
our $ENDMONTH;
our $MYNAME;
our $OPENDNS;
our $DIRECTSITES;
our $PROXY;
our $PROXYSERVER;
our $PROXYPORT;
our $PROXYLOCK;
our $TRAYICON;
our $WEBSERVER;
our $WEBPORT;
our $UPLOADOLDFILES;

my $KEYPATH="LMachine/Software";
my $RAUTORPATH="LMachine/Software/$MYNAME";

my %reg;
######################################################################

sub doRegistry{
my $RegCreated=1;

if ( defined($PROXYSERVER) && defined ($PROXYPORT) ){
	$PROXY=$PROXYSERVER.":".$PROXYPORT;
} else {
	$PROXY="";
	$PROXYLOCK=0;
}

my $winNames=join( @WINDOWSNAMES,';');


my $key=$Registry->{$RAUTORPATH};
	if (! defined ($key)  ) {
	   # plug in the defaults creating the key
	   $Registry->{"$KEYPATH/"}={
		$MYNAME => {
			"/LICENSE"		=> "",
			"/DRIVE"		=> $DRIVE,
			"/AUDITDIR"		=> $AUDITDIR,
			"/SLEEP"		=> $SLEEP,
			"/QUANTUM"		=> $QUANTUM,
			"/VERBOSE"		=> $VERBOSE,
			"/FTPSERVER"		=> $FTPSERVER,
			"/FTPUSER"		=> $FTPUSER,
			"/FTPPASS"		=> $FTPPASS,
			"/KEEPFILES"		=> $KEEPFILES,
			"/SCREENSCRAPER"	=> $SCREENSCRAPER,
			"/LEGALWARNING"		=> $LEGALWARNING,
			"/KEYLOGGER"		=> $KEYLOGGER,
			"/WINDOWSNAMES"		=> $winNames,
			"/TRIGGER"		=> $TRIGGER,
			"/SCREENDUMPER"		=> $SCREENDUMPER,
			"/FULLSCRAPE"		=> $FULLSCRAPE,
			"/OPENDNS"		=> $OPENDNS,
			"/PROXYLOCK"		=> $PROXYLOCK,
			"/PROXY"		=> $PROXY,
			"/DIRECTSITES"		=> $DIRECTSITES,
			"/TRAYICON"		=> $TRAYICON,
			"/WEBSERVER"		=> $WEBSERVER,
			"/WEBPORT"		=> $WEBPORT,
			"/UPLOADOLDFILES"	=> $UPLOADOLDFILES,
		}
	   } || undef($RegCreated);

		if ( ! defined( $RegCreated ) ) {
			&mylog("Could not Create Rautor\'s Registry key"); 
			# use defaults
			return; 
		} 
		#reset $key
		$key=$Registry->{$RAUTORPATH};
		if ( ! defined($key) ) {
	   		&mylog("Weird! Could not Read Rautor\'s newly created registry key");
			# use defaults
	   		return;
		}
	} 

	# key is defined and exists    ( it should at least )
	my $rootdrive	=$key->{"/DRIVE"};
	my $auditdir	=$key->{"/AUDITDIR"};
	my $sleep	=$key->{"/SLEEP"};
	my $quantum	=$key->{"/QUANTUM"};
	my $verbose	=$key->{"/VERBOSE"};
	   $winNames 	=$key->{"/WINDOWSNAMES"};
	my $license	=$key->{"/LICENSE"};
	my $ftpserver	=$key->{"/FTPSERVER"};
	my $ftpuser	=$key->{"/FTPUSER"};
	my $ftppass	=$key->{"/FTPPASS"};
	my $keepfiles	=$key->{"/KEEPFILES"};
	my $scraper	=$key->{"/SCREENSCRAPER"};
	my $warning	=$key->{"/LEGALWARNING"};
	my $debug	=$key->{"/DEBUG"};
	my $keylogger	=$key->{"/KEYLOGGER"};
	my $trigger	=$key->{"/TRIGGER"};
	my $dumper	=$key->{"/SCREENDUMPER"};
	my $fullscrape	=$key->{"/FULLSCRAPE"};
	my $opendns	=$key->{"/OPENDNS"};
	my $directsites	=$key->{"/DIRECTSITES"};
	my $proxy	=$key->{"/PROXY"};
	my $proxylock	=$key->{"/PROXYLOCK"};
	my $trayicon	=$key->{"/TRAYICON"};
	my $webserver	=$key->{"/WEBSERVER"};
	my $webport	=$key->{"/WEBPORT"};
	my $uploadoldfiles=$key->{"/UPLOADOLDFILES"};

	if ( defined($rootdrive))	{ $DRIVE=$rootdrive ;			}
	if ( defined($auditdir)	)	{ $AUDITDIR=$auditdir ;			}
	if ( defined($sleep)	)	{ $SLEEP=$sleep ;			}
	if ( defined($quantum)	)	{ $QUANTUM=$quantum ;			}
	if ( defined($verbose)	)	{ $VERBOSE=$verbose ;			}
	if ( defined($winNames)	)	{ @WINDOWSNAMES=split(/[,\;]/,$winNames);}
	if ( defined($license)	)	{ $LICENSE=$license;			}
	if ( defined($ftpserver))	{ $FTPSERVER=$ftpserver;		}
	if ( defined($ftpuser)	)	{ $FTPUSER=$ftpuser;			}
	if ( defined($ftppass)	)	{ $FTPPASS=$ftppass;			}
	if ( defined($keepfiles))	{ $KEEPFILES=$keepfiles;		}
	if ( defined($scraper)	)	{ $SCREENSCRAPER=$scraper;		}
	if ( defined($warning)	)	{ $LEGALWARNING=$warning;		}
	if ( defined($debug)	)	{ $DEBUG=$debug;			}
	if ( defined($keylogger))	{ $KEYLOGGER=$keylogger;		}
	if ( defined($trigger)	)	{ $TRIGGER=$trigger;			}
	if ( defined($dumper)	)	{ $SCREENDUMPER=$dumper;		}
	if ( defined($fullscrape))	{ $FULLSCRAPE=$fullscrape;		}
	if ( defined($opendns))		{ $OPENDNS=$opendns;			}
	if ( defined($directsites))	{ $DIRECTSITES=$directsites;		}
	if ( defined($proxy))		{ $PROXY=$proxy;			}
	if ( defined($proxylock))	{ $PROXYLOCK=$proxylock;		}
	if ( defined($trayicon))	{ $TRAYICON=$trayicon;			}
	if ( defined($webserver))	{ $WEBSERVER=$webserver;		}
	if ( defined($webport))		{ $WEBPORT=$webport;			}
	if ( defined($uploadoldfiles))	{ $UPLOADOLDFILES=$uploadoldfiles;	}

	undef $key;
}


######################################################################

sub ReadRegistry{
my $key=$Registry->{$RAUTORPATH};

	if (! defined ($key)  ) {	# plug in the defaults creating the key
		if ( $VERBOSE == 1 ) {
		   &mylog("Could not Read Rautor\'s dynamic Registry Values");
   		}
	   return;
	} 

	# now get the data again or for the first time !
	my $trigger	=$key->{"/TRIGGER"};
	my $sleep	=$key->{"/SLEEP"};
	my $quantum	=$key->{"/QUANTUM"};
	my $verbose	=$key->{"/VERBOSE"};
	my $debug	=$key->{"/DEBUG"};
	my $winNames	=$key->{"/WINDOWSNAMES"};
	my $keepfiles	=$key->{"/KEEPFILES"};
	my $scraper	=$key->{"/SCREENSCRAPER"};
	my $keylogger	=$key->{"/KEYLOGGER"};
	my $dumper	=$key->{"/SCREENDUMPER"};
	my $fullscrape	=$key->{"/FULLSCRAPE"};
	my $opendns	=$key->{"/OPENDNS"};
	my $directsites	=$key->{"/DIRECTSITES"};
	my $proxy	=$key->{"/PROXY"};
	my $proxylock	=$key->{"/PROXYLOCK"};
	my $trayicon	=$key->{"/TRAYICON"};
	my $webserver	=$key->{"/WEBSERVER"};
	my $webport	=$key->{"/WEBPORT"};
	my $uploadoldfiles=$key->{"/UPLOADOLDFILES"};
	
	if ( defined($trigger)	)	{ $TRIGGER=$trigger;			}
	if ( defined($sleep)	)	{ $SLEEP=$sleep ;			}
	if ( defined($quantum)	)	{ $QUANTUM=$quantum ;			}
	if ( defined($debug)	)	{ $DEBUG=$debug;			}
	if ( defined($verbose)	)	{ $VERBOSE=$verbose ;			}
	if ( defined($winNames)	)	{ @WINDOWSNAMES=split(/[,\;]/,$winNames);}
	if ( defined($keepfiles))	{ $KEEPFILES=$keepfiles;		}
	if ( defined($scraper)	)	{ $SCREENSCRAPER=$scraper;		}
	if ( defined($keylogger))	{ $KEYLOGGER=$keylogger;		}
	if ( defined($dumper)	)	{ $SCREENDUMPER=$dumper;		}
	if ( defined($opendns))		{ $OPENDNS=$opendns;			}
	if ( defined($directsites))	{ $DIRECTSITES=$directsites;		}
	if ( defined($proxy))		{ $PROXY=$proxy;			}
	if ( defined($proxylock))	{ $PROXYLOCK=$proxylock;		}
	if ( defined($trayicon))	{ $TRAYICON=$trayicon;			}
	if ( defined($webserver))	{ $WEBSERVER=$webserver;		}
	if ( defined($webport))		{ $WEBPORT=$webport;			}
	if ( defined($uploadoldfiles))	{ $UPLOADOLDFILES=$uploadoldfiles;	}
     
	undef $key;
}

1;
