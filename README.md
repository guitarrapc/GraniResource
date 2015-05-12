DSCResources
============

PowerShel DSC Resources

What inside
----

Directory|ResourceName
----|----
Custom|GraniResource
MicrosoftScriptCenter|MSFT Resource
PowerShellOrg|PowerShell Org DSC Resource

GraniResource
----

DSC Resources published  by [Grani.Inc.](http://grani.jp/)

You can manage followings.

ResourceName|FriendlyName|Description
----|----|----
[Grani_ACL](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_ACL)|cACL|ACL Resource make you ability to manage ACL through easy configuration.
[Grani_DomainJoin](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_DomainJoin)|cDomainJoin|Join/Unjoin Domain Resource. This free you from xComputerManagement resource force to specify Host Computer name.
[Grani_Download](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_Download)|cDownload|Download Remote file to local. This include file hash comparison for detecting file change.
[Grani_GitHubApiContent](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_GitHubApiContent)|cGitHubApiContent|Download GitHub content to local through API. This include file hash comparison for detecting file change.
[Grani_PendingReboot](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_PendingReboot) | cPendingReboot | Allow you to handle reboot with configuration both LocalConfigurationManager ```RebootNodeIfNeeded``` setting as $true/$false.
[Grani_PfxImport](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_PfxImport)|cPfxImport|Import Pfx file into desired CertStore / or Remove pfx from CertStore.
[Grani_S3Content](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_S3Content)|cS3Content|Download and track change with S3 Object and Local File.
[Grani_ScheduleTask](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_ScheduleTask)|cScheduledTask|Enable you to configure Schedule Task. (Not all property supported, but quiet a lot.)
[Grani_ScheduleTaskLog](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_ScheduleTaskLog)|cScheduledTaskLog|Enable/Disable Scheduled Task Log
[Grani_SymbolicLink](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_SymbolicLink)| cSymbolicLink | Create/Remove SymbolicLink.
[Grani_TCPAckFrequency](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_TCPAckFrequency)|cTCPAckFrequency|Enable/Disable TCPAckFrequency
[Grani_TopShelf](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_TopShelf)|cTopShelf|Install/Uninstall TopShelf Application
[Grani_WebPI](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/Grani_WebPI)|cWebPI|Install WebPlatformInstaller Products(You cannot uninstall from WebPI)
[cWebPILauncher](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources/cWebPILauncher)|cWebPILauncher|Install WebPlatformInstaller itself

Check [GraniResurce.Test](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource.Test) for GraniResource sample usage.

All Resource have it's README.md inside [DSCResouce](https://github.com/guitarrapc/DSCResources/tree/master/Custom/GraniResource/DSCResources).

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
