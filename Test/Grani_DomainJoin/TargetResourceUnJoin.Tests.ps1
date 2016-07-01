$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Computer : *-TargetResource" {

    $identifier = "hoge"
    $domainName = (Get-Credential).UserName
    $credential = Get-Credential
    $workGroup = "WORKGROUP"

    Context "Already configured environment. UnJoin Domain" {
        It "Test-TargetResource should return true" {
            Test-TargetResource -Identifier $identifier -DomainName $domainName -Credential $credential | should be $true
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Identifier $identifier -WorkGroup $workGroup -Credential $credential} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -Identifier $identifier -WorkGroup $workGroup -Credential $credential).Ensure | should be ([Ensuretype]::Present.ToString())
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Identifier $identifier -WorkGroupName $workGroup -Credential $credential | should be $true
        }
    }

}