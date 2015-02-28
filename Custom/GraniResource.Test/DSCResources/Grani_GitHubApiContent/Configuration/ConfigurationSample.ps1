configuration DownloadGitHubContentFromAPI
{
    param
    (
        [PSCredential]$Credential
    )

    Import-DscResource -ModuleName GraniResource

    node $Allnodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cGitHubApiContent hoge
        {
            DestinationPath = "C:\Tools\README.md"
            Repository = "DSCResources"
            RepositoryOwner = "guitarrapc"
            ContentPath = "README.md"
            OAuth2Token = $Credential
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDSCAllowPlainTextPassword = $true
        }
        @{
            NodeName = "localhost"
            Role     = "localhost"
        }
    )
}
DownloadGitHubContentFromAPI -Credential (Get-Credential) -ConfigurationData $configurationData
Start-DscConfiguration -Wait -Verbose -Force -Path DownloadGitHubContentFromAPI