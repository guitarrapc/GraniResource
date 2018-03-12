$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScriptOnOSVersion : TargetResource" {

    # Definition
    $key = "hogehoge"
    [string]$setScript = {Set-Item -Path Env:Grani_ScriptOnOSVersion -Value 1}
    [string]$testScript = {(Test-Path Env:Grani_ScriptOnOSVersion) -and (Get-Item -Path Env:Grani_ScriptOnOSVersion).Value -eq 1}
    $credential = Get-Credential
    $executeOnPlatform = [System.Environment]::OSVersion.Platform
    $executeOnVersionString = [Version]::Parse("10.0.16299.0").ToString()
    $whenLT = "LessThan"
    $whenLE = "LessThanEqual"
    $whenEQ = "Equal"
    $whenNEQ = "NotEqual"
    $whenGT = "GreaterThan"
    $whenGE = "GreaterThanEqual"

    Context "Scratch environment with Credential." {
        BeforeAll {
            # [DebuggerStrings]::Culture にInvariantCultureに設定(要リフレクション)
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            # テストが終わったら元の設定(CurrentUICulture)に戻す
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)

            if (Test-Path Env:Grani_ScriptOnOSVersion) {
                Remove-Item -Path Env:Grani_ScriptOnOSVersion
            }
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should not throw with less parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should throw when omit key parameter" {
            {Get-TargetResource -Key $null -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT} | Should Throw
        }

        It "Get-TargetResource should throw when omit required parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $null -ExecuteOnVersionString $null -When $null} | Should Throw
        }

        $get = Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return ExecuteOnPlatform : $ExecuteOnPlatform" {
            $get.ExecuteOnPlatform | Should be $executeOnPlatform
        }

        It "Get-TargetResource should return ExecuteOnVersionString : $ExecuteOnVersionString" {
            $get.ExecuteOnVersionString | Should be $executeOnVersionString
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
           Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ | should be $false
        }

        It "Set-TargetResource Present should not Throw" {
            {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ} | should not Throw
        }

        It "Test-TargetResource Present should return true" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ | should be $true
         }

         It "Test-TargetResource Present should return false on lt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT | should be $false
         }

         It "Test-TargetResource Present should return true on le" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLE | should be $true
         }

         It "Test-TargetResource Present should return false on gt" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenGT | should be $false
         }

         It "Test-TargetResource Present should return true on ge" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -Credential $credential -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenGE | should be $true
         }
    }

     Context "Scratch environment without Credential." {
        BeforeAll {
            # [DebuggerStrings]::Culture にInvariantCultureに設定(要リフレクション)
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            # テストが終わったら元の設定(CurrentUICulture)に戻す
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)
        }

        It "Get-TargetResource should not throw" {
            {Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should not throw with less parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT} | Should not Throw
        }

        It "Get-TargetResource should throw when omit key parameter" {
            {Get-TargetResource -Key $null -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT} | Should Throw
        }

        It "Get-TargetResource should throw when omit required parameter" {
            {Get-TargetResource -Key $key -ExecuteOnPlatform $null -ExecuteOnVersionString $null -When $null} | Should Throw
        }

        $get = Get-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT
        It "Get-TargetResource should return Ensure : Absent" {
            $get.Ensure | Should be "Absent"
        }

        It "Get-TargetResource should return ExecuteOnPlatform : $ExecuteOnPlatform" {
            $get.ExecuteOnPlatform | Should be $executeOnPlatform
        }

        It "Get-TargetResource should return ExecuteOnVersionString : $ExecuteOnVersionString" {
            $get.ExecuteOnVersionString | Should be $executeOnVersionString
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
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ | should be $false
         }
 
         It "Set-TargetResource Present should not Throw" {
             {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ} | should not Throw
         }
 
         It "Test-TargetResource Present should return true" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ | should be $true
          }
 
          It "Test-TargetResource Present should return false on lt" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLT | should be $false
          }
 
          It "Test-TargetResource Present should return true on le" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenLE | should be $true
          }
 
          It "Test-TargetResource Present should return false on gt" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenGT | should be $false
          }
 
          It "Test-TargetResource Present should return true on ge" {
             Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenGE | should be $true
          }
     }

    Context "Change existing settings." {
        BeforeAll {
            [string]$setScript = {Set-Item -Path Env:Grani_ScriptOnOSVersion -Value 1}
            [string]$testScript = {(Test-Path Env:Grani_ScriptOnOSVersion) -and (Get-Item -Path Env:Grani_ScriptOnOSVersion).Value -eq 1}

            # [DebuggerStrings]::Culture にInvariantCultureに設定(要リフレクション)
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::InvariantCulture)
        }
        AfterAll {
            # テストが終わったら元の設定(CurrentUICulture)に戻す
            $private:type = [Type]::GetType("DebuggerStrings, System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            $culture = $type.GetProperty('Culture', [Reflection.BindingFlags]::Static -bor [Reflection.BindingFlags]::NonPublic).SetValue($null, [cultureinfo]::CurrentUICulture)

            if (Test-Path Env:Grani_ScriptOnOSVersion) {
                Remove-Item -Path Env:Grani_ScriptOnOSVersion
            }
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ} | should not Throw
        }
        
        It "Test-TargetResource Absent should return true" {
            Test-TargetResource -Key $key -SetScript $setScript -TestScript $testScript -ExecuteOnPlatform $executeOnPlatform -ExecuteOnVersionString $executeOnVersionString -When $WhenEQ | should be $true
        }
    }
}


