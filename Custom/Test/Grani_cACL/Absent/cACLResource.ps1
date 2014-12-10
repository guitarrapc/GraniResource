# Absent
configuration ACLChange
{
    Import-DscResource -ModuleName GraniResource

    node Localhost
    {
        File hoge
        {
            Ensure            = "Present"
            DestinationPath   = "C:\host.txt"
            Type              = "file"
            Contents          = "hoge"
        }

        cACL Absent
        {
            Ensure  = "Absent"
            Path    = "C:\host.txt"
            Account = "Users"
            Rights  = "FullControl"
        }
    }
}

ACLChange -OutputPath .
Start-DscConfiguration -Wait -Force -Verbose -Path ACLChange
