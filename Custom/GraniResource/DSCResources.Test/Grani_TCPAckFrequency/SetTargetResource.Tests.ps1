$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_TCPAckFrequency : Set-TargetResource" {

    $Enable = $true
    $Disable = $false
    Context "Should install complete." {
        It "Set-TargetResource should success as Enale : '$Enable'" {
            {Set-TargetResource -Enable $Enable} | Should not Throw
        }

        It "Set-TargetResource should success as Enale : '$Disable'" {
            {Set-TargetResource -Enable $Disable} | Should not Throw
        }
    }
}
