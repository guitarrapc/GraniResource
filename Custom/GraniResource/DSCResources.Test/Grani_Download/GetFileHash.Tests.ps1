$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "GetPathItemType" {

    $path = "d:\hoge\ReadMe.md"

    Context "GetPathItemType should return hash string" {

        It "GetFileHash should not BeNullOrEmpty" {
            New-Item -Path $Path -ItemType File -Force > $null
            GetFileHash -Path $path | Should Not BeNullOrEmpty
            Remove-Item -Path $Path -Force
        }
    }
}
