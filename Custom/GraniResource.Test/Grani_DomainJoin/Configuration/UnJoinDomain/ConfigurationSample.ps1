configuration DomainUnJoin
{
    param
    (
        [PSCredential]$Credential
    )

    Import-DscResource -ModuleName GraniResource

    node $Allnodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cDomainJoin DomainUnJoin
        {
            Identifier = 'DomainUnjoin'
            WorkGroupName = 'WORKGROUP'
            Credential = $Credential
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDSCAllowPlainTextPassword = $true
        }
        @{
            NodeName = "localhost"
            Role     = "localhost"
        }
    )
}

$credential = (Get-Credential)
DomainUnJoin -Credential $credential -ConfigurationData $configurationData
Start-DscConfiguration -Verbose -Force -Wait -Path DomainUnJoin -Debug