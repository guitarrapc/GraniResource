$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_PendingReboot : *-TargetResource" {

    $name1 = "test PendingReboot"
    $waitTimeSec = 1
    $force = $true
    $whatIf = $true
    $TriggerPendingFileRename = $false

    $componentBasedServicing = @{
        Path = 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\'
        Name = "RebootPending"
        Value = "1"
    }
    $windowsUpdate = @{
        Path = 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\'
        Name = "RebootPending"
        Value = "1"
    }
    $pendingFileRenameOperations = @{
        Path = 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\'
        Name = "PendingFileRenameOperations"
        Value = "hoge"
    }
    $computerName = [System.Net.DNS]::GetHostName().ToUpper()
    $pendingComputerName = @{
        Path = 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName'
    }

    Context "pendingFileRenameOperations environment." {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf).Ensure | should be "Absent"
        }

        It "Test-TargetResource should return true" {
            {Set-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf} | should not Throw
        }

        Set-ItemProperty @pendingFileRenameOperations
        $result = Get-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be "Absent"
        }

        It "Get-TargetResource should return Name : $name1" {
            $result.Name | should be $name1
        }

        It "Get-TargetResource should return WaitTimeSec : $waitTimeSec" {
            $result.WaitTimeSec | should be $waitTimeSec
        }

        It "Get-TargetResource should return RebootNodeIfNeeded : $rebootNodeIfNeeded" {
            $result.RebootNodeIfNeeded | should be $rebootNodeIfNeeded
        }

        It "Get-TargetResource should return TriggerComponentBasedServicing :  $true" {
            $result.TriggerComponentBasedServicing | should be $true
        }

        It "Get-TargetResource should return TriggerWindowsUpdate :  $true" {
            $result.TriggerWindowsUpdate | should be $true
        }

        It "Get-TargetResource should return TriggerPendingFileRename :  $true" {
            $result.TriggerPendingFileRename | should be $true
        }

        It "Get-TargetResource should return TriggerPendingComputerRename :  $true" {
            $result.TriggerPendingComputerRename | should be $true
        }

        It "Get-TargetResource should return TriggerCcmClientSDK :  $true" {
            $result.TriggerCcmClientSDK | should be $true
        }

        It "Get-TargetResource should return ComponentBasedServicing : $false" {
            $result.ComponentBasedServicing | should be $false
        }

        It "Get-TargetResource should return WindowsUpdate : $false" {
            $result.WindowsUpdate | should be $false
        }

        It "Get-TargetResource should return PendingFileRename : $true" {
            $result.PendingFileRename | should be $true
        }

        It "Get-TargetResource should return PendingComputerRename : $false" {
            $result.PendingComputerRename | should be $false
        }

        It "Test-TargetResource should return $false" {
            Test-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf | should be $false
        }

        It "Set-TargetResource should not Throw. => Also remove trigger key." {
            {
                Set-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf
                Remove-ItemProperty $pendingFileRenameOperations.Path -Name $pendingFileRenameOperations.Name
            } | should not Throw
        }
    }

    Context "skip pendingFileRenameOperations environment." {
        Set-ItemProperty @pendingFileRenameOperations
        $result = Get-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf -TriggerPendingFileRename $TriggerPendingFileRename 
        It "Get-TargetResource should return Ensure : $true" {
            $result.Ensure | should be $true
        }

        It "Get-TargetResource should return Name : $name1" {
            $result.Name | should be $name1
        }

        It "Get-TargetResource should return WaitTimeSec : $waitTimeSec" {
            $result.WaitTimeSec | should be $waitTimeSec
        }

        It "Get-TargetResource should return RebootNodeIfNeeded : $rebootNodeIfNeeded" {
            $result.RebootNodeIfNeeded | should be $rebootNodeIfNeeded
        }

        It "Get-TargetResource should return TriggerComponentBasedServicing :  $true" {
            $result.TriggerComponentBasedServicing | should be $true
        }

        It "Get-TargetResource should return TriggerWindowsUpdate :  $true" {
            $result.TriggerWindowsUpdate | should be $true
        }

        It "Get-TargetResource should return TriggerPendingFileRename :  $true" {
            $result.TriggerPendingFileRename | should be $false
        }

        It "Get-TargetResource should return TriggerPendingComputerRename :  $true" {
            $result.TriggerPendingComputerRename | should be $true
        }

        It "Get-TargetResource should return TriggerCcmClientSDK :  $true" {
            $result.TriggerCcmClientSDK | should be $true
        }

        It "Get-TargetResource should return ComponentBasedServicing : $false" {
            $result.ComponentBasedServicing | should be $false
        }

        It "Get-TargetResource should return ComponentBasedServicing : $false" {
            $result.ComponentBasedServicing | should be $false
        }

        It "Get-TargetResource should return WindowsUpdate : $false" {
            $result.WindowsUpdate | should be $false
        }

        It "Get-TargetResource should return PendingFileRename : $false" {
            $result.PendingFileRename | should be $false
        }

        It "Get-TargetResource should return PendingComputerRename : $false" {
            $result.PendingComputerRename | should be $false
        }

        It "Test-TargetResource should return $true" {
            Test-TargetResource -Name $name1 -WaitTimeSec $waitTimeSec -Force $force -WhatIf $whatIf -TriggerPendingFileRename $TriggerPendingFileRename | should be $true
        }
    }
}