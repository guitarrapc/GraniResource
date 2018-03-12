configuration present
{
    Import-DscResource -ModuleName GraniResource
    cScriptOnOSVersion hoge
    {
        Key = "hoge"
        SetScript = {Set-Item -Path Env:Grani_ScriptOnOSVersion -Value 1}
        TestScript = {(Test-Path Env:Grani_ScriptOnOSVersion) -and (Get-Item -Path Env:Grani_ScriptOnOSVersion).Value -eq 1}
        ExecuteOnPlatform = [Environment]::OSVersion.Platform
        ExecuteOnVersion = [System.Environment]::OSVersion.Version.ToString()
        When = 'Equal'
    }
}

present
Start-DscConfiguration -Path present -Wait -Verbose -Force -Credential (Get-Credential)