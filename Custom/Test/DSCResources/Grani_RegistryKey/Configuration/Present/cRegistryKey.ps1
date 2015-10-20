configuration present
{
    Import-DscResource -ModuleName GraniResource
    cRegistryKey hoge
    {
        Key = "HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
        Ensure = "Present"
    }    
}

present
Start-DscConfiguration -Path present -Wait -Verbose -Force