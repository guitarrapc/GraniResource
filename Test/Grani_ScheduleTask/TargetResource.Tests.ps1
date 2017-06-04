$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScheduleTask : TargetResource" {

    $ensure = "Present"
    $taskName = "hoge"
    $taskPath = "\"
    $description = "hoge"
    $execute = "powershell.exe"
    $argument = "-Command 'Get-Date'"
    $workingDirectory = "c:\hoge"
    $credential = Get-Credential
    $runlevel = "limited"
    $compatibility = "Win8"
    $executeTimeLimitTicks = [TimeSpan]::FromDays(3).Ticks
    $hidden = $true
    $disable = $false
    $scheduledAt = [datetime]"00:00:00"
    $repetitionIntervalTimeSpanString = [TimeSpan]::FromHours(1).ToString()
    $repetitionDurationTimeSpanString = [TimeSpan]::FromDays(1).ToString()
    $emptyRepetitionIntervalTimeSpanString = ""
    $emptyRepetitionDurationTimeSpanString = ""
    $once = $true
    $daily = $true
    $atStartup = $true
    $atLogOn = $true
    #$atLogOnUserId = "test"
    $atLogOnUserId = "WINDOWS10PRO\admin"

    Context "Scratch environment with simple parameters." {

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $Ensure -TaskPath $taskPath -TaskName $TaskName -Disable $true} | Should not Throw
        }

        $schedule = Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Disable $disable
        It "Get-TargetResource should return Ensure : Absent" {
            $schedule.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return TaskPath : $taskPath" {
            $schedule.TaskPath | Should be $taskPath
        }

        It "Get-TargetResource should return TaskName : null" {
            $schedule.TaskName | Should be $null
        }

        It "Test-TargetResource Present should return false" {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Disable $disable | should be $false
        }

        It "Test-TargetResource Absent should return true as Ensure : Absent" {
            Test-TargetResource -Ensure Absent -TaskPath $taskPath -TaskName $taskName -Disable $disable | should be $true
        }

        It "Set-TargetResource should Throw as Ensure : $ensure, Execute : null" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Disable $disable} | should Throw
        }

        It "Set-TargetResource Present should not Throw as Ensure : $ensure, ScheduledAt : $scheduledAt" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute} | should not Throw
        }
    }

    Context "Already configured environment." {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $Ensure -TaskPath $taskPath -TaskName $TaskName -ScheduledAt $scheduledAt -Disable $disable} | Should not Throw
        }

        It "Get-TargetResource should return Ensure : $ensure" {
            (Get-TargetResource -Ensure $Ensure -TaskPath $taskPath -TaskName $TaskName -ScheduledAt $scheduledAt -Disable $disable).Ensure | Should be $ensure
        }

        It "Test-TargetResource should return false as Ensure : Absent" {
            Test-TargetResource -Ensure Absent -TaskPath $taskPath -TaskName $taskName -Disable $disable | should be $false
        }

        It "Test-TargetResource should return true as Ensure : $ensure" {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute | should be $true
        }
    }

    Context "Remove existing Settings." {
        It "Set-TargetResource Absent should not Throw" {
            {Set-TargetResource -Ensure Absent -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute} | should not Throw
        }
        
        It "Test-TargetResource should return false as Ensure : $ensure" {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Disable $disable | should be $false
        }

        It "Test-TargetResource should return true as Ensure : Absent" {
            Test-TargetResource -Ensure Absent -TaskPath $taskPath -TaskName $taskName -Disable $disable | should be $true
        }
    }

    Context "Scratch environment with Complex parameters." {
        It "Set-TargetResource Present should Throw as RepetitionInterval and Daily use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString -Daily $daily} | should Throw
        }

        It "Set-TargetResource Present should Throw as RepetitionInterval and Once use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString -Once $once} | should Throw
        }

        It "Set-TargetResource Present should Throw as RepetitionInterval and AtStartup use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString -AtStartup $atStartup} | should Throw
        }

        It "Set-TargetResource Present should not Throw when RepetitionInterval and AtLogOn use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString -AtLogOn $atLogOn} | should Throw
        }

        It "Set-TargetResource Present should not Throw when ScheduleAt and AtStartup use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -AtStartup $atStartup} | should not Throw
        }

        It "Set-TargetResource Present should Throw as ScheduleAt and AtLogOn use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -AtLogOn $atLogOn} | should not Throw
        }

        It "Set-TargetResource Present should not Throw." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString} | should not Throw
        }

        It "Test-TargetResource should return true as Ensure : $ensure" {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $true
        }
    }

    Context "Get Each returned value as is matched with passed parameter." {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString} | should not Throw
        }

        $result = Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString

        It "Get-TargetResource should return Ensure : $ensure" {
            $result.Ensure | should be $ensure
        }

        It "Get-TargetResource should return TaskName : $taskName" {
            $result.TaskName | should be $taskName
        }

        It "Get-TargetResource should return TaskPath : $taskPath" {
            $result.TaskPath | should be $taskPath
        }

        It "Get-TargetResource should return Description : $description" {
            $result.Description | should be $description
        }

        It "Get-TargetResource should return Execute : $execute" {
            $result.Execute | should be $execute
        }

        It "Get-TargetResource should return Argument : $argument" {
            $result.Argument | should be $argument
        }

        It "Get-TargetResource should return WorkingDirectory : $workingDirectory" {
            $result.WorkingDirectory | should be $workingDirectory
        }

        It "Get-TargetResource should return Credential : $($credential.UserName)" {
            $result.Credential.UserName | should be $credential.UserName
        }

        It "Get-TargetResource should return Runlevel : $runlevel" {
            $result.Runlevel | should be $runlevel
        }

        It "Get-TargetResource should return Compatibility : $compatibility" {
            $result.Compatibility | should be $compatibility
        }

        It "Get-TargetResource should return ExecuteTimeLimitTicks : $executeTimeLimitTicks" {
            $result.ExecuteTimeLimitTicks | should be $executeTimeLimitTicks
        }

        It "Get-TargetResource should return Hidden : $hidden" {
            $result.Hidden | should be $hidden
        }

        It "Get-TargetResource should return Disable : $disable" {
            $result.Disable | should be $disable
        }

        It "Get-TargetResource should return ScheduledAt : $scheduledAt" {
            $result.ScheduledAt | should be $scheduledAt
        }

        It "Get-TargetResource should return RepetitionInterval : $repetitionIntervalTimeSpanString" {
            $result.RepetitionIntervalTimeSpanString | should be $repetitionIntervalTimeSpanString
        }

        It "Get-TargetResource should return RepetitionDuration : $repetitionDurationTimeSpanString" {
            $result.RepetitionDurationTimeSpanString | should be $repetitionDurationTimeSpanString
        }
    }

    Context "Test existing Settings is detected as false for each not same passed parameters." {
        It "Test-TargetResource should return false for invalid Description." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description "" -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid Execute." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute hoge -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid Argument." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument hoge -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid WorkingDirectory." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory hoge -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid Credential." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential (Get-Credential) -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid RunLevel." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel Highest -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid Compatibility." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility Win7 -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid ExecuteTimeLimitTicks." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks 0 -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid Hidden." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $false -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid Disable." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $true -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid ScheduledAt." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt.AddHours(1) -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid RepetitionInterval Day." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString ([TimeSpan]$repetitionIntervalTimeSpanString + [TimeSpan]::FromDays(1)).ToString() -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid RepetitionInterval Hour." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString ([TimeSpan]$repetitionIntervalTimeSpanString + [TimeSpan]::FromHours(1)).ToString() -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid RepetitionInterval Min." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString ([TimeSpan]$repetitionIntervalTimeSpanString + [TimeSpan]::FromMinutes(1)).ToString() -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString | should be $false
        }

        It "Test-TargetResource should return false for invalid RepetitionDuration Day." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString ([TimeSpan]$repetitionDurationTimeSpanString + [TimeSpan]::FromDays(1)).ToString() | should be $false
        }

        It "Test-TargetResource should return false for invalid RepetitionDuration Hour." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString ([TimeSpan]$repetitionDurationTimeSpanString + [TimeSpan]::FromHours(1)).ToString() | should be $false
        }

        It "Test-TargetResource should return false for invalid RepetitionInterval Hour." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString ([TimeSpan]$repetitionDurationTimeSpanString + [TimeSpan]::FromMinutes(1)).ToString() | should be $false
        }
    }

    Context "Overwrite Credential ScheduleTask with non Credential ScheduleTask." {
        It "Set-TargetResource Present should not Throw as Ensure : $ensure, ScheduledAt : $scheduledAt" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute} | should not Throw
        }

        It "Test-TargetResource should return true." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute | should be $true
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute} | should not Throw
        }
    }

    Context "Try Empty Repetition" {
        It "Set-TargetResource Present should Throw as Ensure : $ensure, ScheduledAt : $scheduledAt, RepetitionIntervalTimeSpanString : $emptyrepetitionIntervalTimeSpanString, RepetitionDuration : $emptyRepetitionDuration" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -ScheduledAt $scheduledAt -Disable $disable -Execute $execute -RepetitionIntervalTimeSpanString $emptyRepetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $emptyrepetitionDurationTimeSpanString} | should Throw
        }
    }

    Context "Try AtLogon" {
        It "Set-TargetResource Present should not Throw as Ensure : $ensure, AtLogon : $atLogOn, Credential : $null" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -Disable $disable -Execute $execute} | should not Throw
        }

        It "Test-TargetResource should return true." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -Disable $disable -Execute $execute | should be $true
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -Disable $disable -Execute $execute} | should not Throw
        }

        It "Test-TargetResource should return false." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $credential.UserName -Disable $disable -Execute $execute -Credential $credential | should be $false
        }

        It "Set-TargetResource Present should not Throw as Ensure : $ensure, AtLogon : $atLogOn, Credential : $($credential.UserName), AtLogOnUserId : $atLogOnUserId" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $atLogOnUserId -Disable $disable -Execute $execute -Credential $credential} | should not Throw
        }

        It "Test-TargetResource should return true." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $atLogOnUserId -Disable $disable -Execute $execute -Credential $credential | should be $true
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $atLogOnUserId -Disable $disable -Execute $execute -Credential $credential} | should not Throw
        }

        It "Test-TargetResource should return false." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $credential.UserName -Disable $disable -Execute $execute -Credential $credential | should be $false
        }

        It "Set-TargetResource Present should not Throw as Ensure : $ensure, AtLogon : $atLogOn, Credential : $($credential.UserName), AtLogOnUserId : $atLogOnUserId" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $atLogOnUserId -Disable $disable -Execute $execute -Credential $credential} | should not Throw
        }

        It "Test-TargetResource should return true." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $atLogOnUserId -Disable $disable -Execute $execute -Credential $credential | should be $true
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -AtLogOnUserId $atLogOnUserId -Disable $disable -Execute $execute -Credential $credential} | should not Throw
        }

        It "Test-TargetResource should return true when Specific User require to be AnyUser. Because you are not checking!" {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -AtLogon $atLogOn -Disable $disable -Execute $execute -Credential $credential | should be $true
        }
    }

    Context "Remove existing Settings." {
        It "Set-TargetResource Absent should not Throw." {
            {Set-TargetResource -Ensure Absent -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -RepetitionIntervalTimeSpanString $repetitionIntervalTimeSpanString -RepetitionDurationTimeSpanString $repetitionDurationTimeSpanString} | should not Throw
        }
    }
}

