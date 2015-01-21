configuration EnableCleanupTask
{
    Import-DscResource -ModuleName GraniResource
    cScheduleTask PlugAndPlayCleanup
    {
        Ensure = "Present"
        TaskName = 'Plug and Play Cleanup'
        TaskPath = '\Microsoft\Windows\Plug and Play\'
        Disable = $false
    }
}

EnableCleanupTask -OutputPath .
Start-DscConfiguration -Wait -Force -Verbose -Path EnableCleanupTask