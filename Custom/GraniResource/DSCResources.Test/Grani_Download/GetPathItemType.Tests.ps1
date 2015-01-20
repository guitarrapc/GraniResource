$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "GetPathItemType" {

    $path = "d:\hoge\ReadMe.md"

    Context "GetPathItemType should get ItemType" {

        It "GetPathItemType should return FileInfo" {
            New-Item -Path $Path -ItemType File -Force > $null
            GetPathItemType -Path $path | Should be "FileInfo"
            Remove-Item -Path $Path -Force > $null
        }

        It "GetPathItemType should return DirectoryInfo" {
            New-Item -Path $Path -ItemType Directory -Force > $null
            GetPathItemType -Path $path | Should be "DirectoryInfo"
            Remove-Item -Path $Path -Force > $null
        }
    }
}
