Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Required `
    -ValueMap "Present", "Absent" `
    -Values "Present", "Absent"
$property += New-xDscResourceProperty `
    -Name TaskName `
    -Type String `
    -Attribute Key
$property += New-xDscResourceProperty `
    -Name TaskPath `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Description `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Execute `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Argument `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name WorkingDirectory `
    -Type String `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Credential `
    -Type PSCredential `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Runlevel `
    -Type String `
    -Attribute Write `
    -ValueMap "Highest", "Limited" `
    -Values "Highest", "Limited"
$property += New-xDscResourceProperty `
    -Name Compatibility `
    -Type String `
    -Attribute Write `
    -ValueMap "At", "Win8", "Win7", "Vista", "V1" `
    -Values "At", "Win8", "Win7", "Vista", "V1"
$property += New-xDscResourceProperty `
    -Name ExecuteTimeLimitTicks `
    -Type Sint64 `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Hidden `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Disable `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name ScheduledAt `
    -Type DateTime[] `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name RepetitionIntervalTimeSpanString `
    -Type String[] `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name RepetitionDurationTimeSpanString `
    -Type String[] `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Daily `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name Once `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name AtStartup `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name AtLogOn `
    -Type Boolean `
    -Attribute Write
$property += New-xDscResourceProperty `
    -Name AtLogOnUserId `
    -Type String `
    -Attribute Write

New-xDscResource -Name Grani_ScheduleTask -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cScheduleTask -Force

