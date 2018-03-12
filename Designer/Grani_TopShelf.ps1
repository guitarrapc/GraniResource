Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Path `
    -Type String `
    -Attribute Key `
    -Description "TopShelf Service Path."
$property += New-xDscResourceProperty `
    -Name ServiceName `
    -Type String `
    -Attribute Required `
    -Description "Service Name | Display Name which installed by TopShelf. This must be same as you define in TopShelf."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -Description "Relates to TopShelf Verbs. Ensure means install, uninstall means unistall. Only support install/uninstall as we only need these with DSC. : http://docs.topshelf-project.com/en/latest/overview/commandline.html" `
    -ValueMap Present, Absent `
    -Values Present, Absent

New-xDscResource -Name Grani_TopShelf -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cTopShelf -Force

