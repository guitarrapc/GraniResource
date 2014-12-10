configuration hoge
{
    Import-DscResource -ModuleName GraniResource
    cWebPILauncher fuga
    {
        ProductId = "4D84C195-86F0-4B34-8FDE-4A17EB41306A"
    }
}

hoge -OutputPath hoge
Start-DscConfiguration -Path hoge -Wait -Force -Verbose