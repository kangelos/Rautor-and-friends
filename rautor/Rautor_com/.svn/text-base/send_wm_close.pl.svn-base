#!/usr/bin/perl

use strict;
use warnings;

use Win32::GuiTest qw(FindWindowLike SendKeys SetForegroundWindow GetWindowText) ;

die "Need pattern to match against window titles\n" unless @ARGV;
my ($windowtitle) = @ARGV;

my ($myhandle) = FindWindowLike(0, qr/$0/);

my @windows = FindWindowLike(0, qr/\Q$windowtitle\E/i);
my @windows = FindWindowLike(0, qr/./i);


my $last;
for my $handle ( @windows ) {
	print "$handle	". GetWindowText($handle) ."\n";
	$last=$handle;
#    next if $handle == $myhandle;
#    SetForegroundWindow($handle);
#    SendKeys("%{F4}");
}


use Win32::GUI qw( WM_CLOSE );
my $tray = Win32::GUI::FindWindow("kidns.pl","kidns.pl");
#Win32::GUI::SendMessage($last,WM_CLOSE,0,0);
