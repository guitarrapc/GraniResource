configuration absent
{
    Import-DscResource -ModuleName GraniResource
    cScriptOnOSVersion hoge
    {
        Key = "hoge"
        SetScript = {Remove-Item -Path Env:Grani_ScriptOnOSVersion}
        TestScript = {!(Test-Path Env:Grani_ScriptOnOSVersion)}
        ExecuteOnPlatform = [Environment]::OSVersion.Platform
        ExecuteOnVersionString = [System.Environment]::OSVersion.Version.ToString()
        When = 'Equal'
    }
}

absent
Start-DscConfiguration -Path absent -Wait -Verbose -Force -Credential (Get-Credential)