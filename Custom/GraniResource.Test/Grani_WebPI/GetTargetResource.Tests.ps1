$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_WebPI : Get-TargetResource" {

    $availableName = "WordPress"
    $installedName = "PowerShell4"

    $available = Get-WebPlatformInstallerProduct -Available
    $install = Get-WebPlatformInstallerProduct -Installed

    $GetTargetResourceInstall = Get-TargetResource -Name $installedName
    $GetTargetResourceAvailable = Get-TargetResource -Name $availableName

    Context "All test must return valid value" {

        It "Available Package List should return object" { 
            $available | Should not be $null
        }
        It "Available Package should return Package '$availableName'" {
            $available | where ProductId -eq $availableName | select -ExpandProperty ProductId | Should be $availableName
        }
        It "Installed Package List should return object" { 
            $install | Should not be $null
        }
        It "Installed Package should return Package '$installedName'" {
            $install | where ProductId -eq $installedName | select -ExpandProperty ProductId | Should be $installedName
        }
        It "Get-TargetResource should not return null" {
            $GetTargetResourceInstall | Should not be $null
        }
        It "Get-TargetResource should return Package '$installedName'" {
            $GetTargetResourceInstall.GetEnumerator() | where Value -eq $installedName | Select -ExpandProperty Value | Should be $installedName
        }
    }

    Context "All test should return null" {

        It "Available Package '$availableName' should not return from Installed Package" {
            $install | where ProductId -eq $availableName | Should be $null
        }
        It "Installed Package '$installedName' should not return from available Package" {
            $available | where ProductId -eq $installedName | Should be $null
        }
        It "Get-TargetResource should not return Package '$availableName'" {
            $GetTargetResourceAvailable | Where Value -eq $availableName | Should be $null
        }
    }
}
