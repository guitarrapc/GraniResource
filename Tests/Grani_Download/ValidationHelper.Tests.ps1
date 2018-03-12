$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_Download : ValidationHelper" {

    $http = [uri]"http://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    $https = [uri]"https://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    $file = [uri]"file://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    $unc = [uri]"c:\raw.githubusercontent.com\guitarrapc\WindowsCredentialVault\master\README.md"
    $invalid = [uri]"httttp://raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    $other = [uri]"//raw.githubusercontent.com/guitarrapc/WindowsCredentialVault/master/README.md"
    
    $path = "d:\hoge\ReadMe.md"
    $parent = Split-Path -Path $path -Parent

    Context "ValidateUri test" {
        It "http scheme should not be null." {
            ValidateUri -Uri $http | Should Not Be $null
        }

        It "https scheme should not be null." {
            ValidateUri -Uri $https | Should Not Be $null
        }

        It "file scheme should not be null." {
            ValidateUri -Uri $file | Should Not Be $null
        }

        It "UNC scheme format should be fail." {
            {ValidateUri -Uri $unc} | Should Not Be $null
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
 