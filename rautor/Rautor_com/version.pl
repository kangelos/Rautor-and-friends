     use Win32::Exe;

print " mangling  $ARGV[0] \n";
     my $exe = Win32::Exe->new($ARGV[0]);
	my $VERSION="1.8";

     # Get version information
     print $exe->version_info->get('FileDescription') . "\n";
#     $exe->version_info->set('LegalCopyright','Unix.gr');
 #    print    $exe->version_info->get('LegalCopyright'), "\n";


     # Import icons from a .exe or .ico file and writes back the file
     $exe->update( icon => 'bull.ico' );

     # Dump icons in an executable
     foreach my $icon ($exe->icons) {
         printf "Icon: %s x %s (%s colors)\n",
                $icon->Width, $icon->Height, 2 ** $icon->BitCount;
     }
#     # Change it to a console application, then save to another .exe
#     $exe->SetSubsystem('console');
#     $exe->write('c:/windows/another.exe');

 # Add a manifest section
#     $exe->update( manifest => $mymanifestxml );
#     # or a default
#     $exe->update( defaultmanifest => 1 );

#	ProductVerion	=>$VERSION
#	LegalCopyright	=>Unix.gr
#	ProductName	=>Rautor

   my @pairs=[
     ["CompanyName"=>"Unix.gr"],
      ["FileDescription"=>"Rautor"],
       ["FileVersion"=>"1.0.0.7"],
       ["LegalCopyright"=>"Unix.gr"],
       ["LegalTrademarks"=> "Unix.gr"],
       ["ProductName"=>"Rautor"],
       ["ProductVersion"=>"1.7.0.0"],
   ];
$exe->update(\@pairs);
