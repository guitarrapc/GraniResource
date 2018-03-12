configuration Grani_CredentialManager_Config_Absent
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        cCredentialManager Absent
        {
            InstanceIdentifier = $Node.InstanceIdentifier
            Ensure = $Node.Ensure
            Target = $Node.Target
            Credential = $Node.Credential
        }
    }
}

#configurationData
$configurationDataAbsent = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            InstanceIdentifier = "PesterTest"
            Ensure = "Absent"
            Target = "PesterTest"
            Credential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
        }
    )
}
