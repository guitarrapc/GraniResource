#region Initialize

function Initialize
{
    # hosts location
    $script:hostsLocation = "$env:SystemRoot\System32\drivers\etc\hosts";
    $script:encoding = "UTF8";

    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue; 
}

. Initialize;

#endregion

#region Message Definition

Data VerboseMessages {
    ConvertFrom-StringData -StringData @"
        CheckHostsEntry = Check hosts entry is exists.
        CreateHostsEntry = Create hosts entry {0} : {1}.
        HostsEntryFound = Found a hosts entry {0} : {1}.
        HostsEntryNotFound = Did not find a hosts entry {0} : {1}.
        RemoveHostsEntry = Remove hosts entry {0} : {1}.
        RemoveHostsEntryBeforeAdd = Remove duplicate hostname entry before adding host entry. This will ignore IPAddress because correct host entry will add right after remove. hostname : {0}
        RemovedEntryIP = Removed Entry for {0} : {1}.{2}.{3}.{4}
"@
}

Data DebugMessages {
    ConvertFrom-StringData -StringData @"
"@
}

Data ErrorMessages {
    ConvertFrom-StringData -StringData @"
"@
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [OutputType([Hashtable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$HostName,
        
        [parameter(Mandatory = $true)]
        [string]$IpAddress,

        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = [EnsureType]::Present
    )  
    
    $Configuration = @{
        HostName = $HostName
        IPAddress = $IpAddress
    };

    Write-Verbose $VerboseMessages.CheckHostsEntry;

    try
    {
        if (TestIsHostEntryExists -IpAddress $IpAddress -HostName $HostName)
        {
            Write-Verbose ($VerboseMessages.HostsEntryFound -f $HostName, $IpAddress);
            $Configuration.Ensure = [EnsureType]::Present;
        }
        else
        {
            Write-Verbose ($VerboseMessages.HostsEntryNotFound -f $HostName, $IpAddress);
            $Configuration.Ensure = [EnsureType]::Absent;
        }
    }
    catch
    {
        Write-Error $_
    }

    return $Configuration;
}

function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$HostName,
        
        [parameter(Mandatory = $true)]
        [string]$IpAddress,

        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )  

    $hostEntry = "`n{0}`t{1}" -f $IpAddress, $HostName

    try
    {
        # Absent
        if ($Ensure -eq [EnsureType]::Absent.ToString())
        {
            Write-Verbose ($VerboseMessages.RemoveHostsEntry -f $HostName, $IpAddress)
            ((Get-Content $script:hostsLocation) -notmatch "^\s*$") -notmatch "^[^#]*$IpAddress\s+$HostName" | Set-Content -Path $script:hostsLocation -Force -Encoding $script:encoding
            return;
        }
        else
        {
            # Present
            Write-Verbose ($VerboseMessages.RemoveHostsEntryBeforeAdd -f $HostName)
            ((Get-Content $script:hostsLocation) -notmatch "^\s*$") -notmatch "^[^#]*(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\s+$HostName" | Set-Content -Path $script:hostsLocation -Force -Encoding $script:encoding

            Write-Verbose ($VerboseMessages.CreateHostsEntry -f $HostName, $IpAddress)
            Add-Content -Path $script:hostsLocation -Value $hostEntry -Force -Encoding $script:encoding
        }
    }
    catch
    {
        throw $_
    }
}

function Test-TargetResource
{
    [OutputType([boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$HostName,
        
        [parameter(Mandatory = $true)]
        [string]$IpAddress,

        [parameter(Mandatory = $true)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure = 'Present'
    )  

    return (Get-TargetResource -HostName $HostName -IpAddress $IpAddress -Ensure $Ensure).Ensure -eq $Ensure
}

#endregion

#region Helper Function

function TestIsHostEntryExists ([string]$IpAddress, [string] $HostName)
{
    return (Get-Content -Path $script:hostsLocation -Encoding $script:encoding) -match "^[^#]*$ipAddress\s+$HostName";
}

#endregion

Export-ModuleMember -Function *-TargetResource
