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

See **Test** Project for the detail.

Method | Result
----|----
Pester| pass
Configuration| pass
Get-DSCConfiguration| pass
Test-DSCConfiguration| pass

Intellisense
----

![](cCredentialManager.png)


Sample
----

### Sample 1. Create Credential Manager entry **DesiredTargetName** to DSC run account (== SYSTEM Account).

```powershell
configuration Present_System
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        cCredentialManager Present
        {
            Ensure = $Node.Ensure
            Target = $Node.Target
            Credential = $Node.Credential
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            Ensure = "Present"
            Target = "DesiredTargetName"
            Credential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
        }
    )
}

Present_System -ConfigurationData $configurationData
```

### Sample 2. Remove Credential Manager entry **DesiredTargetName** from DSC run account (== SYSTEM Account).

```powershell
configuration Absent_System
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        cCredentialManager Present
        {
            Ensure = $Node.Ensure
            Target = $Node.Target
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            Ensure = "Absent"
            Target = "DesiredTargetName"
        }
    )
}

Absent_System -ConfigurationData $configurationData
```

Tips
----

You can handle which user to be target by using PsDscRunAsCredential.

PsDscRunAsCredential functionality is supports from WMF5, so WMF4 users could not handle this behavior.

### Sample3. Create Credential Manager entry **DesiredTargetName** to Specific user account by using PsDscRunAsCredential (== In this case **administrator**).

```powershell
configuration Present_PsDscRunAsCredential
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        cCredentialManager Present
        {
            Ensure = $Node.Ensure
            Target = $Node.Target
            Credential = $Node.Credential
            PsDscRunAsCredential = $Node.PsDscRunAsCredential
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            Ensure = "Present"
            Target = "DesiredTargetName"
            Credential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
            PsDscRunAsCredential = New-Object PSCredential ("administrator", ("SuperExcellntPassword____????1111" | ConvertTo-SecureString -Force -AsPlainText))
        }
    )
}

Present_PsDscRunAsCredential -ConfigurationData $configurationData
```

### Sample4. Remove Credential Manager entry **DesiredTargetName** from Specific user account by using PsDscRunAsCredential (== In this case **administrator**).

```powershell
configuration Absent_PsDscRunAsCredential
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        cCredentialManager Present
        {
            Ensure = $Node.Ensure
            Target = $Node.Target
            PsDscRunAsCredential = $Node.PsDscRunAsCredential
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            Ensure = "Absent"
            Target = "DesiredTargetName"
            PsDscRunAsCredential = New-Object PSCredential ("administrator", ("SuperExcellntPassword____????1111" | ConvertTo-SecureString -Force -AsPlainText))
        }
    )
}

Absent_PsDscRunAsCredential -ConfigurationData $configurationData
```
