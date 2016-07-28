#region Initialize

function Initialize
{
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

#region Wrapper

function ListCredential
{
    [OutputType([PSCredential])]
    [CmdletBinding()]
    param
    ()
    
    return [GraniResource.CredentialManager]::List();
}

function RemoveTarget
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $false, position = 1)]
        [ValidateNotNullOrEmpty()]
        [GraniResource.CredType]$Type = [GraniResource.CredType]::Generic
    )
 
    [GraniResource.CredentialManager]::Remove($Target, $Type);
}

function TestTarget
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true, position = 0)]
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
        [Parameter(mandatory = $true, position = 0)]
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
        [Parameter(mandatory = $true, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $true, position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(mandatory = $false, position = 2)]
        [ValidateNotNullOrEmpty()]
        [GraniResource.CredType]$Type = [GraniResource.CredType]::Generic
    )
    
    [GraniResource.CredentialManager]::Write($Target, $Credential, $Type)
}

#endregion

#region Helper

function IsCredentialEmpty
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true, position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential
    )

    return ($null -eq $Credential) -or ([PSCredential]::Empty -eq $Credential)
}

function IsCredentialMatch
{
    [OutputType([bool])]
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter(mandatory = $true, position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credential
    )

    $current = GetCredential -Target $Target;
    $isUserNameMatch = $current.UserName -eq $Credential.UserName;
    $isPassMatch = $current.GetNetworkCredential().Password -eq $Credential.GetNetworkCredential().Password;
    return $isUserNameMatch -and $isPassMatch;
}

#endregion

Export-ModuleMember -Function *