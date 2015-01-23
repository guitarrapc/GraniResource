$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Download : *-TargetResource" {

    $prev = $script:cacheLocation
    $script:cacheLocation = "d:\hoge\cache"

    $path = "d:\hoge\ReadMe.md"
    $parent = Split-Path -Path $path -Parent
    $uri = [uri]"https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"

    $userAgent = "hoge"
    $contentType = "application/vnd.github+json"
    $invalidContentType = "hoge"
    $allowRedirect = $false
    $userAgent = "hoge"

    Context "Scratch environment. " {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Uri $uri -DestinationPath $path} | should not Throw
        }

        $result = Get-TargetResource -Uri $uri -DestinationPath $path -ContentType $contentType -UserAgent $userAgent -AllowRedirect $allowRedirect -CacheLocation $cacheLocation
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be "Absent"
        }

        It "Get-TargetResource should return DestinationPath : $path" {
            $result.DestinationPath | should be $path
        }

        It "Get-TargetResource should return Uri : $uri" {
            $result.Uri | should be $uri
        }

        It "Get-TargetResource should return ContentType : $contentType" {
            $result.ContentType | should be $contentType
        }

        It "Get-TargetResource should return UserAgent" {
            $result.UserAgent | should be $userAgent
        }

        It "Get-TargetResource should return AllowRedirect : $allowRedirect" {
            $result.AllowRedirect | should be $allowRedirect
        }

        It "Get-TargetResource should return CacheLocation : $cacheLocation" {
            $result.CacheLocation | should be $script:cacheLocation
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -Uri $uri -DestinationPath $path | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Uri $uri -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Uri $uri -DestinationPath $path).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Uri $uri -DestinationPath $path | should be $true
        }
    }

    Context "Already configured environment. Same Uri / same file update." {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Uri $uri -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Uri $uri -DestinationPath $path).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Uri $uri -DestinationPath $path | should be $true
        }
    }

    Context "Already configured environment. Same Uri / same file update. Added UserAgent." {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Uri $uri -DestinationPath $path -UserAgent $userAgent} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Uri $uri -DestinationPath $path -UserAgent $userAgent).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Uri $uri -DestinationPath $path -UserAgent $userAgent | should be $true
        }
    }

    Context "Already configured environment. Same Uri / same file update. Added ContentType." {
        It "Set-TargetResource should Throw with invalid ContentType" {
            {Set-TargetResource -Uri $uri -DestinationPath $path -ContentType $invalidContentType} | should Throw
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Uri $uri -DestinationPath $path -ContentType $contentType} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Uri $uri -DestinationPath $path -ContentType $contentType).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Uri $uri -DestinationPath $path -ContentType $contentType | should be $true
        }
    }

    Context "Already configured but delete file environment, Same Uri / same file update." {
        Remove-Item -Path $path -Force

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Uri $uri -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -Uri $uri -DestinationPath $path).Ensure | should be "Absent"
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -Uri $uri -DestinationPath $path | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Uri $uri -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Uri $uri -DestinationPath $path).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Uri $uri -DestinationPath $path | should be $true
        }
    }

    Context "Exist same name Folder environment." {
        Remove-Item -Path $path -Force
        New-Item -Path $path -ItemType Directory > $null

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Uri $uri -DestinationPath $path} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -Uri $uri -DestinationPath $path).Ensure | should be "Absent"
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -Uri $uri -DestinationPath $path | should be $false
        }

        It "Set-TargetResource should Throw" {
            {Set-TargetResource -Uri $uri -DestinationPath $path} | should Throw
        }

        Remove-Item -Path $path -Force -Recurse
    }

    Remove-Item -Path $script:cacheLocation -Force -Recurse
    Remove-Item -Path $parent -Recurse -Force

    $script:cacheLocation = $prev
}
