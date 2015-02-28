$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_ScheduleTask : ValidateTaskPathLastChar" {

    Context "GetPathItemType" {

        It "Last TaskPath char was not \. Output as add \ on last." {
            ValidateTaskPathLastChar -taskPath "hoge" | Should be "hoge\"
        }

        It "Last TaskPath char was \. No modify." {
            ValidateTaskPathLastChar -taskPath "hoge\" | Should be "hoge\"
        }
    }
}
