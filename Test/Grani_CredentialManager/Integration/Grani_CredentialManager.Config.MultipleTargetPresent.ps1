configuration Grani_CredentialManager_Config_MultipleTargetPresent
{
    Import-DscResource -Modulename GraniResource
    Node localhost
    {
        foreach($item in $Node.InstanceIdentifier)
        {
            cCredentialManager MultipleTargetPresent
            {
                InstanceIdentifier = $item
                Ensure = $Node.Ensure
                Target = $Node.Target
                Credential = $Node.Credential
            }

            cCredentialManager MultipleTargetPresent2
            {
                InstanceIdentifier = $item
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
            InstanceIdentifier = "PesterTest", "PesterTest2"
            Ensure = "Present"
            Target = "PesterTest"
            Credential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
        }
    )
}
