Grani_CredentialManager
============

DSC Resource to manage Credential Manager.

Resource Information
----

Name | FriendlyName | ModuleName 
-----|-----|-----
Grani_CredentialManager | cCredentialManager | GraniResource

Test Status
----

See GraniResource.Test for the detail.

Method | Result
----|----
Pester| WIP
Configuration| WIP
Get-DSCConfiguration| WIP
Test-DSCConfiguration| WIP

Intellisense
----

![](cCredentialManager.png)


Sample
----


```powershell
configuration Hoge
{
    Import-DscResource -ModuleName GraniResource;
    Node localhost
    {
        cCredentialManager Credential
        {
            Ensure = "Present"
            Target = "hoge"
            Credential = $Node.Credential
            PsDscRunAsCredential = $Node.Administrator
        }
    }
}

$data = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            Credential = $Credential
            Administrator = $Administrator
        }
    )
}

Hoge -ConfigurationData $data
```

Tips
----

