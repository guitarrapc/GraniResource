configuration absent
{
    Import-DscResource -ModuleName GraniResource
    cRegistryKey hoge
    {
        Key = "HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
        Ensure = "Absent"
    }    
}

absent
Start-DscConfiguration -Path absent -Wait -Verbose -Force