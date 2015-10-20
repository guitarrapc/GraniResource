configuration Absent
{
    Import-DscResource -ModuleName GraniResource
    cHostsFile hoge
    {
        HostName = "google.com"
        IpAddress = "8.8.8.8"
        Ensure = "Absent"
    }    
}

absent
Start-DscConfiguration -Force -Wait -Path absent -Verbose