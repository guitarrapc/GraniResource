Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Key `
    -Type String `
    -Attribute Key `
    -Description "Unique key."
$property += New-xDscResourceProperty `
    -Name SetScript `
    -Type String `
    -Attribute Write `
    -Description "Set Script when run script."
$property += New-xDscResourceProperty `
    -Name TestScript `
    -Type String `
    -Attribute Write `
    -Description "Test Script when run script."
$property += New-xDscResourceProperty `
    -Name Credential `
    -Type PSCredential `
    -Attribute Write `
    -Description "Action execute Credential. You can ignore it if run as SYSTEM."
$property += New-xDscResourceProperty `
    -Name ExecuteOnPlatform `
    -Type String `
    -Attribute Required `
    -Description "Platfrom Name = OS Name."
$property += New-xDscResourceProperty `
    -Name ExecuteOnVersionString `
    -Type String `
    -Attribute Required `
    -Description ".NET Version formatted string for OS."
$property += New-xDscResourceProperty `
    -Name When `
    -Type String `
    -Attribute Required `
    -Description "Specify version matching condition." `
    -ValueMap LessThan, LessThanEqual, Equal, NotEqual, GreaterThan, GreaterThanEqual `
    -Values LessThan, LessThanEqual, Equal, NotEqual, GreaterThan, GreaterThanEqual
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Read `
    -Description "Ensure run on specified platform." `
    -ValueMap Present, Absent `
    -Values Present, Absent

New-xDscResource -Name Grani_ScriptOnOSVersion -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cScriptOnOSVersion -Force