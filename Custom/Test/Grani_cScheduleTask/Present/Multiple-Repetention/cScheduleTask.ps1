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
            ScheduledAt = [datetime]"00:00:00", [datetime]"01:00:00"
            ScheduledTimeSpanDay = 0,0
            ScheduledTimeSpanHour = 1,1
            ScheduledTimeSpanMin = 0,0
            ScheduledDurationDay = 0,0
            ScheduledDurationHour = 0,0
            ScheduledDurationMin = 0,0
            Credential = (get-valentiaCredential)
            Disable = $false
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