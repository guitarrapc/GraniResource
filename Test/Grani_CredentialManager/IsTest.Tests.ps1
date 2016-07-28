$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_SymbolicLink : Is*" {

    $directory = "d:\hoge"
    $file = "hoge"
    $path = Join-Path $directory $file
    New-Item -Path $path -ItemType File -Force > $null

    Context "IsFile" {

        It "IsFile will null for Directory." {
            IsFile -Path $directory | Should be $null
        }

        It "IsFile will return System.IO.FileInfo for File." {
            (IsFile -Path $path).GetType().FullName | Should be ([System.IO.FileInfo].FullName)
        }
    }

    Context "IsDirectory" {

        It "IsDirectory will null for File." {
            IsDirectory -Path $path | Should be $null
        }

        It "IsDirectory will return System.IO.DirectoryInfo for Directory." {
            (IsDirectory -Path $directory).GetType().FullName | Should be ([System.IO.DirectoryInfo].FullName)
        }
    }
    
    Remove-Item -Path $directory -Force -Recurse > $null
}
