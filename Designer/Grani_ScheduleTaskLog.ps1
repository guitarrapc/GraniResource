Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Enable `
    -Type Boolean `
    -Attribute Key

New-xDscResource -Name Grani_ScheduleTaskLog -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cScheduleTaskLog -Force

