$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Computer : *-TargetResource" {

    $identifier = "hoge"
    $domainName = (Get-Credential).UserName
    $credential = Get-Credential

    Context "Scratch environment. Join Domain" {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential} | should not Throw
        }

        $result = Get-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be ([Ensuretype]::Absent.ToString())
        }

        It "Get-TargetResource should return Identifier : $identifier" {
            $result.Identifier | should be $identifier
        }

        It "Get-TargetResource should return DomainName : $domainName" {
            $result.DomainName | should be $domainName
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential).Ensure | should be ([Ensuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential | should be $true
        }
    }
}