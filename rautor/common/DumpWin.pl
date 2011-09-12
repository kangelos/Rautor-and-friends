use Win32::GuiTest qw /FindWindowLike GetWindowText WMGetText/;


print DumpAnyText();

############# Screen Scraper Section ################
#####################################################
sub DumpAnyText{
        my $Text="";
        my @hwnds = FindWindowLike();
        foreach my $window (@hwnds) {
                my $title=GetWindowText($window);
#                next if ( $title =~ /^$/);
                $Text .= "[$title]\n";

                my @edits=FindWindowLike($window,"","");
                foreach my $ed (@edits) {
                        my $text=" " x 65536;
                        $text=GetWhatYoucan($ed);
                        $text=~s/\x00/ / ;
                        $text=~s/[\r\n]$// ;
                        next if ($text =~ /^$/ );
                        $Text .= "\t". $text ."\n";
                }
                $Text .= "\n";
        }
        return($Text);
}

######################################################################
sub GetWhatYoucan{
        my $ed=shift;

        my $text="";
        eval {
                local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
                alarm 2;
                $text=WMGetText($ed);
                alarm 0;
        };
        if ($@) {
                return undef;
        }
        return $text;
}
