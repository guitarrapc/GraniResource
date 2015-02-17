$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_S3Content : ScriptBlockHelper" {

    $folder = "d:\hoge"
    $scriptString = "whoami"
    $noReturnScriptString = "return ''"
    $credential = Get-Credential

    Context "ScriptBlockExecute Helper test" {
        
        It "ScriptBlock without Credential should not throw." {
            {ExecuteScriptBlock -ScriptBlockString $scriptString -debug} | Should not Throw
        }

        It "ScriptBlock with Credential should not throw." {
            {ExecuteScriptBlock -ScriptBlockString $scriptString -Credential $credential -debug} | Should not Throw
        }

        It "ScriptBlock void return should not throw." {
            {ExecuteScriptBlock -ScriptBlockString $noReturnScriptString -debug} | Should not Throw
        }
    }
}