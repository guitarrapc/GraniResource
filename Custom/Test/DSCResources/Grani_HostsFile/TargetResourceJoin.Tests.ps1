$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_HostsFile : *-TargetResource" {

    $hostName = "google.com"
    $ipAddress = "8.8.8.8"
    $present = "Present"
    $absent = "Absent"

    Context "Scratch environment. Add HostsEntry " {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present} | should not Throw
        }

        $result = Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be ([EnsureType]::Absent.ToString())
        }

        It "Get-TargetResource should return HostName : $hostName" {
            $result.HostName | should be $hostName
        }

        It "Get-TargetResource should return IpAddress : $ipAddress" {
            $result.IpAddress | should be $ipAddress
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present).Ensure | should be ([EnsureType]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present | should be $true
        }
   }

    Context "Already configured environment. Remove HostEntry " {
        It "Test-TargetResource should return true" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $absent} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $absent).Ensure | should be ([EnsureType]::Absent.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $absent | should be $true
        }
    }
}