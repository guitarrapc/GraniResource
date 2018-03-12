configuration absent
{
    Import-DscResource -ModuleName GraniResource
    cTopShelf hoge
    {
        ServiceName = "SampleTopShelfService"
        Path = (Resolve-Path "..\..\SampleTopShelfService\SampleTopShelfService\bin\Debug\SampleTopShelfService.exe").Path
        Ensure = "Absent"
    }
}

absent
Start-DscConfiguration -Path absent -Wait -Verbose -Force -Debug