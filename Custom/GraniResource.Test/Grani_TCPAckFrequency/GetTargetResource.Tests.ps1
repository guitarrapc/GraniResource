$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_TCPAckFrequency : Get-TargetResource" {

    $Enable = $true
    $Disable = $false

    $networkInterfaceEnable = Get-TargetResource -Enable $Enable
    $networkInterfaceDisable = Get-TargetResource -Enable $Disable

    Context "All test must return valid value" {

        It "Get-TargetResource Network Interface should return object for Enable : $Enable" { 
            $networkInterfaceEnable | Should not be $null
        }
        It "Get-TargetResource Network Interface should return object for Enable : $Disable" { 
            $networkInterfaceDisable | Should not be $null
        }
        It "Get-TargetResource Network Interface should contains Enable: $Enable" { 
            $networkInterfaceEnable | %{ $_.Enable -eq $Enable }
        }
        It "Get-TargetResource Network Interface should contains Disable: $Disable" { 
            $networkInterfaceDisable | %{ $_.Enable -eq $Disable }
        }
        It "Get-TargetResource Network Interface should contains Result for Enable test" { 
            $networkInterfaceEnable.Result | Should not be $null
        }
        It "Get-TargetResource Network Interface should contains Result for Disable test" { 
            $networkInterfaceDisable.Result | Should not be $null
        }
        It "Get-TargetResource Network Interface should contains Result should be : $Enable" { 
            $networkInterfaceEnable.Result | Should be $Enable
        }
        It "Get-TargetResource Network Interface should contains Result should be : $Disable" { 
            $networkInterfaceDisable.Result | Should be $Disable
        }
    }
}