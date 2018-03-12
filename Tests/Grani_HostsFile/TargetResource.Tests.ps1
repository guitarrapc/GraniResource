$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_HostsFile : *-TargetResource" {

    $hostName = "google.com"
    $ipAddress = "8.8.8.8"
    $alterIpAddress = "8.8.4.4"
    $newIPAddress = "129.250.35.250"
    $present = "Present"
    $absent = "Absent"
    $referenceStatic = [ReferenceType]::StaticIp
    $referenceDnsServer = [ReferenceType]::DnsServer

    Context "Scratch environment. Add HostsEntry for StaticIp" {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceStatic} | should not Throw
        }

        $result = Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceStatic
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be ([EnsureType]::Absent.ToString())
        }

        It "Get-TargetResource should return HostName : $hostName" {
            $result.HostName | should be $hostName
        }

        It "Get-TargetResource should return IpAddress : $ipAddress" {
            $result.IpAddress | should be $ipAddress
        }

        It "Get-TargetResource should return Reference : $referenceStatic" {
            $result.Reference | should be $referenceStatic
        }

        It "Test-TargetResource should return false : present" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceStatic | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceStatic} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceStatic).Ensure | should be ([EnsureType]::Present.ToString())
        }

        It "Test-TargetResource should return true : present" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceStatic | should be $true
        }
   }

    Context "Already configured environment. Enter different IP with same HostEntry for StaticIp" {
        It "Test-TargetResource should return true for not exist ip: absent" {
            Test-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceStatic | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $present -Reference $referenceStatic} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $present -Reference $referenceStatic).Ensure | should be ([EnsureType]::Present.ToString())
        }

        It "Test-TargetResource should return true : present" {
            Test-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $present -Reference $referenceStatic | should be $true
        }
    }

    Context "Already configured environment. Remove HostEntry for StaticIp" {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceStatic} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceStatic).Ensure | should be ([EnsureType]::Absent.ToString())
        }

        It "Test-TargetResource should return true : absent" {
            Test-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceStatic | should be $true
        }
    }


    Context "Scratch environment. Add HostsEntry for DnsServer" {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceDnsServer} | should not Throw
        }

        $result = Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceDnsServer
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be ([EnsureType]::Absent.ToString())
        }

        It "Get-TargetResource should return HostName : $hostName" {
            $result.HostName | should be $hostName
        }

        It "Get-TargetResource should return IpAddress : $ipAddress" {
            $result.IpAddress | should be $ipAddress
        }

        It "Get-TargetResource should return Reference : $referenceDnsServer" {
            $result.Reference | should be $referenceDnsServer
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceDnsServer | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceDnsServer} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceDnsServer).Ensure | should be ([EnsureType]::Present.ToString())
        }

        It "Test-TargetResource should return true : present" {
            Test-TargetResource -HostName $hostName -IpAddress $ipAddress -Ensure $present -Reference $referenceDnsServer | should be $true
        }
   }

    Context "Already configured environment. Enter Alter IP with same HostEntry for DnsServer" {
        It "Test-TargetResource should return true for alter dns ip: absent" {
            Test-TargetResource -HostName $hostName -IpAddress $alterIPAddress -Ensure $present -Reference $referenceDnsServer | should be $true
        }
    }

    Context "Already configured environment. Enter different IP with same HostEntry for DnsServer" {
        It "Test-TargetResource should return true for not exist ip: absent" {
            Test-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceDnsServer | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $present -Reference $referenceDnsServer} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $present -Reference $referenceDnsServer).Ensure | should be ([EnsureType]::Present.ToString())
        }

        It "Test-TargetResource should return true : present" {
            Test-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $present -Reference $referenceDnsServer | should be $true
        }
    }

    Context "Already configured environment. Remove HostEntry for DnsServer" {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceDnsServer} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceDnsServer).Ensure | should be ([EnsureType]::Absent.ToString())
        }

        It "Test-TargetResource should return true : absent" {
            Test-TargetResource -HostName $hostName -IpAddress $newIPAddress -Ensure $absent -Reference $referenceDnsServer | should be $true
        }
    }

}