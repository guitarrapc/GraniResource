param([string]$Version, [string]$Path)

$script:moduleManufest = @{
    Path                 = $Path
    ModuleVersion        = $Version
    Author               = 'guitarrapc'
    CompanyName          = 'Grani'
    Description          = 'DSC Resource for Windows Configuration Management.'
    PowerShellVersion    = '4.0'
    CLRVersion           = '4.0'
    RequiredModules      = @()
    FunctionsToExport    = @('*')
    CmdletsToExport      = '*'
    Tags                 = "DesiredStateConfiguration", "DSC", "DSCResources"
    ReleaseNotes         = "https://github.com/guitarrapc/GraniResource/releases/tag/ver.$Version"
    ProjectUri           = "https://github.com/guitarrapc/GraniResource"
    LicenseUri           = "https://github.com/guitarrapc/GraniResource/blob/master/LICENSE"
    <#
    # As these are not supported in PowerShell 4.0...
    # and this section cause Module Version in mof to be force "0.0"
    DscResourcesToExport = @()
    #>
}

New-ModuleManifest @moduleManufest