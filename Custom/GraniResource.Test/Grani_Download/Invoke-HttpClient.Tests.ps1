$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Download : Invoke-HttpClient" {

    $path = "d:\hoge\ReadMe.md"
    $path2 = "d:\hoge\ReadMe2.md"
    $path3 = "d:\hoge\ReadMe3.md"

    $parent = Split-Path -Path $path -Parent

    $uri = [uri]"https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    $uri2 = [uri]"https://raw.githubusercontent.com/guitarrapc/DSCResources/master/README.md"
    [uri]$invalidUri = [uri]"https://invalid.address.google.contosocom"
    
    New-Item -Path $parent -ItemType Directory -Force > $null

    Context "Invoke-HttpClient success/failure test" {
        It "Invoke-HttpClient should Throw for invalid Uri download" {
            {Invoke-HttpClient -Uri $invalidUri -Path $path} | Should Throw
        }

        It "Invoke-HttpClient should not Throw." {
            {
                Invoke-HttpClient -Uri $uri -Path $path;
                Invoke-HttpClient -Uri $uri2 -Path $path3;
            } | Should Not Throw
        }
    }

    Context "Invoke-HttpClient should download stream and save file test" {

        It "Invoke-HttpClient should download file" {
            (Get-Item -Path $path).GetType().FullName | Should be System.IO.FileInfo
            (Get-Item -Path $path3).GetType().FullName | Should be System.IO.FileInfo
        }

        It "Copy Downloaded content should not throw." {
            {
                Get-Item -Path $path;
                Copy-Item -Path $path -Destination $path2
            } | Should not Throw
        }

    }

    Context "Invoke-HttpClient downloaded file test" {
        It "Same Filehash for same uri/version download." {
            GetFileHash -Path $path | Should be (GetFileHash -Path $path2)
        }

        It "Different Filehash for different uri/version download." {
            GetFileHash -Path $path | Should not be (GetFileHash -Path $path3)
        }
    }

    Remove-Item -Path $path -Force
    Remove-Item -Path $path2 -Force
}
