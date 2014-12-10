$moduleName = 'GraniResource'
$script:moduleManufest = @{
    Path                   = ".\$ModuleName.psd1"
    ModuleVersion          = '2.0'
    Author                 = 'guitarrapc'
    CompanyName            = 'Grani'
    Description            = 'Grani Resource for Windows Environment Setup'
    PowerShellVersion      = '4.0'
    CLRVersion             = '4.0'
    RequiredModules = @()
    FunctionsToExport      = @('*')
    CmdletsToExport = '*'
}

New-ModuleManifest @moduleManufest