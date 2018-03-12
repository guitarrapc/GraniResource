$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_GitHubApiContent : Invoke-HttpClient" {

    $path = "d:\hoge\ReadMe.md"
    $path2 = "d:\hoge\ReadMe2.md"
    $path3 = "d:\hoge\ReadMe3.md"
    $path4 = "d:\hoge\xDSCResourceDesignerRaw.zip"
    $path5 = "d:\hoge\xDSCResourceDesignerRaw2.zip"
    $path6 = "d:\hoge\xDSCResourceDesignerJson.zip"

    $parent = Split-Path -Path $path -Parent

    $Repository = "DSCResources"
    $Repository2 = "valentia"
    $RepositoryOwner = "guitarrapc"
    $ContentPath = "README.md"
    $ContentPathRaw = "MicrosoftScriptCenter/xDSCResourceDesigner.zip"
    $Branch = "master"
    $BranchNotExist = "NotExist"
    $OAuth2Token = Get-Credential
    $ContentType = "application/vnd.github.v3.raw"

    [uri]$uri = ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository -ContentPath $ContentPath -Branch $Branch
    [uri]$uri2 = ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository2 -ContentPath $ContentPath -Branch $Branch
    [uri]$uri3 = ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository -ContentPath $ContentPathRaw -Branch $Branch
    [uri]$invalidUri = ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository -ContentPath $ContentPath -Branch $BranchNotExist
    
    New-Item -Path $parent -ItemType Directory -Force > $null

    Context "Invoke-HttpClient failure test" {
        It "Invoke-HttpClient should Throw from invalid Uri download" {
            {Invoke-HttpClient -Uri $invalidUri -Path $path -OAuth2Token $OAuth2Token} | Should Throw
        }

        It "Invoke-HttpClient should Throw when no User-Agent" {
            {Invoke-HttpClient -Uri $invalidUri -Path $path -UserAgent "" -OAuth2Token $OAuth2Token} | Should Throw
        }
    }

    Context "Invoke-HttpClient should download content as json" {
        It "Invoke-HttpClient should not Throw." {
            {
                Invoke-HttpClient -Uri $uri -Path $path -OAuth2Token $OAuth2Token;
                Invoke-HttpClient -Uri $uri -Path $path2 -OAuth2Token $OAuth2Token;
                Invoke-HttpClient -Uri $uri2 -Path $path3 -OAuth2Token $OAuth2Token;
            } | Should Not Throw
        }

        It "Invoke-HttpClient should download file" {
            (Get-Item -Path $path).GetType().FullName | Should be System.IO.FileInfo
            (Get-Item -Path $path2).GetType().FullName | Should be System.IO.FileInfo
            (Get-Item -Path $path3).GetType().FullName | Should be System.IO.FileInfo
        }
    }

    Context "Invoke-HttpClient version would be same for json" {
        It "Same Filehash for same uri/version download." {
            GetFileHash -Path $path | Should be (GetFileHash -Path $path2)
        }

        It "Different Filehash for different uri/version download." {
            GetFileHash -Path $path | Should not be (GetFileHash -Path $path3)
        }
    }

    Context "Invoke-HttpClient should download content as raw" {
        It "Invoke-HttpClient should not Throw." {
            {
                Invoke-HttpClient -Uri $uri3 -Path $path4 -OAuth2Token $OAuth2Token -ContentType $ContentType;
                Invoke-HttpClient -Uri $uri3 -Path $path5 -OAuth2Token $OAuth2Token -ContentType $ContentType;
                Invoke-HttpClient -Uri $uri3 -Path $path6 -OAuth2Token $OAuth2Token;
            } | Should Not Throw
        }

        It "Invoke-HttpClient should download file" {
            (Get-Item -Path $path4).GetType().FullName | Should be System.IO.FileInfo
            (Get-Item -Path $path5).GetType().FullName | Should be System.IO.FileInfo
            (Get-Item -Path $path6).GetType().FullName | Should be System.IO.FileInfo
        }
    }

    Context "Invoke-HttpClient version would be same" {
        It "Same Filehash for same uri/version download." {
            GetFileHash -Path $path5 | Should not be (GetFileHash -Path $path6)
        }

        It "Different Filehash for different uri/version download." {
            GetFileHash -Path $path4 | Should not be (GetFileHash -Path $path6)
        }
    }

    Remove-Item -Path $parent -Force -Recurse
}
