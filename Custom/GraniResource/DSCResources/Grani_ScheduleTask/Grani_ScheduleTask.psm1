#region Initialize

function Initialize
{
    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue

    #-- PublicEnum Enum for ScheduledTaskTest --#
    Add-Type -TypeDefinition @"
        public enum ScheduledParameterType
        {
            Root,
            Actions,
            Principal,
            Settings,
            Triggers
        }
"@ -ErrorAction SilentlyContinue

    #-- PublicEnum Enum for ScheduledTaskTest Property --#
    Add-Type -TypeDefinition @"
        public enum ScheduledTaskPropertyType
        {
            TaskPaty,
            TaskName,
            Description,
            Execute,
            Argument,
            WorkingDirectory,
            Credential,
            RunLevel,
            Compatibility,
            ExecutionTimeLimit,
            Hidden,
            Disable,
            ScheduledAt,
            ScheduledTimeSpan,
            ScheduledDuration,
            Daily,
            Once
        }
"@ -ErrorAction SilentlyContinue
}

Initialize

#endregion

#region Message Definition

$verboseMessages = Data {
    ConvertFrom-StringData -StringData @"
        EnsureDetectAbsent = Ensure detected as Absent. Removing existing ScheduledTask for TaskPath '{0}', TaskName '{1}'.
        EnsureDetectPresent = Ensure detected as Present. Setting ScheduledTask for TaskPath '{0}', TaskName '{1}'.
        DisableDetected = Disabled detected as $true. Disabling task and exit configuration.
"@
}

$debugMessages = Data {
    ConvertFrom-StringData -StringData @"
        CheckSchedulerDaily = Checking Trigger is : Daily
        CheckSchedulerOnce = Checking Trigger is : Once
        CheckScheduleTaskExist = Checking {0} is exists with : {1}
        CheckScheduleTaskParameter = Checking {0} is match with : {1}
        CheckScheduleTaskParameterTimeSpan = Checking {0} is match with : {1}min
        CreateTask = Creating Task Scheduler Name '{0}', Path '{1}'
        ScheduleTaskResult = {0} : {1} ({2})
        ScheduleTaskTimeSpanResult = {0} : {1} ({2}min)
        SetAction = Setting Action Execute : '{0}', Argument : '{1}', WorkingDirectory : '{2}'.
        SetDescription = Setting Description : '{0}'.
        SetDisable = Setting ScheduledTask Disable : '{0}'.
        SetTrigger = Setting Trigger ScheduledTimeSpan : '{0}', ScheduledDuration : '{1}', ScheduledAt : '{2}', Daily : '{3}', Once : '{4}'.
        SkipNoneUseParameter = Skipping {0} as value not passed to function.
        SkipNullPassedParameter = Skipping {0} as passed value is null.
        SkipPrincipal = Skip Credential. Using System for Principal.
        UsePrincipal = Using principal with Credential. Execution will be fail if not elevated.
"@
}

