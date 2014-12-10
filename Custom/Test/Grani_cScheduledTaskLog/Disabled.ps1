configuration Disabled
{
    Import-DscResource -ModuleName GraniResource
    cScheduleTaskLog hoge
    {
        Enable = $false
    }
}

Disabled -OutputPath Disabled
Start-DscConfiguration -Wait -Force -Verbose -Path Disabled