$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_TopShelf : TargetResource" {

    $ServiceName = "SampleTopShelfService"
    $Path = (Resolve-Path ".\SampleTopShelfService\SampleTopShelfService\bin\Debug\SampleTopShelfService.exe").Path
    $Ensure = "Present"

    Context "Scratch environment without TopShelf Service not exists." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure} | Should not Throw
        }

        $get = Get-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return ServiceName : $ServiceName" {
            $get.ServiceName | Should be $ServiceName
        }

        It "Get-TargetResource should return Path : $Path" {
            $get.Path | Should be $Path
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -Path $Path -ServiceName $ServiceName -Ensure "Absent" | should be $true
        }

        It "Set-TargetResource Present should not Throw as Ensure : $Ensure" {
            {Set-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure} | should not Throw
        }
    }

    Context "Already Configured Environment should skip." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure} | should not Throw
        }
        
        It "Test-TargetResource Present should return true" {
           Test-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure | should be $true
        }

        It "Test-TargetResource Absent should return false" {
            Test-TargetResource -Path $Path -ServiceName $ServiceName -Ensure Absent | should be $false
        }
    }

    Context "Remove Configured settings." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -Path $Path -ServiceName $ServiceName -Ensure Absent} | should not Throw
        }
        
        It "Test-TargetResource Present should return false" {
           Test-TargetResource -Path $Path -ServiceName $ServiceName -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -Path $Path -ServiceName $ServiceName -Ensure Absent | should be $true
        }
    }
}