$errorMessages = Data {
    ConvertFrom-StringData -StringData @"
        InvalidTrigger = Invalid Operation detected, you can't set same or greater timespan for RepetitionInterval '{0}' than RepetitionDuration '{1}'.
        ExecuteBrank = Invalid Operation detected, Execute detected as blank. You must set executable string.
        ScheduleAtArgumentLength = Argument length not match with current ScheduledAt {0} and passed ScheduledAt {1}.
        ScheduleRepetitionArgumentLength = Argument length not match with current Scheduled Repetition {0} and passed ScheduledAt {1}.
        ScheduleAtNullException = ScheduledAt detected as null. You must set at least 1 ScheduledAt to set ScheduledTask as Present.
"@
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [OutputType([HashTable])]
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [parameter(Mandatory = $true)]
        [System.String]$TaskName,

        [parameter(Mandatory = $false)]
        [System.String]$TaskPath = "\",

        [parameter(Mandatory = $false)]
        [System.String]$Description,

        [parameter(Mandatory = $false)]
        [System.String]$Execute,

        [parameter(Mandatory = $false)]
        [System.String]$Argument,

        [parameter(Mandatory = $false)]
        [System.String]$WorkingDirectory,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory = $false)]
        [ValidateSet("Highest","Limited")]
        [System.String]$Runlevel,

        [parameter(Mandatory = $false)]
        [ValidateSet("At","Win8","Win7","Vista","V1")]
        [System.String]$Compatibility,

        [parameter(Mandatory = $false)]
        [System.Int64]$ExecuteTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Hidden,

        [parameter(Mandatory = $true)]
        [System.Boolean]$Disable,

        [parameter(Mandatory = $false)]
        [System.DateTime[]]$ScheduledAt,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanDay = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanHour = 1,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanMin = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationDay = 1,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationHour = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationMin = 0,

        [parameter(Mandatory = $false, parameterSetName = "Daily")]
        [System.Boolean]$Daily,

        [parameter(Mandatory = $false, parameterSetName = "Once")]
        [System.Boolean]$Once
    )

    $param = @{}

    # Task Path validation
    $param.TaskPath = ValidateTaskPathLastChar -taskPath $taskPath

    if ($Disable)
    {
        Write-Debug "Disable"
        @(
            'TaskName',
            'Disable'
        ) `
        | where {$PSBoundParameters.ContainsKey($_)} `
        | %{ $param.$_ = Get-Variable -Name $_ -ValueOnly }
    }
    else
    {
        # Credential param
        if (($PSBoundParameters.ContainsKey("Credential")) -or ([PSCredential]::Empty -ne $Credential))
        {
            $param.Credential = $Credential
        }

        # Trigger param
        if ($PSBoundParameters.ContainsKey("Once"))
        {
            $param.Once = $Once
        }
        elseif ($PSBoundParameters.ContainsKey("Daily"))
        {
            $param.Daily = $Daily
        }
        else
        {
            if ($PSBoundParameters.ContainsKey('ScheduledTimeSpanDay') -and $PSBoundParameters.ContainsKey('ScheduledTimeSpanHour') -and $PSBoundParameters.ContainsKey('ScheduledTimeSpanMin'))
            {
                $param.ScheduledTimeSpan = CreateTimeSpan -Day $ScheduledTimeSpanDay -Hour $ScheduledTimeSpanHour -Min $ScheduledTimeSpanMin
            }

            if ($PSBoundParameters.ContainsKey('ScheduledDurationDay') -and $PSBoundParameters.ContainsKey('ScheduledDurationHour') -and $PSBoundParameters.ContainsKey('ScheduledDurationMin'))
            {
                $param.ScheduledDuration = CreateTimeSpan -Day $ScheduledDurationDay -Hour $ScheduledDurationHour -Min $ScheduledDurationMin
            }
        }

        # ExecutionTimelimit param
        Write-Verbose $PSBoundParameters.ContainsKey("ExecuteTimeLimitTicks")
        if ($PSBoundParameters.ContainsKey("ExecuteTimeLimitTicks")){ $param.ExecutionTimeLimit = [TimeSpan]::FromTicks($ExecuteTimeLimitTicks) }

        # obtain other param
        @(
            'TaskName',
            'Description', 
            'Execute', 
            'Argument', 
            'WorkingDirectory', 
            'Runlevel',
            'Compatibility',
            'Hidden',
            'Disable', 
            'ScheduledAt'
        ) `
        | where {$PSBoundParameters.ContainsKey($_)} `
        | %{ $param.$_ = Get-Variable -Name $_ -ValueOnly }
    }

    # Test current ScheduledTask
    $taskResult = TestScheduledTaskStatus @param

    # ensure check
    $ensureResult = if (($taskResult.GetEnumerator() | %{$_.Value.result}) -contains $false)
    {
        [EnsureType]::Absent
    }
    else
    {
        [EnsureType]::Present
    }

    # return hashtable    
    $returnHash = [ordered]@{}
    $returnHash.Ensure = $ensureResult
    @(
        # root
        'TaskName',
        'TaskPath',
        'Description', 

        # Action
        'Execute', 
        'Argument', 
        'WorkingDirectory', 

        # Principal
        'Runlevel',

        # settings
        'Compatibility',
        'Hidden',
        'Disable',

        # Trigger
        'ScheduledAt',
        'Daily',
        'Once'
    ) `
    | where {$taskResult."$_".target -ne $null} `
    | %{$returnHash.$_ = $taskResult."$_".target}

    # convert credential to CIM Instance
    if (($PSBoundParameters.ContainsKey("Credential")))
    {
        $returnHash.Credential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
    }

    # convert timespan to int
    if (($PSBoundParameters.ContainsKey("ExecuteTimeLimitTicks")) -and ($taskResult.ExecutionTimeLimit.target.Ticks -ne $null))
    {
        $returnHash.ExecuteTimeLimitTicks = [System.Int64]$taskResult.ExecutionTimeLimit.target.Ticks
    }
    if (($PSBoundParameters.ContainsKey("ScheduledTimeSpanDay")) -and ($taskResult.ScheduledTimeSpan.target -ne $null))
    {
        $returnHash.ScheduledTimeSpanDay = [int[]]($taskResult.ScheduledTimeSpan.target.Days)
    }
    if (($PSBoundParameters.ContainsKey("ScheduledTimeSpanHour")) -and ($taskResult.ScheduledTimeSpan.target -ne $null))
    {
        $returnHash.ScheduledTimeSpanHour = [int[]]($taskResult.ScheduledTimeSpan.target.Hours)
    }
    if (($PSBoundParameters.ContainsKey("ScheduledTimeSpanMin")) -and ($taskResult.ScheduledTimeSpan.target -ne $null))
    {
        $returnHash.ScheduledTimeSpanMin = [int[]]($taskResult.ScheduledTimeSpan.target.Minutes)
    }
    if (($PSBoundParameters.ContainsKey("ScheduledDurationDay")) -and ($taskResult.ScheduledDuration.target -ne $null))
    {
        $returnHash.ScheduledDurationDay = [int[]]($taskResult.ScheduledDuration.target.Days)
    }
    if (($PSBoundParameters.ContainsKey("ScheduledDurationHour")) -and ($taskResult.ScheduledDuration.target -ne $null))
    {
        $returnHash.ScheduledDurationHour = [int[]]($taskResult.ScheduledDuration.target.Hours)
    }
    if (($PSBoundParameters.ContainsKey("ScheduledDurationMin")) -and ($taskResult.ScheduledDuration.target -ne $null))
    {
        $returnHash.ScheduledDurationMin = [int[]]($taskResult.ScheduledDuration.target.Minutes)
    }

    return $returnHash
}

