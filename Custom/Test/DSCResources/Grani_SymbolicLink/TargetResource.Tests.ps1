$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScheduleTask : TargetResource" {

    $DestinationPath = "d:\fuga"
    $SourcePath = "d:\hoge"
    $name = "hoge.log"
    $file = Join-Path $SourcePath $name
    $Ensure = "Present"

    New-Item $SourcePath -Itemtype Directory -Force > $null
    New-Item $file -Itemtype File -Force > $null
    
    Context "Scratch environment with Directory." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure} | Should not Throw
        }

        $get = Get-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return DestinationPath : $DestinationPath" {
            $get.DestinationPath | Should be $DestinationPath
        }

        It "Get-TargetResource should return SourcePath : $SourcePath" {
            $get.SourcePath | Should be $SourcePath
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure Absent | should be $true
        }

        It "Set-TargetResource Present should not Throw as Ensure : $ensure" {
            {Set-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure} | should not Throw
        }
    }

    Context "Already configured environment with Directory." {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure} | Should not Throw
        }

        It "Get-TargetResource should return Ensure : $Ensure" {
            (Get-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure).Ensure | Should be $ensure
        }

        It "Test-TargetResource should return false as Ensure : Absent" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure Absent | should be $false
        }

        It "Test-TargetResource should return true as Ensure : $Ensure" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure | should be $true
        }
    }

    Context "Remove existing Settings with Directory." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure Absent} | should not Throw
        }
        
        It "Test-TargetResource Present should return false" {
           Test-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $SourcePath -Ensure Absent | should be $true
        }
    }

    Context "Scratch environment with File." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure} | Should not Throw
        }

        $get = Get-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return DestinationPath : $DestinationPath" {
            $get.DestinationPath | Should be $DestinationPath
        }

        It "Get-TargetResource should return SourcePath : $file" {
            $get.SourcePath | Should be $file
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure Absent | should be $true
        }

        It "Set-TargetResource Present should not Throw as Ensure : $ensure" {
            {Set-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure} | should not Throw
        }
    }

    Context "Already configured environment with Directory." {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure} | Should not Throw
        }

        It "Get-TargetResource should return Ensure : $Ensure" {
            (Get-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure).Ensure | Should be $ensure
        }

        It "Test-TargetResource should return false as Ensure : Absent" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure Absent | should be $false
        }

        It "Test-TargetResource should return true as Ensure : $Ensure" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure | should be $true
        }
    }

    Context "Remove existing Settings with Directory." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure Absent} | should not Throw
        }
        
        It "Test-TargetResource Present should return false" {
           Test-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure $Ensure | should be $false
        }

        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -DestinationPath $DestinationPath -SourcePath $file -Ensure Absent | should be $true
        }
    }

    Remove-Item -Path $SourcePath -Force -Recurse
}


