$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Download : CacheHelper" {

    # swap cache control path for test
    $prev = $script:cacheLocation
    $script:cacheLocation = "d:\hoge\cache"

    $path = "d:\hoge\ReadMe.md"
    $uri = [uri]"https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    
    Remove-Item -Path $script:cacheLocation -Force -Recurse

    Context "CacheLocation should swap for test" {
        It "cacheLocation should swapped." {
            $script:cacheLocation | Should Not Be $prev
        }
    }

    Context "GetFileHash should return hash string" {

        New-Item -Path $path -ItemType File > $null

        It "GetFileHash should not BeNullOrEmpty" {
            GetFileHash -Path $path | Should Not BeNullOrEmpty
        }

        It "GetFileHash should be SHA256 hash string." {
            GetFileHash -Path $path | Should be (Get-FileHash -Path $path -Algorithm SHA256).Hash
        }

        It "GetFileHash should not be MD5 hash string." {
            GetFileHash -Path $path | Should not be (Get-FileHash -Path $path -Algorithm MD5).Hash
        }

        Remove-Item -Path $path -Force > $null
    }

    Invoke-HttpClient -Uri $uri -Path $path
    $fileHash = GetFileHash -Path $path

    Context "NewXmlObject" {
        It "NewXmlObject is not null." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Should not be $null
        }

        It "NewXmlObject contains FileHash Property." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Get-Member -MemberType Properties -Name FileHash | Should not be $null
        }

        It "NewXmlObject contains WriteTime Property." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Get-Member -MemberType Properties -Name WriteTime | Should not be $null
        }

        It "NewXmlObject contains Path Property." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Get-Member -MemberType Properties -Name Path | Should not be $null
        }

        It "NewXmlObject contains Uri Property." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Get-Member -MemberType Properties -Name Uri | Should not be $null
        }

        It "NewXmlObject FileHash is not Null." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Select -ExpandProperty FileHash | Should not be $null
        }

        It "NewXmlObject WriteTime is not Null." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Select -ExpandProperty WriteTime | Should not be $null
        }

        It "NewXmlObject Path is not Null." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Select -ExpandProperty Path | Should not be $null
        }

        It "NewXmlObject Uri is not Null." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Select -ExpandProperty Uri | Should not be $null
        }

        It "NewXmlObject FileHash is same as filehash passed." {
            NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash | Select -ExpandProperty FileHash | Should be $fileHash
        }
    }

    Context "UpdateCache" {
        It "UpdateCache create cache file." {
            UpdateCache -DestinationPath $path -Uri $uri
            Get-ChildItem -Path $script:cacheLocation -File | Measure-Object | Select -ExcludeProperty Count | Should not be 0
        }

        It "UpdateCache cache file name Is created by GetCacheKey." {
            UpdateCache -DestinationPath $path -Uri $uri
            Get-ChildItem -Path $script:cacheLocation -File | Select -ExpandProperty Name | Should be (GetCacheKey -DestinationPath $path -Uri $uri)
        }
    }

    Context "GetCache" {
        It "GetCache Should return Empty when cache is not exist." {
            Remove-Item -Path $script:cacheLocation -Force -Recurse
            GetCache -DestinationPath $path -Uri $uri | Should be ([string]::Empty)
        }

        It "GetCache Should get same cache as updated." {
            UpdateCache -DestinationPath $path -Uri $uri
            $obj = NewXmlObject -DestinationPath $path -Uri $Uri -FileHash $fileHash
            GetCache -DestinationPath $path -Uri $uri | Should be ($obj.FileHash)
        }
    }

    Remove-Item -Path $path -Force
    $script:cacheLocation = $prev
}
