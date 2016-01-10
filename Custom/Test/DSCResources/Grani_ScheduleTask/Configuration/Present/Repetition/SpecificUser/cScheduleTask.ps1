configuration ScheduleTask
{
    param([PSCredential]$Credential)
    Import-DscResource -Modulename GraniResource
    Node $AllNodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cScheduleTask ScheduleTask
        {
            Ensure = "Present"
            Execute = "powershell.exe"
            Argument = '-Command "Get-Date | Out-File c:\hoge.log"'
            TaskName = "hoge"
            TaskPath = "\"
            ScheduledAt = [datetime]"00:00:00"
            RepetitionIntervalTimeSpanString = @(([TimeSpan]"01:00:00").ToString())
            RepetitionDurationTimeSpanString = @(([TimeSpan]::MaxValue).ToString())
            Compatibility = "Win8"
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
$credential = Get-Credential
ScheduleTask -ConfigurationData $ConfigurationData -Credential $credential
Start-DscConfiguration -Wait -Force -Verbose ScheduleTask