Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Identifier `
    -Type String `
    -Attribute Key
$property += New-xDscResourceProperty `
    -Name Name `
    -Type String `
    -Attribute Read
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Read `
    -ValueMap Present, Absent `
    -Values Present, Absent `
    -Description "Describe Status is in desired state."
$property += New-xDscResourceProperty `
    -Name DomainName `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name WorkGroupName `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Credential `
    -Type PSCredential `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name UnjoinCredential `
    -Type PSCredential `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Restart `
    -Type Boolean `
    -Attribute Write

New-xDscResource -Name Grani_DomainJoin -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cDomainJoin -Force

