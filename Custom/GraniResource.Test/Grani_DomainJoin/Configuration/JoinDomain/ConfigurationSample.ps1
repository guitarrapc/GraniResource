configuration DomainJoin
{
    param
    (
        [PSCredential]$Credential
    )

    Import-DscResource -ModuleName GraniResource

    node $Allnodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cDomainJoin DomainJoin
        {
            Identifier = 'DomainJoin'
            DomainName = 'contoso.com'
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
DomainJoin -Credential $credential -ConfigurationData $configurationData
Start-DscConfiguration -Verbose -Force -Wait -Path DomainJoin