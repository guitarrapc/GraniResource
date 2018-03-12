configuration PendingReboot
{
    Import-DscResource -ModuleName GraniResource
    cPendingReboot PendingReboot
    {
        Name = "Pending Reboot"
        WaitTimeSec = 5
        Force = $true
        WhatIf = $true
        TriggerPendingFileRename = $false
    }
}

PendingReboot
Start-DscConfiguration -Wait -Force -Verbose PendingReboot