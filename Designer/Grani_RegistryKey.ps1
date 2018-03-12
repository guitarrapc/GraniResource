Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Key `
    -Type String `
    -Attribute Key `
    -Description "SubKey Path to create."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -Description "Ensure Key exists or not-exists" `
    -ValueMap Present, Absent `
    -Values Present, Absent

New-xDscResource -Name Grani_RegistryKey -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cRegistryKey -Force

