use Win32::Exe;

	print " mangling  $ARGV[0] \n";
     
	 my $exe = Win32::Exe->new($ARGV[0]);
	 my $icon = $ARGV[1];	

     # Get version information
     print $exe->version_info->get('FileDescription') , "\n";
     print $exe->version_info->get('LegalCopyright'), "\n";


     # Import icons from a .exe or .ico file and writes back the file
     $exe->update( icon => $icon );

     # Dump icons in an executable
     foreach my $icon ($exe->icons) {
         printf "Icon: %s x %s (%s colors)\n",
                $icon->Width, $icon->Height, 2 ** $icon->BitCount;
     }

 # Add a manifest section
#     $exe->update( manifest => $mymanifestxml );
#     # or a default
#     $exe->update( defaultmanifest => 1 );


   my @pairs=[
     ["CompanyName"=>"Unix.gr"],
      ["FileDescription"=>"Rautor"],
       ["FileVersion"=>"1.1.0.0"],
       ["LegalCopyright"=>"Unix.gr"],
       ["LegalTrademarks"=> "Unix.gr"],
       ["ProductName"=>"coliau"],
       ["ProductVersion"=>"1.1.0.0"],
   ];
$exe->update(\@pairs);
