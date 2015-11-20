$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_DotNetFramework : TargetResource" {

    $KB = "KB3045563";
    $present = "present";
    $absent = "absent";
    $uri46 = "http://go.microsoft.com/fwlink/?LinkId=528222";
    $folder = "c:\Tools";
    $path = Join-Path $folder "NDP46-KB3045560-Web.exe";
    $noRestart = $true;
    $restart = $false;
    $logPath = "$env:Temp\hoge.log";

    if (-not (Test-Path $path))
    {
        New-Item -Path $folder -ItemType Directory -Force;
        Invoke-WebRequest -Method Get -Uri $uri46 -OutFile $path;
    }

    Context "Scratch environment without RC46 exist." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -KB $KB -Ensure $present -InstallerPath $path} | Should not Throw
        }

        $get = Get-TargetResource -KB $KB -Ensure $present -InstallerPath $path -NoRestart $noRestart -LogPath $logPath;
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return KB : $KB" {
            $get.KB | Should be $KB
        }

        It "Get-TargetResource should return InstallerPath : $Path" {
            $get.InstallerPath | Should be $Path
        }

        It "Get-TargetResource should return NoRestart : $noRestart" {
            $get.NoRestart | Should be $noRestart
        }

        It "Get-TargetResource should return LogPath : $logPath" {
            $get.LogPath | Should be $logPath
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -KB $KB -Ensure $present -InstallerPath $path -NoRestart $noRestart -LogPath $logPath | should be $false
        }

        It "Test-TargetResource Absent should return true" {
           Test-TargetResource -KB $KB -Ensure $absent -InstallerPath $path -NoRestart $noRestart -LogPath $logPath | should be $true
        }

        It "Set-TargetResource Present should not Throw as Ensure : $present" {
            {Set-TargetResource -KB $KB -Ensure $present -InstallerPath $path -NoRestart $noRestart -LogPath $logPath} | should not Throw
        }
    }

    Context "Already Configured Environment should skip." {
        It "Set-TargetResource $present should not Throw" {
            {Set-TargetResource -KB $KB -Ensure $present -InstallerPath $path -NoRestart $noRestart -LogPath $logPath} | should not Throw
        }
        
        It "Test-TargetResource Present should return true" {
           Test-TargetResource -KB $KB -Ensure $present -InstallerPath $path -NoRestart $noRestart -LogPath $logPath | should be $true
        }

        It "Test-TargetResource Absent should return false" {
            Test-TargetResource -KB $KB -Ensure $absent -InstallerPath $path -NoRestart $noRestart -LogPath $logPath | should be $false
        }
    }

    Context "Remove Configured settings." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -KB $KB -Ensure $absent -InstallerPath $path -NoRestart $noRestart -LogPath $logPath} | should not Throw        }
        
        It "Test-TargetResource Present should return false" {
           Test-TargetResource -KB $KB -Ensure $present -InstallerPath $path -NoRestart $noRestart -LogPath $logPath | should be $false
        }

        It "Test-TargetResource Absent should return true" {
           Test-TargetResource -KB $KB -Ensure $absent -InstallerPath $path -NoRestart $noRestart -LogPath $logPath | should be $true
        }
    }
}