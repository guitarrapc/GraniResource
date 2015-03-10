$moduleName = 'GraniResource'
$script:moduleManufest = @{
    Path              = ".\$ModuleName.psd1"
    ModuleVersion     = '2.11.2'
    Author            = 'guitarrapc'
    CompanyName       = 'Grani'
    Description       = 'DSC Resource for Windows Configuration Management.'
    PowerShellVersion = '4.0'
    CLRVersion        = '4.0'
    RequiredModules   = @()
    FunctionsToExport = @('*')
    CmdletsToExport   = '*'
}

New-ModuleManifest @moduleManufest