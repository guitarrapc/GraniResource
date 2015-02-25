#region Initialize

function Initialize
{
    # Enum for Ensure
    try
    {
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@
    }
    catch
    {
    }
}

Initialize

#endregion

#region Message Definition

$debugMessage = DATA {
    ConvertFrom-StringData -StringData "
        JoinDomain = Join domain.
        JoinWorkGroup = Join workgroup.
        JoinNewWorkGroup = Join to new workgroup
        UnJoinDomain = Leaving old domain.
    "
}

$verboseMessage = DATA {
    ConvertFrom-StringData -StringData "
        DomainNameCheck = Checking if Domain name is {0}
        JoinDomain = Added computer to Domain {0}
        JoinWorkGroup = Added computer to new workgroup {0}
        UnJoinDomain = Leaved old domain {0} with other credential
        WorkGroupNameCheck = Checking if WorkGroup name is {0}
    "
}

$exceptionMessage = DATA {
    ConvertFrom-StringData -StringData "
        NoCredentialWithDomain = Need to specify credentials with domain
        BothWorkGroupAndDomainExist = Only one of either the domain name or the workgroup name can be set. Please edit your configuration to ensure that only one of these properties have a value.
    "
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (	
        [parameter(Mandatory = $true)]
        [string]$Identifier,

        [parameter(Mandatory = $false)]
        [string]$DomainName,

        [parameter(Mandatory = $false)]
        [PSCredential]$Credential,

        [parameter(Mandatory = $false)]
        [PSCredential]$UnjoinCredential,

        [parameter(Mandatory = $false)]
        [string]$WorkGroupName
    )

    # validating DomainName and WorkGroupName not in use at once
    ValidateDomainWorkGroup -DomainName $DomainName -WorkGroupName $WorkGroupName

    # get current computer system information
    $computerSystem = Get-WmiObject WIN32_ComputerSystem

    # return hash
    $returnValue = @{
        Identifier = $Identifier
        Name = $env:COMPUTERNAME
        DomainName =$computerSystem.Domain
        Credential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
        UnjoinCredential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$UnjoinCredential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
        WorkGroupName= $computerSystem.WorkGroup
    }

    # ensure status check
    if(-not [string]::IsNullOrEmpty($DomainName))
    {
        if(!($Credential)){ throw New-Object System.NullReferenceException ($exceptionMessage.NoCredentialWithDomain) }

        Write-Verbose -Message ($verboseMessage.DomainNameCheck -f $DomainName)
        $ensure = if ($DomainName.ToLower() -eq $computerSystem.Domain.ToLower())
        {
            [EnsureType]::Present.ToString()
        }
        else
        {
            [EnsureType]::Absent.ToString()
        }
    }
    elseif(-not [string]::IsNullOrEmpty($WorkGroupName))
    {
        Write-Verbose -Message ($verboseMessage.WorkGroupNameCheck -f $WorkGroupName)
        $ensure = if ($WorkGroupName.ToLower() -eq $computerSystem.WorkGroup.ToLower())
        {
            [EnsureType]::Present.ToString()
        }
        else
        {
            [EnsureType]::Absent.ToString()
        }
    }

    $returnValue.Ensure = $ensure
    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    [OutputType([Void])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identifier,

        [parameter(Mandatory = $false)]
        [string]$DomainName,

        [parameter(Mandatory = $false)]
        [PSCredential]$Credential,

        [parameter(Mandatory = $false)]
        [PSCredential]$UnjoinCredential,

        [parameter(Mandatory = $false)]
        [string]$WorkGroupName
    )

    ValidateDomainWorkGroup -DomainName $DomainName -WorkGroupName $WorkGroupName
   
    # get current computer system information
    $computerSystem = Get-WmiObject WIN32_ComputerSystem

    if($Credential)
    {
        # must be both domain and none-domain scenario
        if($DomainName)
        {
            if($DomainName -ne $computerSystem.Domain)
            {
                if ($UnjoinCredential)
                {
                    # unjoin and re-join to other domain
                    Write-Debug $debugMessage.UnJoinDomain
                    Add-Computer -DomainName $DomainName -Credential $Credential -UnjoinDomainCredential $UnjoinCredential -Force
                    Write-Verbose -Message ($verboseMessage.UnJoinDomain -f $DomainName)
                }
                else
                {
                    # join Domain
                    Write-Debug $debugMessage.JoinDomain
                    Add-Computer -DomainName $DomainName -Credential $Credential -Force
                    Write-Verbose -Message ($verboseMessage.JoinDomain -f $DomainName)
                }
            }
        }
        elseif ($WorkGroupName)
        {
            if($WorkGroupName -ne $computerSystem.WorkGroup)
            {
                # Join to workgroup
                Write-Debug $debugMessage.JoinWorkGroup
                Add-Computer -WorkGroupName $WorkGroupName -Credential $Credential -Force    
                Write-Verbose -Message ($verboseMessage.JoinWorkGroup -f $WorkGroupName)
            }
        }
    }
    else
    {
        # must be non domain scenario
        if($DomainName){ throw New-Object System.NullReferenceException ($exceptionMessage.NoCredentialWithDomain) }

        # workgroup scenario
        if($WorkGroupName)
        {
            if($WorkGroupName -ne $computerSystem.Workgroup)
            {
                Write-Debug $debugMessage.JoinNewWorkGroup
                Add-Computer -WorkgroupName $WorkGroupName
                Write-Verbose -Message ($verboseMessage.JoinWorkGroup -f $WorkGroupName)
            }
        }
    }
            
    # Tell the DSC Engine to restart the machine
    $global:DSCMachineStatus = 1
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Identifier,

        [parameter(Mandatory = $false)]
        [string]$DomainName,

        [parameter(Mandatory = $false)]
        [PSCredential]$Credential,

        [parameter(Mandatory = $false)]
        [PSCredential]$UnjoinCredential,

        [parameter(Mandatory = $false)]
        [string]$WorkGroupName
    )
    
    return (Get-TargetResource -Identifier $Identifier -DomainName $DomainName -Credential $Credential -UnjoinCredential $UnjoinCredential -WorkGroupName $WorkGroupName).Ensure -eq [EnsureType]::Present.ToString()
}

#endregion

#region helper

function ValidateDomainWorkGroup
{
    param
    (
        $DomainName,
        $WorkGroupName
    )

    if($DomainName -and $WorkGroupName)
    {
        throw New-Object System.InvalidOperationException $exceptionMessage.BothWorkGroupAndDomainExist
    }
}

#endregion

Export-ModuleMember -Function *-TargetResource