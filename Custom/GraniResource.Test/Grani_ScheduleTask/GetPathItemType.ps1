$ErrorMessages = Data 
{
    ConvertFrom-StringData -StringData @"
        InvalidTrigger = "Invalid Operation detected, you can't set same or greater timespan for RepetitionInterval '{0}' than RepetitionDuration '{1}'."
        ExecuteBrank = "Invalid Operation detected, Execute detected as blank. You must set executable string."
"@
}

$VerboseMessages = Data 
{
    ConvertFrom-StringData -StringData @"
        CreateTask = "Creating Task Scheduler Name '{0}', Path '{1}'"
        UsePrincipal = "Using principal with Credential. Execution will be fail if not elevated."
        SkipPrincipal = "Skip Principal and Credential. Runlevel Highest requires elevated."
"@
}

$WarningMessages = Data 
{
    ConvertFrom-StringData -StringData @"
        TaskAlreadyExist = '"{0}" already exist on path "{1}". Please Set "-Force $true" to overwrite existing task.'
"@
}

function Set-TargetResource
{
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = 1, Position  = 0)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [parameter(Mandatory = 0, Position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Execute = "",

        [parameter(Mandatory = 0, Position  = 1)]
        [string]$Argument = "",
    
        [parameter(Mandatory = 1, Position  = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
    
        [parameter(Mandatory = 0, Position  = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskPath = "\",

        [parameter(Mandatory = 0, Position  = 4)]
        [ValidateNotNullOrEmpty()]
        [datetime[]]$ScheduledAt,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanDay = 0,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanHour = 1,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanMin = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationDay = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationHour = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationMin = 0,

        [parameter(Mandatory = 0, Position  = 7, parameterSetName = "Daily")]
        [ValidateNotNullOrEmpty()]
        [bool[]]$Daily = $false,

        [parameter(Mandatory = 0, Position  = 8, parameterSetName = "Once")]
        [ValidateNotNullOrEmpty()]
        [bool[]]$Once = $false,

        [parameter(Mandatory = 0, Position  = 9)]
        [string]$Description,

        [parameter(Mandatory = 0, Position  = 10)]
        [PScredential]$Credential = $null,

        [parameter(Mandatory = 0, Position  = 11)]
        [bool]$Disable = $true,

        [parameter(Mandatory = 0,Position  = 12)]
        [bool]$Hidden = $true,

        [parameter(Mandatory = 0,Position  = 13)]
        [System.Int64]$ExecuteTimeLimitTicks,

        [parameter(Mandatory = 0,Position  = 14)]
        [ValidateSet("At", "Win8", "Win7", "Vista", "V1")]
        [string]$Compatibility = "Win8",

        [parameter(Mandatory = 0,Position  = 15)]
        [ValidateSet("Highest", "Limited")]
        [string]$Runlevel = "Limited",

        [parameter(Mandatory = 0, Position  = 16)]
        [bool]$Force = $false
    )
    
    # exist
    $existingTaskParam = 
    @{
        TaskName = $taskName
        TaskPath = ValidateTaskPathLastChar -taskPath $taskPath
    }

#region Absent

    if ($Ensure -eq "Absent")
    {
        GetExistingTaskScheduler @existingTaskParam | Unregister-ScheduledTask -PassThru;
        RemoveScheduledTaskEmptyDirectoryPath
        return;
    }

#endregion

#region Present
    
    #region Exclude Action Change : Only Disable / Enable Task

    if (($Execute -eq "") -and ($null -ne (GetExistingTaskScheduler @existingTaskParam)))
    {
        switch ($Disable)
        {
            $true {
                GetExistingTaskScheduler @existingTaskParam | Disable-ScheduledTask
                return;
            }
            $false {
                GetExistingTaskScheduler @existingTaskParam | Enable-ScheduledTask
                return;
            }
        }
    }

    #endregion

    #region Include Action Change

    # Credential
    if($Credential -ne $null)
    {
        # Credential
        $credentialParam = @{
            User = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
        }

        # Principal
        $principalParam = 
        @{
            UserId = $Credential.UserName
            RunLevel = $Runlevel
            LogOnType = "InteractiveOrPassword"
        }
    }

    # validation
    if ($execute -eq ""){ throw New-Object System.InvalidOperationException ($ErrorMessages.ExecuteBrank) }
    if (TestExistingTaskSchedulerWithPath @existingTaskParam){ throw New-Object System.InvalidOperationException ($ErrorMessages.SameNameFolderFound -f $taskName) }

    # action
    $actionParam = 
    @{
        argument = $argument
        execute = $execute
    }

    # trigger
    $scheduledTimeSpan = if ($Daily -or $Once)
    {
        $null
    }
    else
    {
        CreateTimeSpan -Day $ScheduledTimeSpanDay -Hour $ScheduledTimeSpanHour -Min $ScheduledTimeSpanMin
    }

    $scheduledDuration = if ($Daily -or $Once)
    {
        $null
    }
    else
    {
        CreateTimeSpan -Day $ScheduledDurationDay -Hour $ScheduledDurationHour -Min $ScheduledDurationMin
    }
    
    $triggerParam =
    @{
        ScheduledTimeSpan = $scheduledTimeSpan
        ScheduledDuration = $scheduledDuration
        ScheduledAt = $ScheduledAt
        Daily = $Daily
        Once = $Once
    }

    if ($Description -eq ""){ $Description = "No Description" }
    
    # Setup Task items
    $action = CreateTaskSchedulerAction @actionParam
    $trigger = CreateTaskSchedulerTrigger @triggerParam
    $settings = New-ScheduledTaskSettingsSet -Disable:$Disable -Hidden:$Hidden -Compatibility $Compatibility -ExecutionTimeLimit (TicksToTimeSpan -Ticks $ExecuteTimeLimitTicks)
    $registerParam = if ($null -ne $Credential)
    {
        Write-Verbose $VerboseMessages.UsePrincipal
        $principal = New-ScheduledTaskPrincipal @principalParam
        $scheduledTask = New-ScheduledTask -Description $Description -Action $action -Settings $settings -Trigger $trigger -Principal $principal
        @{
            InputObject = $scheduledTask
            TaskName = $taskName
            TaskPath = $taskPath
            Force = $Force
        }
    }
    else
    {
        Write-Verbose $VerboseMessages.SkipPrincipal
        @{
            Action = $action
            Settings = $settings
            Trigger = $trigger
            Description = $Description
            TaskName = $taskName
            TaskPath = $taskPath
            Runlevel = $Runlevel
            Force = $Force
        }
    }

    if ($force -or -not(GetExistingTaskScheduler @existingTaskParam))
    {
        if ($null -ne $Credential)
        {
            Register-ScheduledTask @registerParam @credentialParam
        }
        else
        {
            Register-ScheduledTask @registerParam
        }
    }

    #endregion

#endregion
}

function Get-TargetResource
{
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = 1, Position  = 0)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [parameter(Mandatory = 0, Position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Execute = "",

        [parameter(Mandatory = 0, Position  = 1)]
        [string]$Argument = "",
    
        [parameter(Mandatory = 1, Position  = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
    
        [parameter(Mandatory = 0, Position  = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskPath = "\",

        [parameter(Mandatory = 0, Position  = 4)]
        [ValidateNotNullOrEmpty()]
        [datetime[]]$ScheduledAt,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanDay = 0,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanHour = 1,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanMin = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationDay = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationHour = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationMin = 0,

        [parameter(Mandatory = 0, Position  = 7, parameterSetName = "Daily")]
        [ValidateNotNullOrEmpty()]
        [bool[]]$Daily = $false,

        [parameter(Mandatory = 0, Position  = 8, parameterSetName = "Once")]
        [ValidateNotNullOrEmpty()]
        [bool[]]$Once = $false,

        [parameter(Mandatory = 0, Position  = 9)]
        [string]$Description,

        [parameter(Mandatory = 0, Position  = 10)]
        [PScredential]$Credential = $null,

        [parameter(Mandatory = 0, Position  = 11)]
        [bool]$Disable = $true,

        [parameter(Mandatory = 0,Position  = 12)]
        [bool]$Hidden = $true,

        [parameter(Mandatory = 0,Position  = 13)]
        [System.Int64]$ExecuteTimeLimitTicks,

        [parameter(Mandatory = 0,Position  = 14)]
        [ValidateSet("At", "Win8", "Win7", "Vista", "V1")]
        [string]$Compatibility = "Win8",

        [parameter(Mandatory = 0,Position  = 15)]
        [ValidateSet("Highest", "Limited")]
        [string]$Runlevel = "Limited",

        [parameter(Mandatory = 0, Position  = 16)]
        [bool]$Force = $false
    )

    $existingTaskParam = 
    @{
        TaskName = $taskName
        TaskPath = ValidateTaskPathLastChar -taskPath $taskPath
    }
    
    if ($Description -eq ""){ $Description = "No Description"}

    $presence = if (GetExistingTaskScheduler @existingTaskParam)
    {
        "Present"
    }
    else
    {
        "Absent"
    }
    
    return @{
        Ensure = $presence
        Execute = $Execute
        TaskName = $TaskName
        TaskPath = $existingTaskParam.TaskPath
        Disable = $Disable
    }
}

function Test-TargetResource
{
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = 1, Position  = 0)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure = "Present",

        [parameter(Mandatory = 0, Position  = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Execute = "",

        [parameter(Mandatory = 0, Position  = 1)]
        [string]$Argument = "",
    
        [parameter(Mandatory = 1, Position  = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
    
        [parameter(Mandatory = 0, Position  = 3)]
        [ValidateNotNullOrEmpty()]
        [string]$TaskPath = "\",

        [parameter(Mandatory = 0, Position  = 4)]
        [ValidateNotNullOrEmpty()]
        [datetime[]]$ScheduledAt,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanDay = 0,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanHour = 1,

        [parameter(Mandatory = 0, Position  = 5, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledTimeSpanMin = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationDay = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationHour = 0,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [ValidateNotNullOrEmpty()]
        [int[]]$ScheduledDurationMin = 0,

        [parameter(Mandatory = 0, Position  = 7, parameterSetName = "Daily")]
        [ValidateNotNullOrEmpty()]
        [bool[]]$Daily = $false,

        [parameter(Mandatory = 0, Position  = 8, parameterSetName = "Once")]
        [ValidateNotNullOrEmpty()]
        [bool[]]$Once = $false,

        [parameter(Mandatory = 0, Position  = 9)]
        [string]$Description,

        [parameter(Mandatory = 0, Position  = 10)]
        [PScredential]$Credential = $null,

        [parameter(Mandatory = 0, Position  = 11)]
        [bool]$Disable = $true,

        [parameter(Mandatory = 0,Position  = 12)]
        [bool]$Hidden = $true,

        [parameter(Mandatory = 0,Position  = 13)]
        [System.Int64]$ExecuteTimeLimitTicks,

        [parameter(Mandatory = 0,Position  = 14)]
        [ValidateSet("At", "Win8", "Win7", "Vista", "V1")]
        [string]$Compatibility = "Win8",

        [parameter(Mandatory = 0,Position  = 15)]
        [ValidateSet("Highest", "Limited")]
        [string]$Runlevel = "Limited",

        [parameter(Mandatory = 0, Position  = 16)]
        [bool]$Force = $false
    )

    $existingTaskParam = 
    @{
        TaskName = $taskName
        TaskPath = ValidateTaskPathLastChar -taskPath $taskPath
    }
    
    $state = if ($Disable)
    {
        "Disabled"
    }
    else
    {
        "Running", "Ready"
    }

    $presence = if (GetExistingTaskScheduler @existingTaskParam | where State -in $state)
    {
        "Present"
    }
    else
    {
        "Absent"
    }
    
    return $presence -eq $Ensure
}

function ValidateTaskPathLastChar ($taskPath)
{
    $lastChar = [System.Linq.Enumerable]::ToArray($taskPath) | select -Last 1
    if ($lastChar -ne "\"){ return $taskPath + "\" }
    return $taskPath
}

function CreateTaskSchedulerAction ($argument, $execute)
{
    $action = if ($argument -ne "")
    {
        New-ScheduledTaskAction -Execute $execute -Argument $Argument
    }
    else
    {
        New-ScheduledTaskAction -Execute $execute
    }
    return $action
}

function CreateTimeSpan
{
    param(
        [parameter(Mandatory = 0, Position  = 0)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Day,

        [parameter(Mandatory = 0, Position  = 1)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Hour,

        [parameter(Mandatory = 0, Position  = 2)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Min
    )

    if ($PSBoundParameters.ContainsKey("Day") -and $PSBoundParameters.ContainsKey("Hour") -and $PSBoundParameters.ContainsKey("Min"))
    {
        $first = New-ZipPairs -first $Day -second $Hour
        $result = New-ZipPairs -first $first -second $Min
        foreach ($x in $result)
        {
            if ($x.item1.item1 -eq 0 -and $x.item1.item2 -eq 0 -and $x.item2 -eq 0)
            {
                [TimeSpan]::MaxValue
            }
            else
            {
                New-TimeSpan -Days $x.item1.item1 -Hours $x.item1.item2 -Minutes $x.item2
            }
        }
    }   
}

function TicksToTimeSpan ([System.Int64]$Ticks)
{
    return [TimeSpan]::FromTicks($Ticks)
}

function CreateTaskSchedulerTrigger ($ScheduledTimeSpan, $ScheduledDuration, $ScheduledAt, $Daily, $Once)
{
    $trigger = if (($false -eq $Daily) -and ($false -eq $Once))
    {
        $ScheduledTimeSpanPair = New-ZipPairs -first $ScheduledTimeSpan -Second $ScheduledDuration
        $ScheduledAtPair = New-ZipPairs -first $ScheduledAt -Second $ScheduledTimeSpanPair
        $ScheduledAtPair `
        | %{
            if ($_.Item2.Item1 -ge $_.Item2.Item2){ throw New-Object System.InvalidOperationException ($ErrorMessages.InvalidTrigger -f $_.Item2.Item1, $_.Item2.Item2)}
            New-ScheduledTaskTrigger -At $_.Item1 -RepetitionInterval $_.Item2.Item1 -RepetitionDuration $_.Item2.Item2 -Once
        }
    }
    elseif ($Daily)
    {
        $ScheduledAt | %{New-ScheduledTaskTrigger -At $_ -Daily}
    }
    elseif ($Once)
    {
        $ScheduledAt | %{New-ScheduledTaskTrigger -At $_ -Once}
    }
    return $trigger
}

function GetExistingTaskScheduler ($TaskName, $TaskPath)
{
    return Get-ScheduledTask | where TaskName -eq $taskName | where TaskPath -eq $taskPath
}

function TestExistingTaskScheduler ($TaskName, $TaskPath)
{
    $task = GetExistingTaskScheduler -TaskName $TaskName -TaskPath $TaskPath
    return ($task | Measure-Object).count -ne 0
}

function TestExistingTaskSchedulerWithPath ($TaskName, $TaskPath)
{
    if ($TaskPath -ne "\"){ return $false }

    # only run when taskpath is \
    $path = Join-Path $env:windir "System32\Tasks"
    $result = Get-ChildItem -Path $path -Directory | where Name -eq $TaskName

    if (($result | measure).count -ne 0)
    {
        return $true
    }
    return $false
}

function RemoveScheduledTaskEmptyDirectoryPath
{
    # validate target Directory is existing
    $path = Join-Path $env:windir "System32\Tasks"
    $result = Get-ChildItem -Path $path -Directory | where Name -ne "Microsoft"
    if (($result | measure).count -eq 0){ return; }

    # validate Child is blank
    $result.FullName `
    | where {(Get-ChildItem -Path $_) -eq $null} `
    | Remove-Item -Force
}

function New-ZipPairs
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = 0, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]$first,
 
        [parameter(Mandatory = 0, Position = 1, ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]$second,

        [parameter(Mandatory = 0, Position = 2, ValueFromPipelineByPropertyName = 1)]
        [scriptBlock]$resultSelector
    )

    process
    {
        if ([string]::IsNullOrWhiteSpace($first)){ break }        
        if ([string]::IsNullOrWhiteSpace($second)){ break }
        
        try
        {
            $e1 = @($first).GetEnumerator()

            while ($e1.MoveNext() -and $e2.MoveNext())
            {
                if ($PSBoundParameters.ContainsKey('resultSelector'))
                {
                    $first = $e1.Current
                    $second = $e2.Current
                    $context = $resultselector.InvokeWithContext(
                        $null,
                        ($psvariable),
                        {
                            (New-Object System.Management.Automation.PSVariable ("first", $first)),
                            (New-Object System.Management.Automation.PSVariable ("second", $second))
                        }
                    )
                    $context
                }
                else
                {
                    $tuple = New-Object 'System.Tuple[PSObject, PSObject]' ($e1.Current, $e2.current)
                    $tuple
                }
            }
        }
        finally
        {
            if(($d1 = $e1 -as [IDisposable]) -ne $null) { $d1.Dispose() }
            if(($d2 = $e2 -as [IDisposable]) -ne $null) { $d2.Dispose() }
            if(($d3 = $psvariable -as [IDisposable]) -ne $null) {$d3.Dispose() }
            if(($d4 = $context -as [IDisposable]) -ne $null) {$d4.Dispose() }
            if(($d5 = $tuple -as [IDisposable]) -ne $null) {$d5.Dispose() }
        }
    }

    begin
    {
        $e2 = @($second).GetEnumerator()
        $psvariable = New-Object 'System.Collections.Generic.List[System.Management.Automation.psvariable]'
    }
}