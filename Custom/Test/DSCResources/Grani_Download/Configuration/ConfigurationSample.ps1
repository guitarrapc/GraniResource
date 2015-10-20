configuration DownloadGitHubRawContent
{
    Import-DscResource -ModuleName GraniResource
    cDownload hoge
    {
        DestinationPath = "C:\Tools\README.md"
        Uri = "https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md"
    }
}

DownloadGitHubRawContent
Start-DscConfiguration -Wait -Verbose -Force -Path DownloadGitHubRawContent