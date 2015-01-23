DSCResources
============

PowerShel DSC Resources

What inside
----

Directory|ResourceName
----|----
Custom|GraniResource
MicrosoftScriptCenter|MSFT Resource
PowerShellOrgDSC|PowerShell Org & StackExchange Resource

GraniResource
----

DSC Resources published  by [Grani.Inc.](http://grani.jp/)

You can manage followings.

ResourceName|FriendlyName|Description
----|----|----
Grani_ACL|cACL|ACL Resource make you ability to manage ACL through easy configuration.
Grani_Download|cDownload|Download Remote file to local. This include file hash comparison for detecting file change.
Grani_GitHubApiContent|cGitHubApiContent|Download GitHub content to local through API. This include file hash comparison for detecting file change.
Grani_ScheduleTask|cScheduledTask|Enable you to configure Schedule Task detail as like cmdlet. (not all but quiet lot.)
Grani_ScheduleTaskLog|cScheduledTaskLog|Enable/Disable Scheduled Task Log
Grani_TCPAckFrequency|cTCPAckFrequency|Enable/Disable TCPAckFrequency
Grani_WebPI|cWebPI|Install WebPlatformInstaller Products(You cannot uninstall from WebPI)
cWebPILauncher|cWebPILauncher|Install WebPlatformInstaller itself

Check [Test](https://github.com/guitarrapc/DSCResources/tree/master/Custom/Test) for sample usage.


MicrosoftScriptCenter
----

Microsoft PowerShell Team publish awesome DSC Resource in ScriptCenter. (future PowerShellGet).

This include PSDesiredStateConfiguration Resource to create Pull Server.

This Repogitry keeps to some version and rename Resource Prefix from x to c as PowerShell Team recommended.


PowerShellOrgDSC
----

PowerShellOrg is community DSC Repository. Hope we can share Resources.

This include PowerShellOrg Resource which needed. 

However some resource are too norty to use in production. (Like TaskScheduler / Choco Resource)  GraniResource include much more powerfull resource which already fully use in production for hundreds of Windows Server 2012 R2.
