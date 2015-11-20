$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_DotNetFramework : Validate" {

    $validPath = Get-ChildItem -Path $env:USERPROFILE -Recurse -File | select -First 1;
    $invalidPath = "z:\hogemoge\fugafuga\piyopiyo\zzzzzzzzzzzzzzzzzzzz";

    $validKB = (Get-Hotfix | select -First 1).HotFixId;
    $number = $validKB.Replace("KB","");
    $invalidKB = "ho" + $number;

    Context "IsHotfixEntryExists" {

        It "valid kb $validKB should be found" {
            IsHotfixEntryExists -Kb $validKB | Should be $true
        }

        It "non kb format number $numbver should not be found" {
            IsHotfixEntryExists -Kb $number | Should be $false
        }

        It "invalid kb $invalidKB should not be found" {
            IsHotfixEntryExists -Kb $invalidKB | Should be $false
        }
    }

    Context "ValidateInstallerPath" {

        It "Valid Path should not throw" {
            {ValidateInstallerPath -Path $validPath.FullName} | Should not throw
        }

        It "Invalid Path should throw" {
            {ValidateInstallerPath -Path $invalidPath} | Should throw
        }
    }

    Context "ValidateKb" {

        It "valid kb $validKB should not throw when parse to int." {
            {[int](ValidateKb -KB $validKB)} | Should not throw
        }

        It "valid number $number should not throw when parse to int." {
            {[int](ValidateKb -KB $number)} | Should not throw
        }

        It "invalid kb $invalidKB should throw when parse to int." {
            {[int](ValidateKb -KB $invalidKB)} | Should throw
        }

        It "valid kb $validKB should be int." {
            ([int](ValidateKb -KB $validKB)).GetType().FullName | Should be "System.Int32"
        }

        It "Number $number should be int." {
            ([int](ValidateKb -KB $number)).GetType().FullName | Should be "System.Int32"
        }

        It "validkb $validKB should be equal to number $number." {
            ValidateKb -KB $validKB | Should be $number
        }
    }
}