function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [parameter(Mandatory = $true)]
        [System.String]$TaskName,

        [parameter(Mandatory = $false)]
        [System.String]$TaskPath = "\",

        [parameter(Mandatory = $false)]
        [System.String]$Description,

        [parameter(Mandatory = $false)]
        [System.String]$Execute = [string]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$Argument = [string]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$WorkingDirectory = [string]::Empty,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [ValidateSet("Highest","Limited")]
        [System.String]$Runlevel = "Limited",

        [parameter(Mandatory = $false)]
        [ValidateSet("At","Win8","Win7","Vista","V1")]
        [System.String]$Compatibility = "Win8",

        [parameter(Mandatory = $false)]
        [System.Int64]$ExecuteTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Hidden = $true,

        [parameter(Mandatory = $true)]
        [System.Boolean]$Disable = $false,

        [parameter(Mandatory = $false)]
        [System.DateTime[]]$ScheduledAt,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanDay = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanHour = 1,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanMin = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationDay = 1,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationHour = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationMin = 0,

        [parameter(Mandatory = $false, parameterSetName = "Daily")]
        [System.Boolean]$Daily = $false,

        [parameter(Mandatory = $false, parameterSetName = "Once")]
        [System.Boolean]$Once = $false
    )
    
    # exist
    $existingTaskParam = 
    @{
        TaskName = $taskName
        TaskPath = ValidateTaskPathLastChar -taskPath $taskPath
    }
    $existingTask = GetExistingTaskScheduler @existingTaskParam

    #region Absent

    if ($Ensure -eq "Absent")
    {
        Write-Verbose ($verboseMessages.EnsureDetectAbsent -f $TaskPath, $TaskName)
        $existingTask | Unregister-ScheduledTask -Confirm:$false > $null;
        RemoveScheduledTaskEmptyDirectoryPath
        return;
    }

    #endregion

    #region Present

    Write-Verbose ($verboseMessages.EnsureDetectPresent -f $TaskPath, $TaskName)
    
    # Enable/Disable
    if (($existingTask | measure).Count -ne 0)
    {
        Write-Debug ($debugMessages.SetDisable -f $Disable)
        switch ($Disable)
        {
            $true {
                Write-Verbose ($verboseMessages.DisableDetected -f $TaskPath, $TaskName)
                $existingTask | Disable-ScheduledTask
                return
            }
            $false {
                $existingTask | Enable-ScheduledTask
            }
        }
    }

    # validation
    ValidateSameFolderNotExist @existingTaskParam

    $scheduleTaskParam = @{}

    # description
    if (-not [string]::IsNullOrWhiteSpace($Description))
    {
        Write-Debug ($debugMessages.SetDescription -f $Description)
        $scheduleTaskParam.description = $Description
    }

    # action
    Write-Debug ($debugMessages.SetAction -f $Execute, $Argument, $WorkingDirectory)
    $actionParam = 
    @{
        Execute = $Execute
        Argument = $Argument
        WorkingDirectory = $WorkingDirectory
    }
    $scheduleTaskParam.action = CreateTaskSchedulerAction @actionParam

    # trigger
    if ($ScheduledAt -ne $null)
    {
        if ($Daily -or $Once)
        {
            $scheduledTimeSpan = $scheduledDuration = $null
        }
        else
        {
            $scheduledTimeSpan = CreateTimeSpan -Day $ScheduledTimeSpanDay -Hour $ScheduledTimeSpanHour -Min $ScheduledTimeSpanMin
            $scheduledDuration = CreateTimeSpan -Day $ScheduledDurationDay -Hour $ScheduledDurationHour -Min $ScheduledDurationMin
        }
    
        Write-Debug ($debugMessages.SetTrigger -f $scheduledTimeSpan, $scheduledDuration, $ScheduledAt, $Daily, $Once)
        $triggerParam =
        @{
            ScheduledTimeSpan = $scheduledTimeSpan
            ScheduledDuration = $scheduledDuration
            ScheduledAt = $ScheduledAt
            Daily = $Daily
            Once = $Once
        }
        $scheduleTaskParam.trigger = CreateTaskSchedulerTrigger @triggerParam
    }

    # settings
    $scheduleTaskParam.settings = if ($PSBoundParameters.ContainsKey('ExecuteTimeLimitTicks'))
    {
        New-ScheduledTaskSettingsSet -Disable:$Disable -Hidden:$Hidden -Compatibility $Compatibility -ExecutionTimeLimit (TicksToTimeSpan -Ticks $ExecuteTimeLimitTicks)
    }
    else
    {
        New-ScheduledTaskSettingsSet -Disable:$Disable -Hidden:$Hidden -Compatibility $Compatibility
    }

    # Register ScheduledTask
    $registerParam = GetRegisterParam -Credential $Credential -Runlevel $Runlevel -TaskName $TaskName -TaskPath $TaskPath -scheduleTaskParam $scheduleTaskParam
    Register-ScheduledTask @registerParam -Force > $null

    #endregion
}

