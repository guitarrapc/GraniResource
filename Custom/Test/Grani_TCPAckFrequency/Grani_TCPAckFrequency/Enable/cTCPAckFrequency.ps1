configuration test
{
    Import-DscResource -ModuleName GraniResource
    cTCPAckFrequency test
    {
        Enable = $true
    }
}

test -OutputPath test
Start-DscConfiguration -Verbose -Force -Wait -Path test