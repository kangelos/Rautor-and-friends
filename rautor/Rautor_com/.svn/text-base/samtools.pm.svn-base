
package SamTools::Process;

use Win32::PerfLib;
use Win32::API;
use Win32::Process::Info;

sub getpid {
    my $process = shift;

    my $server = $ENV{COMPUTERNAME};
    my $pid;

    Win32::PerfLib::GetCounterNames($server, \%counter);
    %r_counter = map { $counter{$_} => $_ } keys %counter;
    $process_obj = $r_counter{Process};
    $process_id = $r_counter{'ID Process'};
    $perflib = new Win32::PerfLib($server) || return 0;
    $proc_ref = {};
    $perflib->GetObjectList($process_obj, $proc_ref);
    $perflib->Close();
    $instance_ref = $proc_ref->{Objects}->{$process_obj}->{Instances};
    foreach $p (sort keys %{$instance_ref}){
        $counter_ref = $instance_ref->{$p}->{Counters};
        foreach $i (keys %{$counter_ref}){
            if($counter_ref->{$i}->{CounterNameTitleIndex} ==
               $process_id && $instance_ref->{$p}->{Name} eq $process){
                $pid = $counter_ref->{$i}->{Counter};
                last;
            }
        }
    }

    #try again using a different approach WMI
    unless ($pid){
        if (my $pi = Win32::Process::Info->new($server)){
            my $processes = $pi->GetProcInfo();
            my $number = @$processes;
            foreach (@$processes){
                if ($_->{Name} =~ /$process/i){
                    $pid = $_->{ProcessId};
                }
            }
        }
    }

    $pid?return $pid:return 0;
}

sub pidalive {
    my $pid = shift;
    my $server = $ENV{COMPUTERNAME};

    Win32::PerfLib::GetCounterNames($server, \%counter);
    %r_counter = map { $counter{$_} => $_ } keys %counter;
    $process_obj = $r_counter{Process};
    $process_id = $r_counter{'ID Process'};
    $perflib = new Win32::PerfLib($server) || return 0;
    $proc_ref = {};
    $perflib->GetObjectList($process_obj, $proc_ref);
    $perflib->Close();
    $instance_ref = $proc_ref->{Objects}->{$process_obj}->{Instances};
    foreach $p (sort keys %{$instance_ref}){
        $counter_ref = $instance_ref->{$p}->{Counters};
        foreach $i (keys %{$counter_ref}){
            if ($counter_ref->{$i}->{Counter} == $pid){
                return $pid;
            }
        }
    }
    return 0;
}

sub kill {
    my $process = shift;
    my $pid = getpid($process);
    if ($pid){
        Configure();
        $iResult = ForceKill( $pid );
        return 1 if( $iResult );
    }
    return 0;
}

sub kill_pid {
    my $pid = shift;
    Configure();
    $iResult = ForceKill( $pid );
    return 1 if( $iResult );
    return 0;
}

sub ForceKill {
    my( $Pid ) = @_;
    my $iResult = 0;
    my $phToken = pack( "L", 0 );
    # Fetch the process's token
    if($OpenProcessToken->Call($GetCurrentProcess->Call(),
                               $TOKEN_ADJUST_PRIVILEGES | $TOKEN_QUERY,
                               $phToken )){
        my $hToken = unpack( "L", $phToken );
        # Set the debug privilege on the token
        if( SetPrivilege( $hToken, $SE_DEBUG_NAME, 1 ) ){
            # Now that we have debug privileges on the process
            # open the process so we can mess with it.
            my $hProcess = $OpenProcess->Call( $PROCESS_TERMINATE, 0, $Pid );
            if( $hProcess ){
                # We no longer need the debug privilege since we have opened
                # the process so remove the privilege.
                SetPrivilege( $hToken, $SE_DEBUG_NAME, 0 );
                # Let's termiante the process
                $iResult = $TerminateProcess->Call( $hProcess, 0 );
                $CloseHandle->Call( $hProcess );
            }
        }
        $CloseHandle->Call( $hToken );
    }
    return $iResult;
}

sub SetPrivilege {
    my( $hToken, $pszPriv, $bSetFlag ) = @_;
    my $pLuid = pack( "Ll", 0, 0 );
    # Lookup the LIUD of the privilege
    if( $LookupPrivilegeValue->Call( "\x00\x00", $pszPriv, $pLuid ) ){
        # Unpack the LUID
        my $pPrivStruct = pack( "LLlL",
                               1,
                               unpack( "Ll", $pLuid ),
                               ( ( $bSetFlag )? $SE_PRIVILEGE_ENABLED : 0 )
                               );
        # Now modify the process's token to set the required privilege
        $iResult = ( 0 != $AdjustTokenPrivileges->Call( $hToken,
                                                       0,
                                                       $pPrivStruct,
                                                       length( $pPrivStruct ),
                                                       0,
                                                       0 )
                    );
    }

    return $iResult;
}

sub Configure {
    $TOKEN_QUERY             = 0x0008;
    $TOKEN_ADJUST_PRIVILEGES = 0x0020;
    $SE_PRIVILEGE_ENABLED    = 0x02;
    $PROCESS_TERMINATE       = 0x0001;
    $SE_DEBUG_NAME           = "SeDebugPrivilege";

    # Prepare to use some specialized Win32 API calls
    $GetCurrentProcess     = new Win32::API( 'Kernel32.dll',
                                             'GetCurrentProcess',
                                             [],
                                             N ) || die;
    $OpenProcessToken      = new Win32::API( 'AdvApi32.dll',
                                             'OpenProcessToken',
                                             [N,N,P], I ) || die;
    $LookupPrivilegeValue  = new Win32::API( 'AdvApi32.dll',
                                             'LookupPrivilegeValue',
                                             [P,P,P], I ) || die;
    $AdjustTokenPrivileges = new Win32::API( 'AdvApi32.dll',
                                             'AdjustTokenPrivileges',
                                             [N,I,P,N,P,P],
                                             I ) || die;
    $OpenProcess           = new Win32::API( 'Kernel32.dll',
                                             'OpenProcess',
                                             [N,I,N],
                                             N ) || die;
    $TerminateProcess      = new Win32::API( 'Kernel32.dll',
                                             'TerminateProcess',
                                             [N,I],
                                             I ) || die;
    $CloseHandle           = new Win32::API( 'Kernel32.dll',
                                             'CloseHandle',
                                             [N],
                                             I ) || die;
}

1;

__END__

=head1 NAME

SamTools::Process - Sam's Process controllers.

=head1 SYNOPSIS

    use SamTools::Process;

=head1 DESCRIPTION

This module controls processes on Win32 Systems.  Currently, only has killing capability.

use SamTools::Process;

=head1 kill

SamTools::Process::kill('ProcessName');

