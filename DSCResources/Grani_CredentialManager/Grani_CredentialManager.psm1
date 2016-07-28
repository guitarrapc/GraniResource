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

    # Credential Manager C# on the fly compile to avoid dll lock.
    # Import Class as [GraniResource.CredentialManager]
    $code = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "CredentialManager.cs") -Raw
    $referenceAssemblies = @("System", "System.Linq", "System.ComponentModel", "System.Management.Automation", "System.Runtime.InteropServices")
    Add-Type -TypeDefinition $code -ReferencedAssemblies $referenceAssemblies -ErrorAction SilentlyContinue;
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
        [System.String]$Target,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential  = [PSCredential]::Empty,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    # Initialize return values
    $returnHash = @{
        Target = $Target;
        Credential = New-CimInstance -ClassName MSFT_Credential -Property @{Username=[string]$Credential.UserName; Password=[string]$null} -Namespace root/microsoft/windows/desiredstateconfiguration -ClientOnly;
        Ensure = [EnsureType]::Absent.ToString();
    }

    # Absent == should remove Target if exists.
    if ($Ensure -eq [EnsureType]::Absent.ToString())
    {
        Write-Verbose -Message ($VerboseMessages.CheckingAbsent);
        if (TestCredential -Target $Target)
        {
            Write-Verbose -Message ($VerboseMessages.FailedAbsent);
            $returnHash.Ensure = [EnsureType]::Present.ToString();
        }
    }

    # Present == Registered credential must match desired credential.
    if ($Ensure -eq [EnsureType]::Present.ToString())
    {
        Write-Verbose -Message ($VerboseMessages.CheckingPresent);

        if (($null -eq $Credential) -or ([PSCredential]::Empty -eq $Credential))
        {
            Write-Verbose -Message ($VerboseMessages.CredentialNotExists);
        }
        elseif (TestCredential -Target $Target)
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
        if (TestCredential -Target $Target)
        {
            Write-Verbose -Message ($VerboseMessages.RemovingCredential -f $Target);
            RemoveCredential -Target $Target;
            return;
        }
    }

    # Present == Register credential as desired
    if ($Ensure -eq [EnsureType]::Present.ToString())
    {
        if (($null -eq $Credential) -or ([PSCredential]::Empty -eq $Credential))
        {
            Write-Verbose -Message ($VerboseMessages.CredentialNotExists);
            throw $ErrorMessages.CredentialNotExistsException;
            return;
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
        [System.String]$Target,

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]$Ensure
    )

    return (Get-TargetResource -Target $Target -Credential $Credential -Ensure $Ensure).Ensure -eq $Ensure
}

#endregion

#region Helper

function ListCredential
{
    [OutputType([PSCredential])]
    [CmdletBinding()]
    param
    ()
    
    return [GraniResource.CredentialManager]::List();
}

function RemoveCredential
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $false, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $false, position = 1)]
        [ValidateNotNullOrEmpty()]
        [GraniResource.CredType]$Type = [GraniResource.CredType]::Generic
    )
 
    [GraniResource.CredentialManager]::Remove($Target, $Type);
}

function TestCredential
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $false, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $false, position = 1)]
        [ValidateNotNullOrEmpty()]
        [GraniResource.CredType]$Type = [GraniResource.CredType]::Generic
    )
 
    [GraniResource.CredentialManager]::Exists($Target, $Type);
}

function GetCredential
{
    [OutputType([PSCredential])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $false, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $false, position = 1)]
        [ValidateNotNullOrEmpty()]
        [GraniResource.CredType]$Type = [GraniResource.CredType]::Generic
    )
    
    return [GraniResource.CredentialManager]::Read($Target, $Type, "");
}

function SetCredential
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $false, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $false, position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(mandatory = $false, position = 2)]
        [ValidateNotNullOrEmpty()]
        [GraniResource.CredType]$Type = [GraniResource.CredType]::Generic
    )
    
    [GraniResource.CredentialManager]::Write($Target, $Credential, $Type)
}

function IsCredentialMatch
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $false, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $false, position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential
    )

    $current = GetCredential -Target $Target;
    $isUserNameMatch = $current.UserName -eq $Credential.UserName;
    $isPassMatch = $current.GetNetworkCredential().Password -eq $Credential.GetNetworkCredential().Password;
    return $isUserNameMatch -and $isPassMatch;
}

#endregion

Export-ModuleMember -Function *-TargetResource