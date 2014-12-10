$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Set-TargetResource" {

    $availableName = "ARRv3_0"
    Context "Should install complete." {
	    It "Set-TargetResource should success as package '$availableName' is valid" {
    	    {Set-TargetResource -Name $availableName} | Should not Throw
	    }
    }
}
