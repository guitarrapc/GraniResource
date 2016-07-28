$global:dscModuleName = 'GraniResource'

# Import
$modulePath = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)).Replace("Test","DSCResources")
$moduleName = (Split-Path -Path $modulePath -leaf)
$moduleFileName = $moduleName+ ".psm1"
Import-Module -Name (Join-Path -Path $modulePath -ChildPath $moduleFileName) -Force

# Begin Test
InModuleScope $moduleName {

    $target = "PesterTest"
    $credential = New-Object PSCredential ("PesterTest", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
    $dummyUserCredential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
    $dummyPasswordCredential = New-Object PSCredential ("PesterTest", ("PesterTestPasswordDummy" | ConvertTo-SecureString -Force -AsPlainText))
    $ensure = "Present"

    Describe "ListCredential" {
        Context "List existing Credential entries" {
            Mock -CommandName ListCredential -MockWith {
                Write-Output $credential;
            }

            It "Retrurns UserName $($credential.UserName)"{
                (ListCredential).UserName | Should Be $credential.UserName
            }

            It "Retrurns Password $($credential.Password)"{
                (ListCredential).Password | Should Be $credential.Password
            }

            It "Retrurns Password $($credential.GetNetworkCredential().Password)"{
                (ListCredential).GetNetworkCredential().Password | Should Be $credential.GetNetworkCredential().Password
            }
        }
    }

    Describe "SetCredential" {
        Context "Create or Update Credential entry" {
            It "Should fail when creating emptry credential entry."{
                {SetCredential -Target $target -Credential ([PSCredential]::Empty)} | Should throw
            }

            It "Should not fail when creating entry."{
                {SetCredential -Target $target -Credential $credential} | Should not throw
            }

            It "Should not fail when existing entry exists."{
                {SetCredential -Target $target -Credential $dummyUserCredential} | Should not throw
            }
        }
    }

    Describe "TestTarget" {
        Context "Test target entry exists" {
            It "Should not fail when entry not exists."{
                {TestTarget -Target ([Guid]::NewGuid().ToString())} | Should not throw
            }

            It "Not existing target should return False."{
                TestTarget -Target ([Guid]::NewGuid().ToString()) | Should be $false
            }

            It "Existing target should return True."{
                TestTarget -Target $target | Should be $true
            }
        }
    }

    Describe "GetCredential" {
        Context "Get existing credential entry" {
            It "Should fail when entry not exists."{
                {GetCredential -Target ([Guid]::NewGuid().ToString())} | Should throw
            }

            It "Should not fail when entry exists."{
                {GetCredential -Target $target} | Should not throw
            }

            It "Retrurns UserName $($dummyUserCredential.UserName)"{
                (GetCredential -Target $target).UserName | Should Be $dummyUserCredential.UserName
            }

            It "Retrurns Password $($dummyUserCredential.Password)"{
                (GetCredential -Target $target).GetNetworkCredential().Password | Should Be $dummyUserCredential.GetNetworkCredential().Password
            }
        }
    }

    Describe "IsCredentialMatch" {
        Context "Match source credential and target credential" {
            It "Should fail when target not exists."{
                {IsCredentialMatch -Target ([Guid]::NewGuid().ToString()) -Credential $credential} | Should throw
            }

            It "Retrurns false when credential UserName not match"{
                {SetCredential -Target $target -Credential $credential} | Should not throw
                IsCredentialMatch -Target $target -Credential $dummyUserCredential | Should Be $false
            }
            
            It "Retrurns false when credential Password not match"{
                IsCredentialMatch -Target $target -Credential $dummyPasswordCredential | Should Be $false
            }

            It "Retrurns true when credential match"{
                IsCredentialMatch -Target $target -Credential $credential | Should Be $true
            }
        }
    }

    Describe "RemoveTarget" {
        Context "Remove existing credntial entry" {
            It "Should fail when entry not exists."{
                {RemoveTarget -Target ([Guid]::NewGuid().ToString())} | Should throw
            }

            It "Should not fail when entry exists."{
                {RemoveTarget -Target $target} | Should not throw
            }
        }
    }
}
