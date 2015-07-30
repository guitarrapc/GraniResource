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

        # Create non inherited Aceess before change to protected w/ non preserve
        cACL hoge
        {
            Access  = "Allow"
            Ensure  = "Present"
            Path    = $path
            Account = "Users"
            Rights  = "FullControl"
            Inherit = $false
            Recurse = $true
        }

        cInheritACL hoge
        {
            Path    = $path
            IsProtected = $true
            PreserveInheritance = $false
        }

        # Promise remove AccessRule which you don't want to set
        cACL hoge2
        {
            Access  = "Allow"
            Ensure  = "Absent"
            Path    = $path
            Account = "administrators"
            Rights  = "FullControl"
            Inherit = $false
            Recurse = $true
        }
    }
}

InheritACL
Start-DscConfiguration -Wait -Force -Verbose -Path InheritACL
Get-DscConfiguration
Test-DscConfiguration