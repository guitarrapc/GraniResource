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
        RemoveHostsEntry = Remove hosts entry {0} : {1}.
"@
}

Data DebugMessages {
    ConvertFrom-StringData -StringData @"
        HostsEntryFound = Found a hosts entry {0} : {1}.
        HostsEntryNotFound = Did not find a hosts entry {0} : {1}.
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
            Write-Verbose ($DebugMessages.HostsEntryFound -f $HostName, $IpAddress);
            $Configuration.Ensure = [EnsureType]::Present;
        }
        else
        {
            Write-Verbose ($DebugMessages.HostsEntryNotFound -f $HostName, $IpAddress);
            $Configuration.Ensure = [EnsureType]::Absent;
        }
    }
    catch
    {
        Write-Verbose $_
        throw $_
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

        # Present
        Write-Verbose ($VerboseMessages.CreateHostsEntry -f $HostName, $IpAddress)
        Add-Content -Path $script:hostsLocation -Value $hostEntry -Force -Encoding $script:encoding
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
