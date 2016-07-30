configuration Grani_CredentialManager_Config_MultipleTargetPresent
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        foreach($identifier in $Node.InstanceIdentifier)
        {
            cCredentialManager $identifier
            {
                InstanceIdentifier = $identifier
                Ensure = $Node.Ensure
                Target = $Node.Target
                Credential = $Node.Credential
            }
        }
    }
}

#configurationData
$configurationDataMultipleTargetPresent = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $true
            InstanceIdentifier = @("PesterTest", "PesterTest2")
            Ensure = "Present"
            Target = "PesterTest"
            Credential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
        }
    )
}
