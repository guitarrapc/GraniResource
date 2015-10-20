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
            IsProtected = $false
            PreserveInheritance = $true
        }
    }
}

InheritACL
Start-DscConfiguration -Wait -Force -Verbose -Path InheritACL
Test-DscConfiguration
Get-DscConfiguration
