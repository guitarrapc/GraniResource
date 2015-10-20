$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_GitHubApiContent : *-TargetResource" {

    $prev = $script:cacheLocation
    $script:cacheLocation = "d:\hoge\cache"

    $path = "d:\hoge\ReadMe.md"
    $parent = Split-Path -Path $path -Parent

    $repository = "DSCResources"
    $repositoryOwner = "guitarrapc"
    $contentPath = "README.md"
    $branch = "master"
    $oAuth2Token = Get-Credential

    $userAgent = "hoge"
    $contentType = "application/vnd.github+json"
    $invalidContentType = "hoge"
    $allowRedirect = $false

    Context "Scratch environment. " {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        $result = Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token -ContentType $contentType -UserAgent $userAgent -AllowRedirect $allowRedirect -CacheLocation $cacheLocation
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be "Absent"
        }

        It "Get-TargetResource should return DestinationPath : $path" {
            $result.DestinationPath | should be $path
        }

        It "Get-TargetResource should return Repository : $repository" {
            $result.Repository | should be $repository
        }

        It "Get-TargetResource should return Repository : $repositoryOwner" {
            $result.RepositoryOwner | should be $repositoryowner
        }

        It "Get-TargetResource should return Uri : $uri" {
            $result.Repository | should be $repository
        }

        It "Get-TargetResource should return ContentPath : $contentPath" {
            $result.ContentPath | should be $contentPath
        }

        It "Get-TargetResource should return Branch : $branch" {
            $result.Branch | should be $branch
        }

        It "Get-TargetResource should return ContentType : $contentType" {
            $result.ContentType | should be $contentType
        }

        It "Get-TargetResource should return UserAgent : $userAgent" {
            $result.UserAgent | should be $userAgent
        }

        It "Get-TargetResource should return AllowRedirect : $allowRedirect" {
            $result.AllowRedirect | should be $allowRedirect
        }

        It "Get-TargetResource should return CacheLocation : $cacheLocation" {
            $result.CacheLocation | should be $script:cacheLocation
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $true
        }
    }

    Context "Already configured environment. Same Uri / same file update." {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $true
        }
    }

    Context "Already configured environment. Same Uri / same file update. Added UserAgent." {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $true
        }
    }

    Context "Already configured environment. Same Uri / same file update. Added ContentType." {
        It "Set-TargetResource should Throw with invalid ContentType" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token -ContentType $invalidContentType} | should Throw
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $true
        }
    }

    Context "Already configured but delete file environment, Same Uri / same file update." {
        Remove-Item -Path $path -Force

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Absent"
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $true
        }
    }

    Context "Exist same name Folder environment." {
        Remove-Item -Path $path -Force
        New-Item -Path $path -ItemType Directory > $null

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token).Ensure | should be "Absent"
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token | should be $false
        }

        It "Set-TargetResource should Throw" {
            {Set-TargetResource -DestinationPath $path -Repository $Repository -RepositoryOwner $RepositoryOwner -ContentPath $ContentPath -Branch $Branch -OAuth2Token $OAuth2Token} | should Throw
        }

        Remove-Item -Path $path -Force -Recurse
    }

    Remove-Item -Path $script:cacheLocation -Force -Recurse
    Remove-Item -Path $parent -Recurse -Force

    $script:cacheLocation = $prev
}