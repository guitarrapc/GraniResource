Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name KB `
    -Type String `
    -Attribute Key `
    -Description "Describe FotNetFramework KB."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -ValueMap Present, Absent `
    -Values Present, Absent `
    -Description "Describe going to install DotnetFramework or not."
$property += New-xDscResourceProperty `
    -Name InstallerPath `
    -Type String `
    -Attribute Write `
    -Description "Describe Path to the offline installation file. It only use for installation."
$property += New-xDscResourceProperty `
    -Name NoRestart `
    -Type Boolean `
    -Attribute Write `
    -Description "Describe restart after install/uninstall."
$property += New-xDscResourceProperty `
    -Name LogPath `
    -Type string `
    -Attribute Write `
    -Description "Describe installation log log file|Directory Path."

New-xDscResource -Name Grani_DotNetFramework -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cDotNetFramework -Force

