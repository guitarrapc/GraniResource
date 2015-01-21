$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_WebPI : Test-TargetResource" {

    $availableName = "WordPress"
    $installedName = "PowerShell4"

    $TestTargetResourceInstall = Test-TargetResource -Name $installedName
    $TestTargetResourceAvailable = Test-TargetResource -Name $availableName

    Context "Test-TargetResource should return boolean" {

        It "Test-TargetResource should return $true with '$installedName'" {
            $TestTargetResourceInstall | Should be $true
        }

        It "Test-TargetResource should return $false with '$availableName'" {
            $TestTargetResourceAvailable | Should be $false
        }
    }
}
