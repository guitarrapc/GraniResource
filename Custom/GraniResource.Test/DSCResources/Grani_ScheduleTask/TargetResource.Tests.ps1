$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScheduleTask : ValidateTaskPathLastChar" {

    Context "GetPathItemType" {

        It "none \ last input value will output as last character with \" {
            ValidateTaskPathLastChar -taskPath "hoge" | Should be "hoge\"
        }

        It "with \ last input value will never change" {
            ValidateTaskPathLastChar -taskPath "hoge\" | Should be "hoge\"
        }
    }
}
