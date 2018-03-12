Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name InstanceIdentifier `
    -Type String `
    -Attribute Key `
    -Description "Configuration Instance Identifier to handle same Target with multiple PsDscRunCredential."
$property += New-xDscResourceProperty `
    -Name Target `
    -Type String `
    -Attribute Required `
    -Description "Credential Manager entry identifier link to Credential."
$property += New-xDscResourceProperty `
    -Name Credential `
    -Type PSCredential `
    -Attribute Write `
    -Description "Credential to save."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -ValueMap Present, Absent `
    -Values Present, Absent `
    -Description "Ensure Target entry is Present or Absent."
New-xDscResource -Name Grani_CredentialManager -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cCredentialManager -Force

