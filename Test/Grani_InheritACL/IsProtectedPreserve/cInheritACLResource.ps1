# Present
configuration InheritACL
{
    Import-DscResource -ModuleName GraniResource

    $path = "C:\test";
    node Localhost
    {
        File hoge
        {
            Ensure            = "Present"
            DestinationPath   = $path
            Type              = "Directory"
        }

        cInheritACL hoge
        {
            Path    = $path
            IsProtected = $true
            PreserveInheritance = $true
        }
    }
}

InheritACL
Start-DscConfiguration -Wait -Force -Verbose -Path InheritACL
Get-DscConfiguration
Test-DscConfiguration