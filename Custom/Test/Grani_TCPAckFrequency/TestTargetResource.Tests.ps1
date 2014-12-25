$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test-TargetResource" {

    $Enable = $true
    $Disable = $false

    $testEnable = Test-TargetResource -Enable $Enable
    $testDisable = Test-TargetResource -Enable $Disable

    Context "Test-TargetResource should return boolean" {

	    It "Test-TargetResource should return $true for Enable : '$Enable'" {
    	    $testEnable | Should be $true
	    }

	    It "Test-TargetResource should return $false for Enable : '$Disable'" {
    	    $testDisable | Should be $false
	    }
    }
}
