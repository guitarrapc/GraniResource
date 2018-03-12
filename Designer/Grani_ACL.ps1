Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Path `
    -Type String `
    -Attribute Key
$property += New-xDscResourceProperty `
    -Name Account `
    -Type String `
    -Attribute Key
$property += New-xDscResourceProperty `
    -Name Rights `
    -Type String `
    -Attribute Write `
    -ValueMap ReadAndExecute, Modify, FullControl `
    -Values ReadAndExecute, Modify, FullControl
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Write `
    -ValueMap Present, Absent `
    -Values Present, Absent
$property += New-xDscResourceProperty `
    -Name Access `
    -Type String `
    -Attribute Write `
    -ValueMap Allow, Deny `
    -Values Allow, Deny
$property += New-xDscResourceProperty `
    -Name Inherit `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Recurse `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Strict `
    -Type Boolean `
    -Attribute Write

New-xDscResource -Name Grani_ACL -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cACL -Force