function Test-TargetResource
{
    [OutputType([Bool])]
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure,

        [parameter(Mandatory = $true)]
        [System.String]$TaskName,

        [parameter(Mandatory = $false)]
        [System.String]$TaskPath = "\",

        [parameter(Mandatory = $false)]
        [System.String]$Description,

        [parameter(Mandatory = $false)]
        [System.String]$Execute,

        [parameter(Mandatory = $false)]
        [System.String]$Argument,

        [parameter(Mandatory = $false)]
        [System.String]$WorkingDirectory,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory = $false)]
        [ValidateSet("Highest","Limited")]
        [System.String]$Runlevel,

        [parameter(Mandatory = $false)]
        [ValidateSet("At","Win8","Win7","Vista","V1")]
        [System.String]$Compatibility,

        [parameter(Mandatory = $false)]
        [System.Int64]$ExecuteTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks,

        [parameter(Mandatory = $false)]
        [System.Boolean]$Hidden,

        [parameter(Mandatory = $true)]
        [System.Boolean]$Disable,

        [parameter(Mandatory = $false)]
        [System.DateTime[]]$ScheduledAt,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanDay = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanHour = 1,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledTimeSpanMin = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationDay = 1,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationHour = 0,

        [parameter(Mandatory = $false, parameterSetName = "ScheduledDuration")]
        [System.Int32[]]$ScheduledDurationMin = 0,

        [parameter(Mandatory = $false, parameterSetName = "Daily")]
        [System.Boolean]$Daily,

        [parameter(Mandatory = $false, parameterSetName = "Once")]
        [System.Boolean]$Once

    )

    $param = @{}

    # obtain other param
    @(
        'Ensure',
        'TaskName',
        'TaskPath'
        'Description', 
        'Execute', 
        'Argument', 
        'WorkingDirectory', 
        'Credential', 
        'Runlevel',
        'Compatibility',
        'ExecuteTimeLimitTicks',
        'Hidden',
        'Disable', 
        'ScheduledAt',
        'ScheduledTimeSpanDay',
        'ScheduledTimeSpanHour',
        'ScheduledTimeSpanMin',
        'ScheduledDurationDay',
        'ScheduledDurationHour',
        'ScheduledDurationMin',
        'Daily',
        'Once'
    ) `
    | where {$PSBoundParameters.ContainsKey($_)} `
    | %{ $param.$_ = Get-Variable -Name $_ -ValueOnly }
    
    return (Get-TargetResource @param).Ensure -eq $Ensure
}

#endregion

#region Validate Helper

