configuration Absent
{
    Import-DscResource -ModuleName GraniResource

    cDotNetFramework hoge
    {
        KB = "KB3045563"
        Ensure = "Absent"
        NoRestart = $true
    }    
}

Absent
Start-DscConfiguration -Force -Wait -Path Absent -Verbose
Get-DscConfiguration
Test-DscConfiguration