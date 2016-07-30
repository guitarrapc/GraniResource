GraniResource
============

DSC Resources published  by [Grani.Inc.](http://grani.jp/)

**Notice : 1st/July/2016**

Repository name changed from DSCResources to GraniResource to simplify code management.

Installation
----

You can retrieve Resource through [PoweShellGet](https://www.powershellgallery.com/packages/GraniResource).

```powershell
Install-Module GraniResource
```

Where can I see how to usage of DSCResource?
----

You may find README.md inside DSCResource\ResourceNameFolder\README.md.


What Inside?
----

- All Resource have it's README.md inside [DSCResouce](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources).
- Check [UnitTestFiles](https://github.com/guitarrapc/GraniResource/tree/master/Test) for GraniResource sample usage.

ResourceName|FriendlyName|Description
----|----|----
[cWebPILauncher](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/cWebPILauncher)|cWebPILauncher|Install WebPlatformInstaller itself
[Grani_ACL](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_ACL)|cACL| Allow you to manage ACL entries with this resource.
[Grani_CredentialManager](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_CredentialManager) |cCredentialManager| All you to manageCredential Manager entry.
[Grani_DomainJoin](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_DomainJoin)|cDomainJoin|Join/Unjoin Domain Resource. This free you from xComputerManagement resource force to specify Host Computer name.
[Grani_DotNetFramework](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_DotNetFramework)|cDotNetFramework|Manage .NET Framework offline file install/uninstall.
[Grani_Download](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_Download)|cDownload|Download Remote file to local. This include file hash comparison for detecting file change.
[Grani_GitHubApiContent](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_GitHubApiContent)|cGitHubApiContent|Download GitHub content to local through API. This include file hash comparison for detecting file change.
[Grani_HostsFile](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_HostsFile)|cHostsFile|Operate hosts file entry with configuration.
[Grani_InheritACL](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_InheritACL)|cInheritACL|Manage NTFS AccessRule Inheritance. Use cACL to manage each access rules for further usage.
[Grani_PendingReboot](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_PendingReboot) | cPendingReboot | Allow you to handle reboot with configuration both LocalConfigurationManager ```RebootNodeIfNeeded``` setting as $true/$false.
[Grani_PfxImport](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_PfxImport)|cPfxImport|Import Pfx file into desired CertStore / or Remove pfx from CertStore.
[Grani_RegistryKey](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_RegistryKey) | cRegistryKey | Allow you to handle Registry SubKey with Configuration.
[Grani_S3Content](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_S3Content)|cS3Content|Download and track change with S3 Object and Local File.
[Grani_ScheduleTask](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_ScheduleTask)|cScheduledTask|Enable you to configure Schedule Task. (Not all property supported, but quiet a lot.)
[Grani_ScheduleTaskLog](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_ScheduleTaskLog)|cScheduledTaskLog|Enable/Disable Scheduled Task Log
[Grani_SymbolicLink](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_SymbolicLink)| cSymbolicLink | Create/Remove SymbolicLink.
[Grani_TCPAckFrequency](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_TCPAckFrequency)|cTCPAckFrequency|Enable/Disable TCPAckFrequency
[Grani_TopShelf](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_TopShelf)|cTopShelf|Install/Uninstall TopShelf Application
[Grani_WebPI](https://github.com/guitarrapc/GraniResource/tree/master/DSCResources/Grani_WebPI)|cWebPI|Install WebPlatformInstaller Products(You cannot uninstall from WebPI)



Directory Tree
----

DirectoryName | Description
----|----
Designer | Contains xDSCResourceDesigner script to create ```*.schame.mof``` and ```*.psm1```.
DSCResource | Contains  DSC Resource source code.
Package | Contains Zip file for release tags.
Test | Contains Pester and Configuration Tests for each DSC Resource.

How to release new version
----

Creating new package zip is Fully integrated with Visual Studio.

1. Open GraniResource.Sln with Visual Studio. 
1. Open Property for **DSCResources**.
1. Go to Assembly Information.
1. Increment Assetmbly version. This version will be automatically used in ```GraniResource.psd1``` and zip file naming. 
1. Change Build setting to **Release** build and run build.
1. Now you will find new DSC Module is created in ```TmpPackage\GraniResource```, and zip file is created in ```Package\GraniResource_{AssemblyVersion}.zip```.

