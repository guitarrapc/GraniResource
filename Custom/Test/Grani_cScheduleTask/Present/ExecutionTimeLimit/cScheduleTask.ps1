configuration present
{
    Import-DscResource -Modulename GraniResource
    Node $AllNodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cScheduleTask hoge
        {
            Ensure = "present"
            Execute = "powershell.exe"
            Argument = '-Command "Get-Date | Out-File c:\hoge.log"'
            TaskName = "hoge"
            TaskPath = "\"
            ScheduledAt = [datetime]"00:00:00"
            ExecuteTimeLimitTicks = (New-TimeSpan -Minutes 10 -Days 1 -Hours 1).Ticks
            Daily = $true
            Disable = $false
            Credential = (get-valentiaCredential -TargetName administrator)
        }
    }
}

$ConfigurationData = @{
    Allnodes = @(
    @{
        NodeName = "*"
        PSDscAllowPlainTextPassword = $true
    }
    @{
        NodeName ="localhost"
        Role = "localhost"
    }
    )
}
present -OutputPath . -ConfigurationData $ConfigurationData
Start-DscConfiguration -Wait -Force -Verbose -Path present