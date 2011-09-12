use strict;
        use Win32::SysTray;
        use File::Basename;
        use File::Spec::Functions qw[ catfile rel2abs updir ];
        
        my $tray = new Win32::SysTray (
                'icon' => rel2abs(dirname($0)).'\daemon.ico',
                'single' => 1,
        ) or exit 0;
        
        $tray->setMenu (
                "> &Test" => sub { print "Hello from the Tray\n"; system("http://www.unix.gr");},
                ">-"      => 0,
                "> E&xit" => sub { return -1 },
        ); 
        
        $tray->runApplication;
