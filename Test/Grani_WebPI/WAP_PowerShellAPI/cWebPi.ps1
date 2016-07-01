configuration hoge
{
    Import-DscResource -ModuleName GraniResource
    cWebPi fuga
    {
        Name = 'WAP_PowerShellAPI'
    }
}

hoge -OutputPath hoge
Start-DscConfiguration -Wait -Force -Verbose -Path hoge