$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Download : Invoke-HttpClient" {

    $path = "d:\hoge\ReadMe.md"
    $path2 = "d:\hoge\ReadMe2.md"

    $parent = Split-Path -Path $path -Parent
    $uri = [uri]"https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    $uri2 = [uri]"https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md"
    
    New-Item -Path $parent -ItemType Directory -Force > $null

    Context "Invoke-HttpClient should download stream and version would be same" {

        It "Invoke-HttpClient should download file" {
            Invoke-HttpClient -Uri $uri -Path $path
            (Get-Item -Path $path).GetType().FullName | Should be System.IO.FileInfo
        }

        It "Same Filehash for same uri/version download." {
            Invoke-HttpClient -Uri $uri -Path $path
            Invoke-HttpClient -Uri $uri -Path $path2
            GetFileHash -Path $path | Should be (GetFileHash -Path $path2)
        }

        It "Different Filehash for different uri/version download." {
            Invoke-HttpClient -Uri $uri -Path $path
            Invoke-HttpClient -Uri $uri2 -Path $path2
            GetFileHash -Path $path | Should not be (GetFileHash -Path $path2)
        }
    }

    Remove-Item -Path $path -Force
    Remove-Item -Path $path2 -Force
}
