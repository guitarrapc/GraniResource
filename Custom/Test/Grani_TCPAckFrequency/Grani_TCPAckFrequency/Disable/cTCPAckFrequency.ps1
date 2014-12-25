configuration test
{
    Import-DscResource -ModuleName GraniResource
    cTCPAckFrequency test
    {
        Enable = $false
    }
}

test -OutputPath test
Start-DscConfiguration -Verbose -Force -Wait -Path test