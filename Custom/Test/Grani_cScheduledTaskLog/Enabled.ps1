configuration Enabled
{
    Import-DscResource -ModuleName GraniResource
    cScheduleTaskLog hoge
    {
        Enable = $true
    }
}

Enabled -OutputPath Enabled
Start-DscConfiguration -Wait -Force -Verbose -Path Enabled