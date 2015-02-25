$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Computer : *-TargetResource" {

    $identifier = "hoge"
    $domainName = (Get-Credential).UserName
    $credential = Get-Credential
    $unjoinCredential = Get-Credential

    Context "Already configured environment. UnJoin Domain" {
        It "Test-TargetResource should return true" {
            Test-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential -UnjoinCredential $unjoinCredential} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential).Ensure | should be ([Ensuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential | should be $true
        }
    }

}