#region Initialize

function Initialize
{
    # Enum for Ensure
    Add-Type -TypeDefinition @"
        public enum EnsureType
        {
            Present,
            Absent
        }
"@ -ErrorAction SilentlyContinue; 

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath "Grani_CredentialManagerHelper.psm1") -Verbose:$false -Force
}

. Initialize;

#endregion

#region Message Definition

Data VerboseMessages {
    ConvertFrom-StringData -StringData @"
        CheckingAbsent = Detected as Ensure=Absent. Checking Target is not exists.
        CheckingPresent = Detected as Ensure=Present. Checking Target credential is as desired.
        CredentialNotExists = Ensure detected as Present but credential was missing. Please make sure credential is exists.
        FailedAbsent = Target was found as not desired.
        PassPresent = Target's Credential was detected as desired.
        RemovingCredential = Removing Target Credential. Target : {0}
        SetCredential = Setting Desired Credential to Target. Target : {0}
"@
}

Data DebugMessages {
    ConvertFrom-StringData -StringData @"
"@
}

Data ErrorMessages {
    ConvertFrom-StringData -StringData @"
        CredentialNotExistsException = Credential parameter's value not exists exception!! Please make sure credential is exists.
"@
}

#endregion

#region *-TargetResource

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$InstanceIdentifier,

        [parameter(Mandatory = $true)]
        [System.String]$Target,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential  = [PSCredential]::Empty,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    # Initialize return values
    $returnHash = @{
        # No meaning with InstanceIdentifier for "how Resource work" but it is identifier to deceive DSC Engine when you want to keep "Same target, Credential for multiple PsDscRunAsCredential".
        # Normally InstanceIdentifier can be same as Target or ConfigurationName. Just change every instance's InstanceIdentifier when you want to set as above situation.
        InstanceIdentifier = $InstanceIdentifier;
        Target = $Target;
        Credential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly;
        Ensure = [EnsureType]::Absent.ToString();
    }

    # Absent == should remove Target if exists.
    if ($Ensure -eq [EnsureType]::Absent.ToString())
    {
        Write-Verbose -Message ($VerboseMessages.CheckingAbsent);
        if (TestTarget -Target $Target)
        {
            Write-Verbose -Message ($VerboseMessages.FailedAbsent);
            $returnHash.Ensure = [EnsureType]::Present.ToString();
        }
    }

    # Present == Registered credential must match desired credential.
    if ($Ensure -eq [EnsureType]::Present.ToString())
    {
        Write-Verbose -Message ($VerboseMessages.CheckingPresent);

        if (IsCredentialEmpty -Credential $Credential)
        {
            Write-Verbose -Message ($VerboseMessages.CredentialNotExists);
        }
        elseif (TestTarget -Target $Target)
        {
            if (IsCredentialMatch -Target $Target -Credential $Credential)
            {
                Write-Verbose -Message ($VerboseMessages.PassPresent);
                $returnHash.Ensure = [EnsureType]::Present.ToString();
            }
        }
    }

    return $returnHash;
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$InstanceIdentifier,

        [parameter(Mandatory = $true)]
        [System.String]$Target,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    # Absent == Start remove existing Target
    if ($Ensure -eq [EnsureType]::Absent.ToString())
    {
        if (TestTarget -Target $Target)
        {
            Write-Verbose -Message ($VerboseMessages.RemovingCredential -f $Target);
            RemoveTarget -Target $Target;
            return;
        }
    }

    # Present == Register credential as desired
    if ($Ensure -eq [EnsureType]::Present.ToString())
    {
        if (IsCredentialEmpty -Credential $Credential)
        {
            Write-Verbose -Message ($VerboseMessages.CredentialNotExists);
            throw $ErrorMessages.CredentialNotExistsException;
        }

        Write-Verbose -Message ($VerboseMessages.SetCredential -f $Target);
        SetCredential -Target $Target -Credential $Credential;
        return;
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$InstanceIdentifier,

        [parameter(Mandatory = $true)]
        [System.String]$Target,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    return (Get-TargetResource -InstanceIdentifier $InstanceIdentifier -Target $Target -Credential $Credential -Ensure $Ensure).Ensure -eq $Ensure
}

#endregion

Export-ModuleMember -Function *-TargetResource