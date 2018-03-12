Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name DestinationPath `
    -Type String `
    -Attribute Key `
    -Description "Symbolic Link path."
$property += New-xDscResourceProperty `
    -Name SourcePath `
    -Type String `
    -Attribute Required `
    -Description "Symbolic Link source path"
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -Description "Ensure Symbolic Link is Present or Absent." `
    -ValueMap Present, Absent `
    -Values Present, Absent

New-xDscResource -Name Grani_SymbolicLink -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cSymbolicLink -Force

