#!perl.exe
#
#
#


$user="rautor";
$pass="rautor";

push @INC,"c:\\perl\\bin";

 use Net::FTPSSL;

  my $ftps = Net::FTPSSL->new('rautor',
                              Port => 21,
                                 Debug => 1)
			    or die "Can't open ftp.yoursecureserver.com";

     $ftps->login($user,$pass)
	        or die "Can't login: ", $ftps->last_message();

 $ftps->cwd("Audit") or die "Can't change directory: " . $ftps->last_message();

  $ftps->get("file") or die "Can't get file: " . $ftps->last_message();

   $ftps->quit();
