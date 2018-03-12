Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty -Name Uri `
    -Type String `
    -Attribute Key `
    -Description "Request Uri to obtain file."
$property += New-xDscResourceProperty `
    -Name DestinationPath `
    -Type String `
    -Attribute Required `
    -Description "File Path to output Donwloaded item."
$property += New-xDscResourceProperty `
    -Name Header `
    -Type Hashtable `
    -Attribute Write `
    -Description "Specify Headers for Web Request."
$property += New-xDscResourceProperty `
    -Name ContentType `
    -Type String `
    -Attribute Write `
    -Description "Specify ContentType for Web Request."
$property += New-xDscResourceProperty `
    -Name Credential `
    -Type PSCredential `
    -Attribute Write `
    -Description "Specify Basic Authorization Credential Web Request."
$property += New-xDscResourceProperty `
    -Name UserAgent `
    -Type String `
    -Attribute Write `
    -Description "Specify User-Agent for Web Request"
$property += New-xDscResourceProperty `
    -Name AllowRedirect `
    -Type Boolean `
    -Attribute Write `
    -Description "Specify if you want to control Redirect."
$property += New-xDscResourceProperty `
    -Name CacheLocation `
    -Type String `
    -Attribute Write `
    -Description "Specify CacheLocation to hold your last configuration result."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Read `
    -ValueMap Present, Absent `
    -Values Present, Absent `
    -Description "Describe File is exist on DestinationPath or not."

New-xDscResource -Name Grani_Download -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cDownload -Force

