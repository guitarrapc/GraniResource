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
        ImportPfx = Importing certificate PFX '{0}' to CertStoreLocation '{1}', CertStore '{2}'.
        RemovePfx = Removing pfx from Cert path '{0}'.
    "
}

$verboseMessage = DATA {
    ConvertFrom-StringData -StringData "
        UnJoinWithOtherCredential = Leaved old domain {0} with other credential
    "
}

$exceptionMessage = DATA {
    ConvertFrom-StringData -StringData "
        CertificateFileNotFoundException = Certificate not found in '{0}'. Make sure you have been already place it.
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

    # type converter for PSCredential
    $convertToCimCredential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly
    $convertToCimUnjoinCredential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$UnjoinCredential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly

    # get current computer system information
    $computerSystem = Get-WmiObject WIN32_ComputerSystem

    # return hash
    $returnValue = @{
        Identifier = $Identifier
		Name = $env:COMPUTERNAME
        DomainName =$computerSystem.Domain
		Credential = [ciminstance]$convertToCimCredential
        UnjoinCredential = [ciminstance]$convertToCimUnjoinCredential
		WorkGroupName= $computerSystem.WorkGroup
	}

    # ensure status check
    if(-not [string]::IsNullOrEmpty($DomainName))
    {
        if(!($Credential)){ throw "Need to specify credentials with domain" }

        Write-Verbose -Message "Checking if domain name is $DomainName"
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
        Write-Verbose -Message "Checking if workgroup name is $WorkGroupName"
        $result = if ($WorkGroupName.ToLower() -eq $computerSystem.WorkGroup.ToLower())
        {
            [EnsureType]::Present.ToString()
        }
        else
        {
            [EnsureType]::Absent.ToString()
        }
    }

    $returnValue.Ensure = $result
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
   
    if($Credential)
    {
        # must be both domain and none-domain scenario
        if($DomainName)
        {
            $currentMachineDomain = (gwmi win32_computersystem).Domain
            if($DomainName -ne $currentMachineDomain)
            {
                #Same computer name, join to domain
                if ($UnjoinCredential)
                {                    
                    Add-Computer -DomainName $DomainName -Credential $Credential -UnjoinDomainCredential $UnjoinCredential -Force
                    Write-Verbose -Message ("Leaved old domain {0} with other credential" -f $DomainName)
                }
                else
                {
                    Add-Computer -DomainName $DomainName -Credential $Credential -Force
                    Write-Verbose -Message "Added computer to Domain $DomainName"
                }
            }
        }
        elseif ($WorkGroupName)
        {
            $currentMachineWorkgroup = (gwmi win32_computersystem).WorkGroup
            if($WorkGroupName -ne $currentMachineWorkgroup)
            {
                #Join to workgroup
                Add-Computer -WorkGroupName $WorkGroupName -Credential $Credential -Force    
                Write-Verbose -Message "Added computer to workgroup $WorkGroupName"
            }
        }
    }
    else
    {
        # must be non domain scenario
        if($DomainName)
        {
            throw "Need to specify credentials with domain"
        }
        if($WorkGroupName)
        {
            if($WorkGroupName -ne (Get-WmiObject win32_computersystem).Workgroup)
            {
                #New workgroup, same name
                Add-Computer -WorkgroupName $WorkGroupName
                Write-Verbose -Message "Added computer to workgroup $WorkGroupName"
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
		throw "Only one of either the domain name or the workgroup name can be set! Please edit the configuration to ensure that only one of these properties have a value."
	}
}

#endregion

Export-ModuleMember -Function *-TargetResource