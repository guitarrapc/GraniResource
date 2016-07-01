# It can be work when there are already non-inherited access in $path.
# But if it were scratch path, there should be none of non-inherited access, 
# and configuration should throw as there will be no access left.
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
            PreserveInheritance = $false
        }
    }
}

InheritACL
Start-DscConfiguration -Wait -Force -Verbose -Path InheritACL
Get-DscConfiguration
Test-DscConfiguration