Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Path `
    -Type String `
    -Attribute Key
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Read `
    -ValueMap Present, Absent `
    -Values Present, Absent
$property += New-xDscResourceProperty `
    -Name IsProtected `
    -Type Boolean `
    -Attribute Required
$property += New-xDscResourceProperty `
    -Name PreserveInheritance `
    -Type Boolean `
    -Attribute Write

New-xDscResource -Name Grani_InheritACL -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cInheritACL -Force

