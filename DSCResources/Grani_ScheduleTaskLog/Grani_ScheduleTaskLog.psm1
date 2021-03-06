﻿function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]$Enable
    )

    try {
        $instance = ScheduledTaskLogInstance
        $instance.IsEnabled = $Enable
        $instance.SaveChanges()
    }
    finally {
        $instance.Dispose() > $null
    }
}

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]$Enable
    )

    try {
        $instance = ScheduledTaskLogInstance
        return @{
            Enable = $instance.IsEnabled
        }
    }
    finally {
        $instance.Dispose() > $null
    }
}

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]$Enable
    )

    return (Get-TargetResource -Enable $Enable).Enable -eq $Enable
}

function ScheduledTaskLogInstance {
    [CmdletBinding()]
    [OutputType([System.Diagnostics.Eventing.Reader.EventLogConfiguration])]
    param
    (
    )
    $logName = 'Microsoft-Windows-TaskScheduler/Operational'
    $instance = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
    return $instance
}

Export-ModuleMember -Function *-TargetResource