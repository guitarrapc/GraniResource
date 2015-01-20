$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "GetPathItemType" {

    $path = "d:\hoge\ReadMe.md"
    $uri = "https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"

    $path2 = "d:\hoge\ReadMe2.md"
    $uri2 = "https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README2.md"

    Context "GetCacheKey should return hash string from FileName and Url" {

        It "GetCacheKey should not BeNullOrEmpty" {
            New-Item -Path $path -ItemType File -Force > $null
            GetCacheKey -DestinationPath $path -Uri $Uri | Should not BeNullOrEmpty
            Remove-Item -Path $path -Force
        }

        It "GetCacheKey should Match for same file, uri." {
            New-Item -Path $path -ItemType File -Force > $null
            New-Item -Path $path2 -ItemType File -Force > $null
            1..100 | Get-Random -Count 10 | Out-File -FilePath $path
            1..100 | Get-Random -Count 10 | Out-File -FilePath $path2
            GetCacheKey -DestinationPath $path -Uri $Uri | Should Match (GetCacheKey -DestinationPath $path -Uri $Uri)
        }

        It "GetCacheKey should not Match for random file." {
            GetCacheKey -DestinationPath $path -Uri $Uri | Should not Match (GetCacheKey -DestinationPath $path2 -Uri $Uri)
        }

        It "GetCacheKey should not Match for random uri." {
            GetCacheKey -DestinationPath $path -Uri $Uri | Should not Match (GetCacheKey -DestinationPath $path -Uri $Uri2)
        }

        It "GetCacheKey should not Match for random file and uri." {
            GetCacheKey -DestinationPath $path -Uri $Uri | Should not Match (GetCacheKey -DestinationPath $path2 -Uri $Uri2)
            Remove-Item -Path $path -Force
            Remove-Item -Path $path2 -Force
        }
    }
}
