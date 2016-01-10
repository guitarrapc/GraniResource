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
            Argument = '-Command "Get-Date | Out-File c:\hoge1.log"'
            TaskName = "hoge"
            TaskPath = "\"
            AtLogOn = $true
            Compatibility = "Win8"
            Disable = $false
            Credential = $Credential
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
Start-DscConfiguration -Wait -Force -Verbose ScheduleTask -Debug
Test-DscConfiguration
Get-DscConfiguration