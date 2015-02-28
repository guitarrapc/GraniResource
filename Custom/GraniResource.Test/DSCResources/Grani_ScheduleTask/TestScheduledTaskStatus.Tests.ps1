$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScheduleTask : TestScheduledTaskStatus" {

    $taskName = "hoge"
    $taskPath = "\"
    $execute = "powershell.exe"
    $argument = "-Command 'Get-Date'"
    $workingDirectory = "c:\hoge"
    $disable = $false
    $scheduledAt = [datetime]"0:0:0"

    Context "Scratch environment." {

        It "TestScheduledTaskStatus should not throw" {
            {TestScheduledTaskStatus -TaskName $taskName -TaskPath $taskPath -Disable $true} | Should not Throw
        }

        It "TestScheduledTaskStatus should contains false" {
            (((TestScheduledTaskStatus -TaskName $TaskName -Disable $true).GetEnumerator() | %{$_.Value.result}) -contains $false) | Should be $true
        }

        It "Register scheduledTask -> TestScheduledTaskStatus should not contains false" {
            $action = New-ScheduledTaskAction -Execute $execute -Argument $argument -WorkingDirectory $workingDirectory
            $trigger = New-ScheduledTaskTrigger -At $scheduledAt -Once
            Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Action $action -Trigger $trigger -Force
            (((TestScheduledTaskStatus -TaskName $taskName -Disable $disable).GetEnumerator() | %{$_.Value.result}) -contains $false) | Should be $false
        }

        It "Disable scheduledTask -> TestScheduledTaskStatus should contains false" {
            Get-ScheduledTask -TaskName $taskName -TaskPath $TaskPath | Disable-ScheduledTask
            (((TestScheduledTaskStatus -TaskName $taskName -TaskPath $taskPath -Disable $true).GetEnumerator() | %{$_.Value.result}) -contains $false) | Should be $false
        }

        Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false
    }
}
