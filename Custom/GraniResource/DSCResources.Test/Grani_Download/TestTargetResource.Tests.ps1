$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test-TargetResource" {

    $destinationPath = "d:\hoge\ReadMe.md"
    $uri = "https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"

    # Test-TargetResource -DestinationPath $destinationPath -Uri $uri    

    Context "Test-TargetResource should return boolean" {
    }
}
