configuration PendingReboot
{
    Import-DscResource -ModuleName GraniResource
    cPendingReboot PendingReboot
    {
        Name = "Pending Reboot"
        WaitTimeSec = 5
        Force = $true
        WhatIf = $false
    }
}
PendingReboot
Start-DscConfiguration -Path PendingReboot -Wait -Force -Verbose