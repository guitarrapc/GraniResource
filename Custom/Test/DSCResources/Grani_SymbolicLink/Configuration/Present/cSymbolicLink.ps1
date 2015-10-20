configuration present
{
    Import-DscResource -ModuleName GraniResource
    cSymbolicLink hoge
    {
        SourcePath = "C:\Logs\DSC"
        DestinationPath = "C:\DSC"
        Ensure = "Present"
    }
}

present
Start-DscConfiguration -Path present -Wait -Verbose -Force