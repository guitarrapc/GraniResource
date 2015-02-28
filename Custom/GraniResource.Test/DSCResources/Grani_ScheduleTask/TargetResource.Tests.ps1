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
    $scheduledAt = [datetime]"0:0:0"
    $scheduledTimeSpanDay = 0
    $scheduledTimeSpanHour = 1
    $scheduledTimeSpanMin = 0
    $scheduledDurationDay = 1
    $scheduledDurationHour = 0
    $scheduledDurationMin = 0
    $once = $true
    $daily = $true

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

        It "Set-TargetResource should Throw as Ensure : $ensure, ScheduledAt : null" {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Disable $disable -Execute $execute} | should Throw
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
        It "Set-TargetResource Present should Throw as ScheduledTimespan and Daily use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin -Daily $daily} | should Throw
        }

        It "Set-TargetResource Present should Throw as ScheduledTimespan and Once use same time." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin -Once $once} | should Throw
        }

        It "Set-TargetResource Present should not Throw." {
            {Set-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin} | should not Throw
        }

        It "Test-TargetResource should return true as Ensure : $ensure" {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $true
        }
    }

    Context "Get Each returned value as is matched with passed parameter." {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin} | should not Throw
        }

        $result = Get-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin

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
            $result.Credential | should be $credential.UserName
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

        It "Get-TargetResource should return ScheduledTimeSpanDay : $scheduledTimeSpanDay" {
            $result.ScheduledTimeSpanDay | should be $scheduledTimeSpanDay
        }

        It "Get-TargetResource should return ScheduledTimeSpanHour : $scheduledTimeSpanHour" {
            $result.ScheduledTimeSpanHour | should be $scheduledTimeSpanHour
        }

        It "Get-TargetResource should return ScheduledTimeSpanMin : $scheduledTimeSpanMin" {
            $result.ScheduledTimeSpanMin | should be $scheduledTimeSpanMin
        }

        It "Get-TargetResource should return ScheduledDurationDay : $scheduledDurationDay" {
            $result.ScheduledDurationDay | should be $scheduledDurationDay
        }

        It "Get-TargetResource should return ScheduledDurationHour : $scheduledDurationHour" {
            $result.ScheduledDurationHour | should be $scheduledDurationHour
        }

        It "Get-TargetResource should return ScheduledDurationMin : $scheduledDurationMin" {
            $result.ScheduledDurationMin | should be $scheduledDurationMin
        }
    }

    Context "Test existing Settings is detected as false for each not same passed parameters." {
        It "Test-TargetResource should return false for invalid Description." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description "" -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid Execute." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute hoge -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid Argument." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument hoge -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid WorkingDirectory." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory hoge -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid Credential." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential (Get-Credential) -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid RunLevel." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel Highest -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid Compatibility." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility Win7 -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid ExecuteTimeLimitTicks." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks 0 -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid Hidden." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $false -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid Disable." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $true -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid ScheduledAt." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt.AddHours(1) -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid scheduledTimeSpanDay." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay ($scheduledTimeSpanDay + 1) -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid scheduledTimeSpanHour." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour ($scheduledTimeSpanHour + 1) -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid scheduledTimeSpanMin." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin ($scheduledTimeSpanMin + 1) -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid ScheduledDurationDay." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay ($scheduledDurationDay + 1) -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid ScheduledDurationHour." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour ($scheduledDurationHour + 1) -ScheduledDurationMin $scheduledDurationMin | should be $false
        }

        It "Test-TargetResource should return false for invalid scheduledTimeSpanHour." {
            Test-TargetResource -Ensure $ensure -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin ($scheduledDurationMin + 1) | should be $false
        }
    }

    Context "Remove existing Settings." {
        It "Set-TargetResource Absent should not Throw." {
            {Set-TargetResource -Ensure Absent -TaskPath $taskPath -TaskName $taskName -Description $description -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory -Credential $credential -Runlevel $runlevel -Compatibility $compatibility -ExecuteTimeLimitTicks $executeTimeLimitTicks -Hidden $hidden -Disable $disable -ScheduledAt $scheduledAt -scheduledTimeSpanDay $scheduledTimeSpanDay -scheduledTimeSpanHour $scheduledTimeSpanHour -ScheduledTimeSpanMin $scheduledTimeSpanMin -ScheduledDurationDay $scheduledDurationDay -ScheduledDurationHour $scheduledDurationHour -ScheduledDurationMin $scheduledDurationMin} | should not Throw
        }
    }
}


