$moduleName = 'GraniResource'
$moduleVersion = '3.7.4'
$script:moduleManufest = @{
    Path                 = ".\$ModuleName.psd1"
    ModuleVersion        = $moduleVersion
    Author               = 'guitarrapc'
    CompanyName          = 'Grani'
    Description          = 'DSC Resource for Windows Configuration Management.'
    PowerShellVersion    = '4.0'
    CLRVersion           = '4.0'
    RequiredModules      = @()
    FunctionsToExport    = @('*')
    CmdletsToExport      = '*'
    Tags                 = "DesiredStateConfiguration", "DSC", "DSC Resources"
    ReleaseNotes         = "https://github.com/guitarrapc/DSCResources/releases/tag/ver.$moduleVersion"
    ProjectUri           = "https://github.com/guitarrapc/DSCResources"
    LicenseUri           = "https://github.com/guitarrapc/DSCResources/blob/master/LICENSE"
    DscResourcesToExport = @(
        "cACL",
        "cDomainJoin",
        "cDotNetFramework",
        "cDownload",
        "cGitHubApiContent",
        "cHostsFile",
        "cInheritACL",
        "cPendingReboot",
        "cPfxImport",
        "cRegistryKey",
        "cS3Content",
        "cScheduleTask",
        "cScheduleTaskLog",
        "cSymbolicLink",
        "cTCPAckFrequency",
        "cTopShelf",
        "cWebPI",
        "cWebPILauncher"
    )
}

New-ModuleManifest @moduleManufest