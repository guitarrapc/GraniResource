Grani_TopShelf
============

DSC Resource to configure RegistryKey.

Resource Information
----

Name | FriendlyName | ModuleName 
-----|-----|-----
Grani_RegistryKey | cRegistryKey | GraniResource

Test Status
----

See GraniResource.Test for the detail.

Method | Result
----|----
Pester| pass
Configuration| pass
Get-DSCConfiguration| pass
Test-DSCConfiguration| pass

Intellisense
----

![](cRegistryKey.png)

Sample
----

- Add RegistryKey

this will add fuga/nyao key and it's parent.

```powershell
configuration present
{
    Import-DscResource -ModuleName GraniResource
    cRegistryKey hoge
    {
        Key = "HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
        Ensure = "Present"
    }    
}
```

- Remove RegistryKey

this will remove fuga/nyao key only. parent path will remain.

```powershell
configuration absent
{
    Import-DscResource -ModuleName GraniResource
    cTopShelf hoge
    {
        ServiceName = "SampleTopShelfService"
        Path = (Resolve-Path ".\SampleTopShelfService\SampleTopShelfService\bin\Debug\SampleTopShelfService.exe").Path
        Ensure = "Absent"
    }
}
```

Tips
----

**When do I need to use it?**

- Scene 1.

As MSFT_Registry never handle RegistryKey, but it only handle Registry values. This resource will allow you to manage RegistryKey where it doesn't exist for Regisry Value.

- Scene 2.

As MSFT_Registy have issue with creating registry path which contains slash "/", like "HKEY_LOCAL_MACHINE\hoge/fuga\nyao", it confuse / as path separater. It means MSFT resource under stand as "HKEY_LOCAL_MACHINE\hoge\fuga\nyao".

With this resource you will be able to handle even path contains /.