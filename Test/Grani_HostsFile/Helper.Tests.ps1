#Requires –RunAsAdministrator

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_HostsFile : Helper" {

    $hostName = "google.com"
    $ipAddress = "8.8.8.8"
    $newIPAddress = "129.250.35.250"
    $referenceStatic = [ReferenceType]::StaticIp
    $referenceDnsServer = [ReferenceType]::DnsServer

    Context "ResolveIpAddressReference with StaticIp should not throw" {
        It "ResolveIpAddressReference with StaticIpAddress should not throw" {
            {ResolveIpAddressReference -IpAddress $ipAddress -HostName $hostName -Reference $referenceStatic} | should not Throw
        }

        It "ResolveIpAddressReference with DnsServer should not throw" {
            {ResolveIpAddressReference -IpAddress $ipAddress -HostName $hostName -Reference $referenceDnsServer} | should not Throw
        }
    }

    $staticIpEntry = ResolveIpAddressReference -IpAddress $ipAddress -HostName $hostName -Reference $referenceStatic
    $dnsIpEntry = ResolveIpAddressReference -IpAddress $ipAddress -HostName $hostName -Reference $referenceDnsServer

    Context "TestIsHostEntryExists. Scratch environment. Add HostsEntry with StaticIp" {
        It "Add host Entry by Add-Content should not throw" {
            {Add-Content -Path $script:hostsLocation "$staticIpEntry`t$hostName" -Encoding Ascii} | should not Throw
        }

        It "Test host Entry should be true for valid ipaddress/hostname" {
            TestIsHostEntryExists -IpAddress $staticIpEntry -HostName $hostName | should be $true
        }

        It "Test host Entry should be false for invalid ipaddress/hostname" {
            TestIsHostEntryExists -IpAddress $newIPAddress -HostName $hostName | should be $false
        }

        It "Remove host Entry should not throw" {
            {((Get-Content $script:hostsLocation) -notmatch "^\s*$") -notmatch "^[^#]*$staticIpEntry\s+$hostName" | Set-Content -Path $script:hostsLocation -Force -Encoding $script:encoding;} | should not Throw
        }

        It "Test host Entry should be false for already removed ipaddress/hostname" {
            TestIsHostEntryExists -IpAddress $staticIpEntry -HostName $hostName | should be $false
        }
   }

    Context "TestIsHostEntryExists. Scratch environment. Add HostsEntry with DnsServer" {
        It "Add host Entry by Add-Content should not throw" {
            {Add-Content -Path $script:hostsLocation "$dnsIpEntry`t$hostName" -Encoding Ascii} | should not Throw
        }

        It "Test host Entry should be true for valid ipaddress/hostname" {
            TestIsHostEntryExists -IpAddress $dnsIpEntry -HostName $hostName | should be $true
        }

        It "Test host Entry should be false for invalid ipaddress/hostname" {
            TestIsHostEntryExists -IpAddress $newIPAddress -HostName $hostName | should be $false
        }

        It "Remove host Entry should not throw" {
            {((Get-Content $script:hostsLocation) -notmatch "^\s*$") -notmatch "^[^#]*$dnsIpEntry\s+$hostName" | Set-Content -Path $script:hostsLocation -Force -Encoding $script:encoding;} | should not Throw
        }

        It "Test host Entry should be false for already removed ipaddress/hostname" {
            TestIsHostEntryExists -IpAddress $dnsIpEntry -HostName $hostName | should be $false
        }
   }
}