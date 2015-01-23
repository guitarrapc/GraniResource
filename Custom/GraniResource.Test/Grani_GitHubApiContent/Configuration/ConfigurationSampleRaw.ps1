configuration DownloadGitHubRawContentFromAPI
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
            DestinationPath = "C:\Tools\xDscResourceDesigner.zip"
            Repository = "DSCResources"
            RepositoryOwner = "guitarrapc"
            ContentPath = "MicrosoftScriptCenter/xDSCResourceDesigner.zip"
            OAuth2Token = $Credential
            ContentType = "application/vnd.github.v3.raw"
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
DownloadGitHubRawContentFromAPI -Credential (Get-Credential) -ConfigurationData $configurationData
Start-DscConfiguration -Wait -Verbose -Force -Path DownloadGitHubRawContentFromAPI