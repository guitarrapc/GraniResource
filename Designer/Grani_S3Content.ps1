Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name DestinationPath `
    -Type String `
    -Attribute Key `
    -Description "Path to output Donwloaded item."
$property += New-xDscResourceProperty `
    -Name S3BucketName `
    -Type String `
    -Attribute Required `
    -Description "S3 Bucket name to access."
$property += New-xDscResourceProperty `
    -Name Key `
    -Type String `
    -Attribute Write `
    -Description "S3 Object Key which identify content. You can't use both Key and KeyPrefix at once."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Read `
    -ValueMap Present, Absent `
    -Values Present, Absent `
    -Description "Describe File is exist on DestinationPath or not."
$property += New-xDscResourceProperty `
    -Name PreAction `
    -Type String `
    -Attribute Write `
    -Description "Pre Action of Download Content. It only run when Test false."
$property += New-xDscResourceProperty `
    -Name PostAction `
    -Type String `
    -Attribute Write `
    -Description "Post Action of Download Content. It only run when Test false."
$property += New-xDscResourceProperty `
    -Name Credential `
    -Type PSCredential `
    -Attribute Write `
    -Description "Action execute Credential. You can ignore it if run as SYSTEM."
$property += New-xDscResourceProperty `
    -Name CheckSum `
    -Type String `
    -Attribute Write `
    -ValueMap FileHash, FileName `
    -Values FileHash, FileName `
    -Description "Checksum to compare S3Object and Local Content. Default is FileHash."
$property += New-xDscResourceProperty `
    -Name Region `
    -Type String `
    -Attribute Write `
    -Description "Use when you want to override AWS Region andpoint string to handle S3bucket."

New-xDscResource -Name Grani_S3Content -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cS3Content -Force

