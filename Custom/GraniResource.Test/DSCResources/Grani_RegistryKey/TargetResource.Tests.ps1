$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_TopShelf : TargetResource" {

    $Key = "HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
    $key2 = "HKLM:\SOFTWARE\hoge/piyo\fuga/nyao"
    $invalidKey = "H_CU\SOFTWARE\hoge/piyo\fuga/nyao"
    $Ensure = "Present"

    Context "Scratch environment without Registry exists." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Key $key -Ensure $Ensure} | Should not Throw
        }

        $get = Get-TargetResource -Key $key -Ensure $Ensure
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return Key : $Key" {
            $get.Key | Should be $key
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -Key $key -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -Key $key -Ensure "Absent" | should be $true
        }

        It "Set-TargetResource Present should not Throw as Ensure : $Ensure" {
            {Set-TargetResource -Key $key -Ensure $Ensure} | should not Throw
        }
    }

    Context "Already Configured Environment should skip." {
        It "Set-TargetResource $Ensure should not Throw" {
            {Set-TargetResource -Key $key -Ensure $Ensure} | should not Throw
        }
        
        It "Test-TargetResource Present should return true" {
           Test-TargetResource -Key $key -Ensure $Ensure | should be $true
        }

        It "Test-TargetResource Absent should return false" {
            Test-TargetResource -Key $key -Ensure "Absent" | should be $false
        }
    }

    Context "Remove Configured settings." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -Key $key -Ensure "Absent"} | should not Throw
        }
        
        It "Test-TargetResource Present should return true" {
           Test-TargetResource -Key $key -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return false" {
            Test-TargetResource -Key $key -Ensure "Absent" | should be $true
        }
    }

    Context "Scratch environment without Registry exists." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Key $key2 -Ensure $Ensure} | Should not Throw
        }

        $get = Get-TargetResource -Key $key2 -Ensure $Ensure
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return Key : $Key2" {
            $get.Key | Should be $key2
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -Key $key2 -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -Key $key2 -Ensure "Absent" | should be $true
        }

        It "Set-TargetResource Present should not Throw as Ensure : $Ensure" {
            {Set-TargetResource -Key $key2 -Ensure $Ensure} | should not Throw
        }
    }

    Context "Already Configured Environment should skip." {
        It "Set-TargetResource $Ensure should not Throw" {
            {Set-TargetResource -Key $key2 -Ensure $Ensure} | should not Throw
        }
        
        It "Test-TargetResource Present should return true" {
           Test-TargetResource -Key $key2 -Ensure $Ensure | should be $true
        }

        It "Test-TargetResource Absent should return false" {
            Test-TargetResource -Key $key2 -Ensure "Absent" | should be $false
        }
    }

    Context "Remove Configured settings." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -Key $key2 -Ensure "Absent"} | should not Throw
        }
        
        It "Test-TargetResource Present should return true" {
           Test-TargetResource -Key $key2 -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return false" {
            Test-TargetResource -Key $key2 -Ensure "Absent" | should be $true
        }
    }

    Context "invalid Key." {
        It "Get-TargetResource should Throw" {
            {Get-TargetResource -Key $invalidKey -Ensure $Ensure} | should Throw
        }
        
        It "Test-TargetResource Should Throw" {
           {Test-TargetResource -Key $invalidKey -Ensure $Ensure} | should Throw
        }

        It "Set-TargetResource should throw" {
            {Set-TargetResource -Key $invalidKey -Ensure $Ensure} | Should Throw
        }
    }
}
