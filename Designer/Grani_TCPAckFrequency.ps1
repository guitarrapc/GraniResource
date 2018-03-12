Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Enable `
    -Type Boolean `
    -Attribute Key

New-xDscResource -Name Grani_TCPAckFrequency -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cTCPAckFrequency -Force

