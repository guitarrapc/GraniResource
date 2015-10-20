configuration absent
{
    Import-DscResource -Modulename GraniResource
    Node $AllNodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cScheduleTask hoge
        {
            Ensure = "absent"
            Execute = "powershell.exe"
            TaskName = "hoge"
            TaskPath = "\"
            ScheduledAt = [datetime]"00:00:00", [datetime]"01:00:00"
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
absent -OutputPath . -ConfigurationData $ConfigurationData
Start-DscConfiguration -Wait -Force -Verbose -Path absent