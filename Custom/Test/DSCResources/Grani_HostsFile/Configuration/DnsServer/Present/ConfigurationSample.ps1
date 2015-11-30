configuration Present
{
    Import-DscResource -ModuleName GraniResource
    cHostsFile hoge
    {
        HostName = "google.com"
        IpAddress = "8.8.8.8"
        Ensure = "Present"
        Reference = "DnsServer"
    }    
}

Present
Start-DscConfiguration -Force -Wait -Path Present -Verbose
Get-DscConfiguration
Test-DscConfiguration