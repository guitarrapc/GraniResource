Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Name `
    -Type String `
    -Attribute Key

New-xDscResource -Name Grani_WebPI -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cWebPI -Force

