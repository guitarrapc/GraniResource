$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Download : GetPathItemType" {

    $pathF = "d:\hoge\ReadMe.md"
    $pathD = "d:\hoge\ReadMe"

    New-Item -Path $pathF -ItemType File -Force > $null
    New-Item -Path $pathD -ItemType Directory -Force > $null

    Context "GetPathItemType should get ItemType" {

        It "Get-Item Type check should return System.IO.FileInfo" {
            (Get-Item -Path $pathF).GetType().FullName | Should be "System.IO.FileInfo"
        }

        It "Get-Item Type check should return System.IO.DirectoryInfo" {
            (Get-Item -Path $pathD).GetType().FullName | Should be "System.IO.DirectoryInfo"
        }

        It "GetPathItemType should return FileInfo" {
            GetPathItemType -Path $pathF | Should be "FileInfo"
        }

        It "GetPathItemType should return DirectoryInfo" {
            GetPathItemType -Path $pathD | Should be "DirectoryInfo"
        }

        It "Pipeline passing File Item to GetPathItemType should return FileInfo" {
            Get-ChildItem -Path $pathF -File | GetPathItemType | Should be "FileInfo"
        }

        It "Pipeline passing Directory Item to GetPathItemType should return DirectoryInfo" {
            Get-Item -Path $pathD | GetPathItemType | Should be "DirectoryInfo"
        }
    }

    Remove-Item -Path $pathF -Force > $null
    Remove-Item -Path $pathD -Force > $null
}
