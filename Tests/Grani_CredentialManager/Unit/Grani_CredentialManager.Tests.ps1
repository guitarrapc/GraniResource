$global:dscModuleName = 'GraniResource'

# Import
$modulePath = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)).Replace("Test","DSCResources")
$global:dscResourceName = (Split-Path -Path $modulePath -leaf)
$moduleFileName = $global:dscResourceName + ".psm1"
Import-Module -Name (Join-Path -Path $modulePath -ChildPath $moduleFileName) -Force

# Prerequisite for Initialize-TestEnvironment in Domain Environment
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

# Initialize
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment -DSCModuleName $global:dscModuleName -DSCResourceName $global:dscResourceName -TestType Unit

# Begin Test
try
{
    InModuleScope $global:dscResourceName {

        $instanceIdentifier = "PesterTest"
        $target = "PesterTest"
        $credential = New-Object PSCredential ("PesterTest", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
        $dummyUserCredential = New-Object PSCredential ("PesterTestDummy", ("PesterTestPassword" | ConvertTo-SecureString -Force -AsPlainText))
        $dummyPasswordCredential = New-Object PSCredential ("PesterTest", ("PesterTestPasswordDummy" | ConvertTo-SecureString -Force -AsPlainText))
        $ensure = "Present"

        Describe 'Schema' {
            it 'InstanceIdentifier Should be mandatory.' {
                $resource = Get-DscResource -Name $global:dscResourceName
                $resource.Properties.Where{$_.Name -eq 'InstanceIdentifier'}.IsMandatory | Should be $true
            }

            it 'Target Should be mandatory.' {
                $resource = Get-DscResource -Name $global:dscResourceName
                $resource.Properties.Where{$_.Name -eq 'Target'}.IsMandatory | Should be $true
            }

            it 'Credential Should not be mandatory.' {
                $resource = Get-DscResource -Name $global:dscResourceName
                $resource.Properties.Where{$_.Name -eq 'Credential'}.IsMandatory | Should be $false
            }

            it 'Ensure Should be mandatory with one value.' {
                $resource = Get-DscResource -Name $global:dscResourceName
                $resource.Properties.Where{$_.Name -eq 'Ensure'}.IsMandatory | Should be $true
            }
        }

        Describe "$global:dscResourceName\Get-TargetResouce" {
            Context "Required Key check" {
                Mock -ModuleName $global:dscResourceName -CommandName TestTarget -MockWith {
                    Write-Output $false;
                }

                $get = Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure "Absent"
                It 'Should return hashtable with Key InstanceIdentifier'{
                    $get.ContainsKey('InstanceIdentifier') | Should Be $true
                }

                It 'Should return hashtable with Value that matches "PesterTest"'{
                    $get.InstanceIdentifier | Should be $instanceIdentifier
                }

                It 'Should return hashtable with Key Target'{
                    $get.ContainsKey('Target') | Should Be $true
                }

                It 'Should return hashtable with Value that matches "PesterTest"'{
                    $get.Target | Should be $target
                }

                It 'Should return hashtable with Key Target'{
                    $get.ContainsKey('Ensure') | Should Be $true
                }

                It 'Should return hashtable with Value that matches "Absent"'{
                    $get.Ensure | Should be "Absent"
                }
            }

            Context "Mocking Target not exists to test guard" {
                Mock -ModuleName $global:dscResourceName -CommandName TestTarget -MockWith {
                    Write-Output $false;
                }

                $get = Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure

                It 'Should return hashtable with Key Ensure'{
                    $get.ContainsKey('Ensure') | Should Be $true
                }

                It 'Mocking Target not exists Should return hashtable with Value that matches "Absent"'{
                    $get.Ensure | Should be 'Absent'
                }
            }

            Context "Mocking Target exists and Credential matching." {
                Mock -ModuleName $global:dscResourceName -CommandName TestTarget -MockWith {
                    Write-Output $true;
                }

                Mock -ModuleName $global:dscResourceName -CommandName IsCredentialMatch -MockWith {
                    Write-Output $false
                }

                It 'Mocking Target exists, and credential not match Should return hashtable with Value that matches "Absent"'{
                    $get = Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure
                    $get.Ensure | Should be 'Absent'
                }

                Mock -ModuleName $global:dscResourceName -CommandName IsCredentialMatch -MockWith {
                    Write-Output $true
                }

                It 'Mocking Target exists, and credential match Should return hashtable with Value that matches "Present"'{
                    $get = Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure
                    $get.Ensure | Should be 'Present'
                }
            }
        }

        Describe "$global:dscResourceName\Test-TargetResouce" {
            Context "Return type check" {
                It 'Should return bool'{
                    $test = Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure
                    $test.GetType().FullName | Should Be System.Boolean
                }
            }

            Context "Mocking Target not exists to test guard" {
                Mock -ModuleName $global:dscResourceName -CommandName TestTarget -MockWith {
                    Write-Output $false;
                }

                It 'Should return hashtable with Key Ensure'{
                    $test = Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure
                    $test | Should Be $false
                }
            }

            Context "Mocking Target exists and Credential matching." {
                Mock -ModuleName $global:dscResourceName -CommandName TestTarget -MockWith {
                    Write-Output $true;
                }

                Mock -ModuleName $global:dscResourceName -CommandName IsCredentialMatch -MockWith {
                    Write-Output $false
                }

                It 'Mocking Target exists, and credential not match Should return hashtable with Value that matches "False"'{
                    $test = Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure
                    $test | Should be $false
                }

                Mock -ModuleName $global:dscResourceName -CommandName IsCredentialMatch -MockWith {
                    Write-Output $true
                }

                It 'Mocking Target exists, and credential match Should return hashtable with Value that matches "True"'{
                    $test = Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure
                    $test | Should be $true
                }
            }
        }

        Describe "$global:dscResourceName : End-to-End Test" {   
            Context "Scratch environment" {

                It "Get-TargetResource Should not throw" {
                    {Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure} | Should not Throw
                }

                $get = Get-TargetResource -InstanceIdentifier $instanceIdentifier  -Target $target -Credential $credential -Ensure $ensure
                It "Get-TargetResource Should return Ensure : Absent" {
                    $get.Ensure | Should be "Absent"
                }

                It "Get-TargetResource Should return Target : $target" {
                    $get.Target | Should be $target
                }

                It "Get-TargetResource Should return Credential : Microsoft.Management.Infrastructure.CimInstance" {
                    $get.Credential.GetType().FullName | Should be Microsoft.Management.Infrastructure.CimInstance
                }

                It "Test-TargetResource Present Should return false" {
                   Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure | Should be $false
                }

                It "Test-TargetResource Absent Should return true" {
                    Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure Absent | Should be $true
                }

                It "Set-TargetResource Present Should not Throw as Ensure : $ensure" {
                    {Set-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure} | Should not Throw
                }
            }

            Context "Already configured environment." {
                It "Get-TargetResource Should not throw" {
                    {Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure} | Should not Throw
                }

                It "Get-TargetResource Should return Ensure : $ensure" {
                    (Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure).Ensure | Should be $ensure
                }

                It "Test-TargetResource Should return false as Ensure : Absent" {
                    Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure Absent | Should be $false
                }

                It "Test-TargetResource Should return true as Ensure : $ensure" {
                    Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure | Should be $true
                }
            }

            Context "Remove existing Settings with Directory." {
                It "Set-TargetResource Absent Should not Throw" {
                    {Set-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure Absent} | Should not Throw
                }
        
                It "Test-TargetResource Present Should return false" {
                   Test-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure $ensure | Should be $false
                }

                It "Test-TargetResource Absent Should return true" {
                    Get-TargetResource -InstanceIdentifier $instanceIdentifier -Target $target -Credential $credential -Ensure Absent | Should be $true
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
