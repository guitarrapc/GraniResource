configuration DisableCleanupTask
{
    Import-DscResource -ModuleName GraniResource
    cScheduleTask PlugAndPlayCleanup
    {
        Ensure = "Present"
        TaskName = 'Plug and Play Cleanup'
        TaskPath = '\Microsoft\Windows\Plug and Play\'
        Disable = $true
    }
}

DisableCleanupTask -OutputPath .
Start-DscConfiguration -Wait -Force -Verbose -Path DisableCleanupTask