function ValidateTaskPathLastChar ($taskPath)
{
    $lastChar = [System.Linq.Enumerable]::ToArray($taskPath) | select -Last 1
    if ($lastChar -ne "\"){ return $taskPath + "\" }
    return $taskPath
}

function ValidateSameFolderNotExist ($TaskName, $TaskPath)
{
    if (TestExistingTaskSchedulerWithPath -TaskName $TaskName -TaskPath $TaskPath){ throw New-Object System.InvalidOperationException ($errorMessages.SameNameFolderFound -f $taskName) }
}

#endregion

#region Create Helper

function CreateTaskSchedulerAction ($Argument, $Execute, $WorkingDirectory)
{
    if ($Execute -eq [string]::Empty){ throw New-Object System.InvalidOperationException ($errorMessages.ExecuteBrank) }

    $param = @{}
    $param.Execute = $Execute
    if ($Argument -ne [string]::Empty){ $param.Argument = $Argument }
    if ($WorkingDirectory -ne [string]::Empty){ $param.WorkingDirectory = $WorkingDirectory }
    return New-ScheduledTaskAction @param
}

function CreateTimeSpan
{
    param(
        [parameter(Mandatory = $false, Position  = 0)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Day,

        [parameter(Mandatory = $false, Position  = 1)]
        [ValidateNotNullOrEmpty()]
        [int[]]$Hour,

        [parameter(Mandatory = $false, Position  = 2)]
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

function CreateTaskSchedulerTrigger ($ScheduledTimeSpan, $ScheduledDuration, $ScheduledAt, $Daily, $Once)
{
    $trigger = if (($false -eq $Daily) -and ($false -eq $Once))
    {
        $ScheduledTimeSpanPair = New-ZipPairs -first $ScheduledTimeSpan -Second $ScheduledDuration
        $ScheduledAtPair = New-ZipPairs -first $ScheduledAt -Second $ScheduledTimeSpanPair
        $ScheduledAtPair `
        | %{
            if ($_.Item2.Item1 -ge $_.Item2.Item2){ throw New-Object System.InvalidOperationException ($errorMessages.InvalidTrigger -f $_.Item2.Item1, $_.Item2.Item2)}
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

#endregion

#region Convert Helper

function TicksToTimeSpan ([System.Int64]$Ticks)
{
    return [TimeSpan]::FromTicks($Ticks)
}

#endregion

#region Get Helper

function GetExistingTaskScheduler ($TaskName, $TaskPath)
{
    return Get-ScheduledTask | where TaskName -eq $taskName | where TaskPath -eq $taskPath
}

function GetRegisterParam ($Credential, $Runlevel, $TaskName, $TaskPath, $scheduleTaskParam)
{
    if (([PSCredential]::Empty -ne $Credential) -and ("SYSTEM" -ne $Credential.UserName))
    {
        Write-Debug $debugMessages.UsePrincipal
        # Principal
        $principalParam = 
        @{
            UserId = $Credential.UserName
            RunLevel = $Runlevel
            LogOnType = "InteractiveOrPassword"
        }
        $scheduleTaskParam.principal = New-ScheduledTaskPrincipal @principalParam

        # return
        return @{
            InputObject = New-ScheduledTask @scheduleTaskParam
            TaskName = $TaskName
            TaskPath = $TaskPath
            User = $Credential.UserName
            Password = $Credential.GetNetworkCredential().Password
        }
    }
    else
    {
        Write-Debug $debugMessages.SkipPrincipal
        $principalParam = 
        @{
            Id = "Author"
            UserId = "SYSTEM"
            RunLevel = $Runlevel
            LogOnType = "ServiceAccount"
            ProcessTokenSidType = "Default"
        }
        $scheduleTaskParam.principal = New-ScheduledTaskPrincipal @principalParam 

        # return
        return @{
            InputObject = New-ScheduledTask @scheduleTaskParam
            TaskName = $TaskName
            TaskPath = $TaskPath
        }

    }
}

#endregion

#region Test Helper

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

function TestScheduledTaskStatus
{
    [OutputType([HashTable])]
    [CmdletBinding(DefaultParameterSetName = "ScheduledDuration")]
    param
    (
        [parameter(Mandatory = 1, Position  = 0)]
        [string]$TaskName,
    
        [parameter(Mandatory = 0, Position  = 1)]
        [string]$TaskPath = "\",

        [parameter(Mandatory = 0, Position  = 2)]
        [string]$Execute,

        [parameter(Mandatory = 0, Position  = 3)]
        [string]$Argument,
    
        [parameter(Mandatory = 0, Position  = 4)]
        [string]$WorkingDirectory,

        [parameter(Mandatory = 0, Position  = 5)]
        [datetime[]]$ScheduledAt,

        [parameter(Mandatory = 0, Position  = 6, parameterSetName = "ScheduledDuration")]
        [TimeSpan[]]$ScheduledTimeSpan,

        [parameter(Mandatory = 0, Position  = 7, parameterSetName = "ScheduledDuration")]
        [TimeSpan[]]$ScheduledDuration,

        [parameter(Mandatory = 0, Position  = 8, parameterSetName = "Daily")]
        [bool]$Daily = $false,

        [parameter(Mandatory = 0, Position  = 9, parameterSetName = "Once")]
        [bool]$Once = $false,

        [parameter(Mandatory = 0, Position  = 10)]
        [string]$Description,

        [parameter(Mandatory = 0, Position  = 11)]
        [PScredential]$Credential,

        [parameter(Mandatory = 0, Position  = 12)]
        [bool]$Disable,

        [parameter(Mandatory = 0, Position  = 13)]
        [bool]$Hidden,

        [parameter(Mandatory = 0, Position  = 14)]
        [TimeSpan]$ExecutionTimeLimit,

        [parameter(Mandatory = 0,Position  = 15)]
        [ValidateSet("At", "Win8", "Win7", "Vista", "V1")]
        [string]$Compatibility,

        [parameter(Mandatory = 0,Position  = 16)]
        [ValidateSet("Highest", "Limited")]
        [string]$Runlevel
    )

    begin
    {
        function GetScheduledTask
        {
            [OutputType([HashTable])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [Microsoft.Management.Infrastructure.CimInstance[]]$ScheduledTask,

                [parameter(Mandatory = $true)]
                [string]$Parameter,

                [parameter(Mandatory = $true)]
                [string]$Value
            )

            Write-Debug ($debugMessages.CheckScheduleTaskExist -f $parameter, $Value)
            $task = $ScheduledTask | where $Parameter -eq $Value
            $uniqueValue = $task.$Parameter | sort -Unique
            $result = $uniqueValue -eq $Value
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $uniqueValue)
            return @{
                task = $task
                target = $uniqueValue
                result = $result
            }
        }

        function TestScheduledTask
        {
            [OutputType([bool])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

                [parameter(Mandatory = $true)]
                [ScheduledParameterType]$Type,

                [parameter(Mandatory = $true)]
                [string]$Parameter,

                [parameter(Mandatory = $false)]
                [PSObject]$Value,

                [bool]$IsExist
            )

            # skip when Parameter not use
            if ($IsExist -eq $false)
            {
                Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            # skip null
            if ($Value -eq $null)
            {
                Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            Write-Debug ($debugMessages.CheckScheduleTaskParameter -f $Parameter, $Value)
            $target = switch ($Type)
            {
                ([ScheduledParameterType]::Root)
                {
                    $ScheduledTask.$Parameter | sort -Unique
                }
                ([ScheduledParameterType]::Actions)
                {
                    $ScheduledTask.Actions.$Parameter | sort -Unique
                }
                ([ScheduledParameterType]::Principal)
                {
                    $ScheduledTask.Principal.$Parameter | sort -Unique
                }
                ([ScheduledParameterType]::Settings)
                {
                    $ScheduledTask.Settings.$Parameter | sort -Unique
                }
                ([ScheduledParameterType]::Triggers)
                {
                    $ScheduledTask.Triggers.$Parameter | sort -Unique
                }
            }
            
            if ($Value.GetType().FullName -eq [string].FullName)
            {
                if (($target -eq $null) -and ([string]::IsNullOrEmpty($Value)))
                {
                    return @{
                        target = $target
                        result = $true
                    }
                    Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
                }
            }

            # value check
            $result = $target -eq $Value
            Write-Debug ($debugMessages.ScheduleTaskResult -f $Parameter, $result, $target)
            return @{
                target = $target
                result = $result
            }
        }

        function TestScheduledTaskExecutionTimeLimit
        {
            [OutputType([bool])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

                [parameter(Mandatory = $false)]
                [PSObject]$Value,

                [bool]$IsExist
            )

            $private:parameter = "ExecutionTimeLimit"

            # skip when Parameter not use
            if ($IsExist -eq $false)
            {
                Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            # skip null
            if ($Value -eq $null)
            {
                Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            $Value = $Value -as [TimeSpan]
            Write-Debug ($debugMessages.CheckScheduleTaskParameterTimeSpan -f $parameter, $Value.TotalMinutes)
            $executionTimeLimitTimeSpan = [System.Xml.XmlConvert]::ToTimeSpan($ScheduledTask.Settings.$parameter)
            $result = $Value -eq $executionTimeLimitTimeSpan
            Write-Debug ($debugMessages.ScheduleTaskTimeSpanResult -f $parameter, $result, $executionTimeLimitTimeSpan.TotalMinutes)
            return @{
                target = $executionTimeLimitTimeSpan
                result = $result
            }
        }

        function TestScheduledTaskDisable
        {
            [OutputType([bool])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

                [parameter(Mandatory = $false)]
                [PSObject]$Value,

                [bool]$IsExist
            )

            # skip when Parameter not use
            if ($IsExist -eq $false)
            {
                Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            # convert Enable -> Disable
            $target = $ScheduledTask.Settings.Enabled -eq $false
            
            # value check
            Write-Debug ($debugMessages.CheckScheduleTaskParameter -f "Disable", $Value)
            $result = $target -eq $Value
            Write-Debug ($debugMessages.ScheduleTaskResult -f "Disable", $result, $target)
            return @{
                target = $target
                result = $result
            }
        }

        function TestScheduledTaskScheduledAt
        {
            [OutputType([bool])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

                [parameter(Mandatory = $false)]
                [DateTime[]]$Value,

                [bool]$IsExist
            )

            $private:parameter = "StartBoundary"

            # skip when Parameter not use
            if ($IsExist -eq $false)
            {
                Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            # skip null
            if ($Value -eq $null)
            {
                Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            $valueCount = ($Value | measure).Count
            $scheduleCount = ($ScheduledTask.Triggers | measure).Count
            if ($valueCount -ne $scheduleCount)
            {
                throw New-Object System.ArgumentException ($errorMessages.ScheduleAtArgumentLength -f $scheduleCount, $valueCount)
            }

            $result = $target = @()
            for ($i = 0; $i -le ($ScheduledTask.Triggers.$parameter.Count -1); $i++)
            {
                Write-Debug ($debugMessages.CheckScheduleTaskParameter -f $parameter, $Value[$i])
                $startBoundaryDateTime = [System.Xml.XmlConvert]::ToDateTime(@($ScheduledTask.Triggers.$parameter)[$i])
                $target += $startBoundaryDateTime
                $result += @($Value)[$i] -eq $startBoundaryDateTime
                Write-Debug ($debugMessages.ScheduleTaskResult -f $parameter, $result[$i], $startBoundaryDateTime)
            }
            return @{
                target = $target
                result = $result | sort -Unique
            }
        }

        function TestScheduledTaskScheduledRepetition
        {
            [OutputType([bool])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [Microsoft.Management.Infrastructure.CimInstance]$ScheduledTask,

                [parameter(Mandatory = $true)]
                [string]$Parameter,

                [parameter(Mandatory = $false)]
                [TimeSpan[]]$Value,

                [bool]$IsExist
            )

            # skip when Parameter not use
            if ($IsExist -eq $false)
            {
                Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            # skip null
            if ($Value -eq $null)
            {
                Write-Debug ($debugMessages.SkipNullPassedParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            $valueCount = ($Value | measure).Count
            $scheduleCount = ($ScheduledTask.Triggers | measure).Count
            if ($valueCount -ne $scheduleCount)
            {
                throw New-Object System.ArgumentException ($errorMessages.ScheduleRepetitionArgumentLength -f $scheduleCount, $valueCount)
            }

            $result = $target = @()
            for ($i = 0; $i -le ($ScheduledTask.Triggers.Repetition.$Parameter.Count -1); $i++)
            {
                Write-Debug ($debugMessages.CheckScheduleTaskParameter -f $Parameter, $Value[$i])
                $repetition = [System.Xml.XmlConvert]::ToTimeSpan(@($ScheduledTask.Triggers.Repetition.$Parameter)[$i])
                $target += $repetition
                $result = @($Value)[$i] -eq $repetition
                Write-Debug ($verboseMessages.ScheduleTaskResult -f $Parameter, $result[$i], $target.TotalMinutes)
            }
            return @{
                target = $target
                result = $result | sort -Unique
            }
        }

        function TestScheduledTaskTriggerBy
        {
            [OutputType([bool])]
            [CmdletBinding()]
            param
            (
                [parameter(Mandatory = $true)]
                [System.Xml.XmlDocument]$ScheduledTaskXml,

                [parameter(Mandatory = $true)]
                [string]$Parameter,

                [parameter(Mandatory = $false)]
                [PSObject]$Value,

                [bool]$IsExist
            )

            # skip when Parameter not use
            if ($IsExist -eq $false)
            {
                Write-Debug ($debugMessages.SkipNoneUseParameter -f $Parameter)
                return @{
                    target = $null
                    result = $true
                }
            }

            $trigger = ($ScheduledTaskXml.task.Triggers.CalendarTrigger.ScheduleByDay | measure).Count
            $result = $false
            switch ($Parameter)
            {
                "Daily"
                {
                    Write-Debug $debugMessages.CheckSchedulerDaily
                    $result = if ($Value)
                    {
                        $trigger -ne 0
                    }
                    else
                    {
                        $trigger-eq 0
                    }
                    Write-Debug ($verboseMessages.ScheduleTaskResult -f $Parameter, $result, $trigger)
                }
                "Once"
                {
                    Write-Debug $debugMessages.CheckSchedulerOnce
                    $result = if ($Value)
                    {
                        $trigger -eq 0
                    }
                    else
                    {
                        $trigger -ne 0
                    }
                    Write-Debug ($verboseMessages.ScheduleTaskResult -f $Parameter, $result, $trigger)
                }
            }
            return @{
                target = $result
                result = $result
            }
        }
    }
    
    end
    {
        #region Root

            $returnHash = [ordered]@{}

            # get whole task
            $root = Get-ScheduledTask

            # TaskPath
            $returnHash.TaskPath = GetScheduledTask -ScheduledTask $root -Parameter TaskPath -Value $TaskPath
            if ($null -eq $returnHash.TaskPath.task)
            {
                foreach ($item in [Enum]::GetNames([ScheduledTaskPropertyType]))
                {
                    $returnHash.$item = @{target = $null; result = $true}
                }
                return $returnHash;
            }

            # TaskName
            $returnHash.TaskName = GetScheduledTask -ScheduledTask $returnHash.TaskPath.task -Parameter Taskname -Value $TaskName

            # default
            $current = $returnHash.TaskName.task
            if (($current | measure).Count -eq 0){ return $returnHash }

            # export as xml
            [xml]$script:xml = Export-ScheduledTask -TaskName $current.TaskName -TaskPath $current.TaskPath

            # Description
            $returnHash.Description = TestScheduledTask -ScheduledTask $current -Parameter Description -Value $Description -Type ([ScheduledParameterType]::Root) -IsExist ($PSBoundParameters.ContainsKey('Description'))

        #endregion

        #region Action

            # Execute
            $returnHash.Execute = TestScheduledTask -ScheduledTask $current -Parameter Execute -Value $Execute -Type ([ScheduledParameterType]::Actions) -IsExist ($PSBoundParameters.ContainsKey('Execute'))

            # Arguments
            $returnHash.Argument = TestScheduledTask -ScheduledTask $current -Parameter Arguments -Value $Argument -Type ([ScheduledParameterType]::Actions) -IsExist ($PSBoundParameters.ContainsKey('Argument'))

            # WorkingDirectory
            $returnHash.WorkingDirectory = TestScheduledTask -ScheduledTask $current -Parameter WorkingDirectory -Value $WorkingDirectory -Type ([ScheduledParameterType]::Actions) -IsExist ($PSBoundParameters.ContainsKey('WorkingDirectory'))

        #endregion

        #region Principal

            # UserId
            $returnHash.Credential = TestScheduledTask -ScheduledTask $current -Parameter UserId -Value $Credential.UserName -Type ([ScheduledParameterType]::Principal) -IsExist ($PSBoundParameters.ContainsKey('Credential'))

            # RunLevel
            $returnHash.RunLevel = TestScheduledTask -ScheduledTask $current -Parameter RunLevel -Value $Runlevel -Type ([ScheduledParameterType]::Principal) -IsExist ($PSBoundParameters.ContainsKey('Runlevel'))

        #endregion

        #region Settings

            # Compatibility
            $returnHash.Compatibility = TestScheduledTask -ScheduledTask $current -Parameter Compatibility -Value $Compatibility -Type ([ScheduledParameterType]::Settings) -IsExist ($PSBoundParameters.ContainsKey('Compatibility'))

            # ExecutionTimeLimit
            $returnHash.ExecutionTimeLimit = TestScheduledTaskExecutionTimeLimit -ScheduledTask $current -Value $ExecutionTimeLimit -IsExist ($PSBoundParameters.ContainsKey('ExecutionTimeLimit'))

            # Hidden
            $returnHash.Hidden = TestScheduledTask -ScheduledTask $current -Parameter Hidden -Value $Hidden -Type ([ScheduledParameterType]::Settings) -IsExist ($PSBoundParameters.ContainsKey('Hidden'))

            # Disable
            $returnHash.Disable = TestScheduledTaskDisable -ScheduledTask $current -Value $Disable -IsExist ($PSBoundParameters.ContainsKey('Disable'))

        #endregion

        #region Triggers

            # SchduledAt
            $returnHash.ScheduledAt = TestScheduledTaskScheduledAt -ScheduledTask $current -Value $ScheduledAt -IsExist ($PSBoundParameters.ContainsKey('ScheduledAt'))

            # ScheduledTimeSpan (Repetition Interval)
            $returnHash.ScheduledTimeSpan = TestScheduledTaskScheduledRepetition -ScheduledTask $current -Value $ScheduledTimeSpan -Parameter Interval -IsExist ($PSBoundParameters.ContainsKey('ScheduledTimeSpan'))

            # ScheduledDuration (Repetition Duration)
            $returnHash.ScheduledDuration = TestScheduledTaskScheduledRepetition -ScheduledTask $current -Value $ScheduledDuration -Parameter Duration -IsExist ($PSBoundParameters.ContainsKey('ScheduledDuration'))

            # Daily
            $returnHash.Daily = TestScheduledTaskTriggerBy -ScheduledTaskXml $xml -Parameter Daily -Value $Daily -IsExist ($PSBoundParameters.ContainsKey('Daily'))

            # Once
            $returnHash.Once = TestScheduledTaskTriggerBy -ScheduledTaskXml $xml -Parameter Once -Value $Once -IsExist ($PSBoundParameters.ContainsKey('Once'))

        #endregion

        return $returnHash
    }
}

#endregion

#region Remove Helper

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

#endregion

#region Extension Helper

function New-ZipPairs
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $false, Position = 0, ValueFromPipeline = 1, ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]$first,
 
        [parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = 1)]
        [PSObject[]]$second,

        [parameter(Mandatory = $false, Position = 2, ValueFromPipelineByPropertyName = 1)]
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

#endregion

Export-ModuleMember -Function *-TargetResource