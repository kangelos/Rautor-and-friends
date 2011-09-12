#!perl

package coliau;

use Win32::OLE;
use Win32;
use File::Basename;


sub firewallOpen {	
	my $path=Win32::GetFullPathName($0);
	my($filename, $directories, $suffix) = fileparse($path);
	$filename =~ s/.exe//i;  
	my $name=$filename;
	
	my $_app_object = (Win32::OLE->GetActiveObject('WScript.Shell') ||
                   Win32::OLE->new('WScript.Shell'));

	$objFirewall = Win32::OLE->new('HNetCfg.FwMgr');
	$objPolicy =  $objFirewall->LocalPolicy;
	$objProfile = $objPolicy->GetProfileByType(1);

	$objApplication = Win32::OLE->new('HNetCfg.FwAuthorizedApplication');
	$objApplication->{Name} = $name;
	$objApplication->{IPVersion} = 2;
	$objApplication->{ProcessImageFileName} = $path;
	$objApplication->{RemoteAddresses} = '*';
	$objApplication->{LocalAddresses} = '*';
	$objApplication->{Scope} = 0;
	$objApplication->{Enabled} = 1;

	$colApplications = $objProfile->AuthorizedApplications;
	$colApplications->Add($objApplication);
}

1;
