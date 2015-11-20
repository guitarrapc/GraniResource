configuration Present
{
    $uri46 = "http://go.microsoft.com/fwlink/?LinkId=528222";
    $folder = "c:\Test";
    $path = Join-Path $folder "NDP46-KB3045560-Web.exe";

    Import-DscResource -ModuleName GraniResource

    cDownload hoge
    {
        Uri = $uri46
        DestinationPath = $path
    }

    cDotNetFramework hoge
    {
        KB = "KB3045563"
        InstallerPath = $path
        Ensure = "Present"
        NoRestart = $true
        LogPath = "C:\Test\Present.log"
        DependsOn = "[cDownload]hoge"
    }    
}

Present
Start-DscConfiguration -Force -Wait -Path Present -Verbose
Get-DscConfiguration
Test-DscConfiguration