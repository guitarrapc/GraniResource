$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_DotNetFramework : Verify" {

    $validKB = (Get-Hotfix | select -First 1).HotFixId;
    $invalidKB = "KB1";
    $present = "present";
    $absent = "absent";

    Context "VerifyExitCode" {

        It "Exit Code 0 should not throw" {
            {VerifyExitCode -ExitCode 0} | Should not throw
        }

        It "Exit Code 1641 should not throw" {
            {VerifyExitCode -ExitCode 1641} | Should not throw
        }

        It "Exit Code 3010 should not throw" {
            {VerifyExitCode -ExitCode 3010} | Should not throw
        }

        It "Exit Code 1602 should not throw" {
            {VerifyExitCode -ExitCode 1602} | Should throw
        }

        It "Exit Code 1603 should throw" {
            {VerifyExitCode -ExitCode 1603} | Should throw
        }

        It "Exit Code 5100 should throw" {
            {VerifyExitCode -ExitCode 5100} | Should throw
        }

        It "Exit Code 1 should throw" {
            {VerifyExitCode -ExitCode 1} | Should throw
        }
    }

    Context "VerifyInstallation" {

        It "Valid Hotfix $validKB should not throw for Ensure $present." {
            {VerifyInstallation -KB $validKB -Ensure $present} | Should not throw
        }

        It "Valid Hotfix $validKB should throw for Ensure $absent." {
            {VerifyInstallation -KB $validKB -Ensure $absent} | Should throw
        }

        It "Invalid Hotfix $validKB should not throw for Ensure $absent." {
            {VerifyInstallation -KB $invalidKB -Ensure $absent} | Should not throw
        }

        It "Invalid Hotfix $validKB should throw for Ensure $present." {
            {VerifyInstallation -KB $invalidKB -Ensure $present} | Should throw
        }
    }
}
