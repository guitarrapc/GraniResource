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
$TestEnvironment = Initialize-TestEnvironment -DSCModuleName $global:dscModuleName -DSCResourceName $global:dscResourceName -TestType Integration

# Begin Test
try
{
    Describe "$($global:DSCResourceName)_Present_Integration" {

        #load configuration
        $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($global:DSCResourceName).Config.Present.ps1"
        . $ConfigFile -Verbose -ErrorAction Stop
        
        It 'Should compile without throwing' {
            {
                . "$($global:DSCResourceName)_Config_Present" -OutputPath $TestEnvironment.WorkingFolder -ConfigurationData $configurationDataPresent
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should Not throw
        }

        It 'should be true for Test-Configuration' {
            { Test-DscConfiguration -Verbose -ErrorAction Stop } | Should Be $true
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {
                $_.ConfigurationName -eq "$($global:DSCResourceName)_Config_Present"
            }
            $current.InstanceIdentifier | Should Be $configurationDataPresent.AllNodes.InstanceIdentifier
            $current.Ensure | Should Be $configurationDataPresent.AllNodes.Ensure
            $current.Target | Should Be $ConfigurationDataPresent.AllNodes.Target
        }
    }

    Describe "$($global:DSCResourceName)_Absent_Integration" {

        #load configuration
        $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($global:DSCResourceName).Config.Absent.ps1"
        . $ConfigFile -Verbose -ErrorAction Stop
        
        It 'Should compile without throwing' {
            {
                . "$($global:DSCResourceName)_Config_Absent" -OutputPath $TestEnvironment.WorkingFolder -ConfigurationData $configurationDataAbsent
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should Not throw
        }

        It 'should be true for Test-Configuration' {
            { Test-DscConfiguration -Verbose -ErrorAction Stop } | Should Be $true
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {
                $_.ConfigurationName -eq "$($global:DSCResourceName)_Config_Absent"
            }
            $current.InstanceIdentifier | Should Be $configurationDataAbsent.AllNodes.InstanceIdentifier
            $current.Ensure | Should Be $configurationDataAbsent.AllNodes.Ensure
            $current.Target | Should Be $ConfigurationDataAbsent.AllNodes.Target
        }
    }

    Describe "$($global:DSCResourceName)_MultipleTargetPresent_Integration" {

        #load configuration
        $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($global:DSCResourceName).Config.MultipleTargetPresent.ps1"
        . $ConfigFile -Verbose -ErrorAction Stop
        
        It 'Should compile without throwing' {
            {
                . "$($global:DSCResourceName)_Config_MultipleTargetPresent" -OutputPath $TestEnvironment.WorkingFolder -ConfigurationData $configurationDataPresent
                Start-DscConfiguration -Path $TestEnvironment.WorkingFolder -ComputerName localhost -Wait -Verbose -Force
            } | Should Not throw
        }

        It 'should be true for Test-Configuration' {
            { Test-DscConfiguration -Verbose -ErrorAction Stop } | Should Be $true
        }

        It 'should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $current = Get-DscConfiguration | Where-Object {
                $_.ConfigurationName -eq "$($global:DSCResourceName)_Config_MultipleTargetPresent"
            }
            $current | ft | Out-String | Write-Verbose -Verbose
            $current.InstanceIdentifier | Should Be $configurationDataMultipleTargetPresent.AllNodes.InstanceIdentifier
            $current.Ensure | Should Be $configurationDataMultipleTargetPresent.AllNodes.Ensure
            $current.Target | Should Be $configurationDataMultipleTargetPresent.AllNodes.Target
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
