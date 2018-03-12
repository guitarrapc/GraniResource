$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScriptOnOSVersion : TargetResource" {

    # Definition
    $key = "hogehoge"
    $credential = Get-Credential
    $executeOnPlatform = [System.Environment]::OSVersion.Platform
    $executeOnVersion = [Version]::Parse("10.0.16299.0").ToString()
    $whenLT = "LessThan"
    $whenLE = "LessThanEqual"
    $whenEQ = "Equal"
    $whenNEQ = "NotEqual"
    $whenGT = "GreaterThan"
    $whenGE = "GreaterThanEqual"

    Context "Scratch environment with Credential." {
        BeforeAll {
            [string]$setScript = {[System.Environment]::SetEnvironmentVariable("Grani_ScriptOnOSVersion", "1", [System.EnvironmentVariableTarget]::User)}
            [string]$testScript = {[System.Environment]::GetEnvironmentVariable("Grani_ScriptOnOSVersion", [System.EnvironmentVariableTarget]::User) -eq "1"}

            if ($null -ne [System.Environment]::GetEnvironmentVariable("Grani_ScriptOnOSVersion", [System.EnvironmentVariableTarget]::User)) {
                [System.Environment]::SetEnvironmentVariable("Grani_ScriptOnOSVersion", $null, [System.EnvironmentVariableTarget]::User)
            }
            
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)

            if ($null -ne [System.Environment]::GetEnvironmentVariable("Grani_ScriptOnOSVersion", [System.EnvironmentVariableTarget]::User)) {
                [System.Environment]::SetEnvironmentVariable("Grani_ScriptOnOSVersion", $null, [System.EnvironmentVariableTarget]::User)
            }
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should not throw with less parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should throw when omit key parameter" {
            {Get-TargetResource -Key $null -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT} | Should Throw
        }

        It "Get-TargetResource should throw when omit required parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $null -ExecuteOnVersion $null -When $null} | Should Throw
        }

        $get = Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return ExecuteOnPlatform : $ExecuteOnPlatform" {
            $get.ExecuteOnPlatform | Should be $executeOnPlatform
        }

        It "Get-TargetResource should return ExecuteOnVersion : $ExecuteOnVersion" {
            $get.ExecuteOnVersion | Should be $executeOnVersion
        }

        It "Get-TargetResource should return SetScript : $setScript" {
            $get.SetScript | Should be $setScript
        }

        It "Get-TargetResource should return TestScript : $testScript" {
            $get.TestScript | Should be $testScript
        }

        It "Get-TargetResource should return When : $whenLT" {
            $get.When | Should be $whenLT
        }

        It "Test-TargetResource Present should return false" {
           Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $false
        }

        It "Set-TargetResource Present should not Throw" {
            {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ} | should not Throw
        }

        It "Test-TargetResource Present should return true on eq" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $true
         }

         It "Test-TargetResource Present should return false on lt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT | should be $false
         }

         It "Test-TargetResource Present should return true on le" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLE | should be $true
         }

         It "Test-TargetResource Present should return false on gt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenGT | should be $false
         }

         It "Test-TargetResource Present should return true on ge" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenGE | should be $true
         }
    }

    Context "Scratch environment without Credential." {
        BeforeAll {
            [string]$setScript = {Set-Item -Path Env:Grani_ScriptOnOSVersion -Value 1}
            [string]$testScript = {(Test-Path Env:Grani_ScriptOnOSVersion) -and (Get-Item -Path Env:Grani_ScriptOnOSVersion).Value -eq 1}

            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should not throw with less parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should throw when omit key parameter" {
            {Get-TargetResource -Key $null -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT} | Should Throw
        }

        It "Get-TargetResource should throw when omit required parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $null -ExecuteOnVersion $null -When $null} | Should Throw
        }

        $get = Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return ExecuteOnPlatform : $ExecuteOnPlatform" {
            $get.ExecuteOnPlatform | Should be $executeOnPlatform
        }

        It "Get-TargetResource should return ExecuteOnVersion : $ExecuteOnVersion" {
            $get.ExecuteOnVersion | Should be $executeOnVersion
        }

        It "Get-TargetResource should return SetScript : $setScript" {
            $get.SetScript | Should be $setScript
        }

        It "Get-TargetResource should return TestScript : $testScript" {
            $get.TestScript | Should be $testScript
        }

        It "Get-TargetResource should return When : $whenLT" {
            $get.When | Should be $whenLT
        }

        It "Test-TargetResource Present should return false" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $false
         }
 
         It "Set-TargetResource Present should not Throw" {
             {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ} | should not Throw
         }
 
         It "Test-TargetResource Present should return true" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $true
          }
 
          It "Test-TargetResource Present should return false on lt" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLT | should be $false
          }
 
          It "Test-TargetResource Present should return true on le" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenLE | should be $true
          }
 
          It "Test-TargetResource Present should return false on gt" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenGT | should be $false
          }
 
          It "Test-TargetResource Present should return true on ge" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenGE | should be $true
          }
     }

    Context "Change existing settings." {
        BeforeAll {
            [string]$setScript = {Set-Item -Path Env:Grani_ScriptOnOSVersion -Value 1}
            [string]$testScript = {(Test-Path Env:Grani_ScriptOnOSVersion) -and (Get-Item -Path Env:Grani_ScriptOnOSVersion).Value -eq 1}

            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)

            if (Test-Path Env:Grani_ScriptOnOSVersion) {
                Remove-Item -Path Env:Grani_ScriptOnOSVersion
            }
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ} | should not Throw
        }
        
        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $true
        }
    }

    Context "Less version settings." {
        BeforeAll {
            $executeOnPlatform = [System.Environment]::OSVersion.Platform
            $executeOnVersion = [Version]::Parse("10.0.0.0").ToString()
            [string]$setScript = {Set-Item -Path Env:Grani_ScriptOnOSVersion -Value 1}
            [string]$testScript = {(Test-Path Env:Grani_ScriptOnOSVersion) -and (Get-Item -Path Env:Grani_ScriptOnOSVersion).Value -eq 1}

            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)

            if (Test-Path Env:Grani_ScriptOnOSVersion) {
                Remove-Item -Path Env:Grani_ScriptOnOSVersion
            }
        }

        It "Test-TargetResource Absent should return false on eq" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $false
        }

        It "Test-TargetResource Absent should return false on noteq" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenNEQ | should be $false
        }

        It "Test-TargetResource Absent should return false on lt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenLT | should be $false
        }

        It "Test-TargetResource Absent should return false on le" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenLT | should be $false
        }

        It "Test-TargetResource Absent should return false on gt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenGT | should be $false
        }

        It "Test-TargetResource Absent should return false on ge" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenGE | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ} | should not Throw
        }
        
        It "Test-TargetResource Absent should return false on eq" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $WhenEQ | should be $false
        }

        It "Test-TargetResource Absent should return true on noteq" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenNEQ | should be $true
        }

        It "Test-TargetResource Absent should return false on lt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenLT | should be $false
        }

        It "Test-TargetResource Absent should return false on le" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenLT | should be $false
        }

        It "Test-TargetResource Absent should return true on gt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenGT | should be $true
        }

        It "Test-TargetResource Absent should return true on ge" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersion $executeOnVersion -When $whenGE | should be $true
        }
    }
}
