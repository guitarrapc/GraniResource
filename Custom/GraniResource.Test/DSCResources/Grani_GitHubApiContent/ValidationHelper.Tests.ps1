$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_GitHubApiContent : ValidationHelper" {

    $Repository = "DSCResources"
    $RepositoryOwner = "guitarrapc"
    $ContentPath = "README.md"
    $Branch = "master"

    $http = [uri]"http://hogemoge.dummy.com"
    $https = [uri]"https://hogemoge.dummy.com"
    $file = [uri]"file://hogemoge.dummy.com"
    $unc = [uri]"c:\hogemoge.dummy.com"
    $invalid = [uri]"httttp://hogemoge.dummy.com"
    $other = [uri]"//hogemoge.dummy.com"
    
    $path = "d:\hoge\ReadMe.md"
    $parent = Split-Path -Path $path -Parent

    Context "ParseGitHubApiUri test" {
        It "ParseGitHubApiUri should not Throw." {
            {ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository -ContentPath $ContentPath -Branch $Branch } | Should not Throw
        }

        It "ParseGitHubApiUri should return github api url string." {
            ParseGitHubApiUri -RepositoryOwner $RepositoryOwner -Repository $Repository -ContentPath $ContentPath -Branch $Branch | Should be ($script:githubApiString -f $RepositoryOwner, $Repository, $ContentPath, $Branch)
        }
    }

    Context "ValidateUri test" {
        It "https scheme should not be null." {
            ValidateUri -Uri $https | Should Not Be $null
        }

        It "http scheme should be fail." {
            {ValidateUri -Uri $http} | Should Throw
        }

        It "file scheme should be fail." {
            {ValidateUri -Uri $file} | Should Throw
        }

        It "UNC scheme format should be fail." {
            {ValidateUri -Uri $unc} | Should Throw
        }

        It "invalid scheme format should be fail." {
            {ValidateUri -Uri $invalid} | Should Throw
        }

        It "other scheme format should be fail." {
            {ValidateUri -Uri $other} | Should Throw
        }
    }

    Context "ValidateFile test" {
        
        It "Parent Directory Should created when not exists." {
            ValidateFilePath -Path $path
            (Get-Item -Path $parent).GetType().FullName | should be "System.IO.DirectoryInfo"
        }

        It "Nothing should do when File already exist and null return." {
            New-Item -Path $path -ItemType File > $null
            ValidateFilePath -Path $path | should be $null
            Remove-Item -Path $path -Force > $null
        }

        It "Already exist Directory for same name should Throw." {
            New-Item -Path $path -ItemType Directory > $null
            {ValidateFilePath -Path $path} | should Throw
        }

        Remove-Item -Path $parent -Recurse -Force > $null
    }
}
 