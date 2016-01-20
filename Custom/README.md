GraniResource
============

This directory includes Custom DSC Resource created by guitarrapc and used in Grani Production.

Installation
----

You can retrieve Resource through [PoweShellGet](https://www.powershellgallery.com/packages/GraniResource).
```powershell
Install-Module GraniResource
```

Directory Tree
----

DirectoryName | Description
----|----
Designer | Contains xDSCResourceDesigner script to create ```*.schame.mof``` and ```*.psm1```.
GraniResource | Contains  DSC Resource source code.
Package | Contains Zip file for release tags.
Test | Contains Pester and Configuration Tests for each DSC Resource.

Where can I see how to usage of DSCResource?
----

You may find README.md inside DSCResource\ResourceNameFolder\README.md.
