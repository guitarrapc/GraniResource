configuration present
{
    Import-DscResource -ModuleName GraniResource
    cTopShelf hoge
    {
        ServiceName = "SampleTopShelfService"
        Path = (Resolve-Path "..\..\SampleTopShelfService\SampleTopShelfService\bin\Debug\SampleTopShelfService.exe").Path
        Ensure = "Present"
    }
}

present
Start-DscConfiguration -Path present -Wait -Verbose -Force -Debug