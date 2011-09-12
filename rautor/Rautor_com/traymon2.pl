    use Win32::GUI;
    use File::Basename;
	use Win32::TieRegistry ( Delimiter=>'/');
	use Win32::Process;


    $main = Win32::GUI::Window->new(-name => 'Main', -text => 'Perl',
                                    -width => 200, -height => 200);

    $icon = new Win32::GUI::Icon('daemon.ico');
    $ni = $main->AddNotifyIcon(-name => "NI", -id => 1,
                               -icon => $icon, -tip => "Hello");

    Win32::GUI::Dialog();

    sub Main_Terminate {
        -1;
    }

    sub Main_Minimize {
        $main->Disable();
        $main->Hide();
        1;
    }

    sub NI_Click {
        $main->Enable();
        $main->Show();
	doexplorer();
        1;
    }

############################################################
sub doexplorer{	
	my $browserkey= $Registry->{"HKEY_CLASSES_ROOT/http/shell/open/command"};
	my $default_browser = "$browserkey->{'/'}";
	$default_browser =~ s/\"//g;
	$default_browser =~ s/\ -.*//g;
	my $stripped_browser=basename($default_browser);
	$stripped_browser =~ s/\".*//g;
	$stripped_browser =~ s/ .*//g;

	print $default_browser ."\n",
        $stripped_browser  ." 'http://www.kidns.eu'\n" ;
		
	my $browser;
	Win32::Process::Create($browser, $default_browser,
        $stripped_browser  ." http://www.kidns.eu", 0,
        NORMAL_PRIORITY_CLASS, ".");
}

