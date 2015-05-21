$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_RegistryKey : RegistryKey" {

    $Key = "HKEY_LOCAL_MACHINE\hoge\hoge\hoge"
    $Key2 = "HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
    $key3 = "HKLM:\SOFTWARE\hoge/piyo\fuga/nyao"
    $key4 = "HKCU:\SOFTWARE\hoge/piyo\fuga/nyao"
    $invalidKey = "H_CU\SOFTWARE\hoge/piyo\fuga/nyao"

    Context "GetRegistryPSDrive" {

        It "GetRegistryPSDrive should not throw" {
            {GetRegistryPSDrive -PSDriveKey $key3} | Should not throw
        }

        It "GetRegistryPSDrive return PSDriveRetter. : $key3" {
            (GetRegistryPSDrive -PSDriveKey $key3).ToString() | Should be "HKLM"
        }

        It "GetRegistryPSDrive return PSDriveRetter. : $key4" {
            (GetRegistryPSDrive -PSDriveKey $key4).ToString() | Should be "HKCU"
        }

        It "GetRegistryPSDrive should throw for invalid key" {
            {GetRegistryPSDrive -PSDriveKey $invalidKey} | Should throw
        }
    }
    
    Context "IsRegistryKeyRootFullQualified" {

        It "IsRegistryKeyRootFullQualified should not throw" {
            {IsRegistryKeyRootFullQualified -Key $key} | Should not throw
        }

        It "IsRegistryKeyRootFullQualified should return true. : $key" {
            IsRegistryKeyRootFullQualified -Key $key | Should be $true
        }

        It "IsRegistryKeyRootFullQualified should return true. : $key2" {
            IsRegistryKeyRootFullQualified -Key $key2 | Should be $true
        }

        It "IsRegistryKeyRootFullQualified should return false : $invalidKey" {
            IsRegistryKeyRootFullQualified -Key $invalidKey | Should be $false
        }
    }

    Context "IsRegistryKeyRootPSDrive" {

        It "IsRegistryKeyRootPSDrive should not throw" {
            {IsRegistryKeyRootPSDrive -Key $key3} | Should not throw
        }

        It "IsRegistryKeyRootPSDrive should return true. : $key3" {
            IsRegistryKeyRootPSDrive -Key $key3 | Should be $true
        }

        It "IsRegistryKeyRootPSDrive should return true. : $key4" {
            IsRegistryKeyRootPSDrive -Key $key4 | Should be $true
        }

        It "IsRegistryKeyRootPSDrive should return false : $invalidKey" {
            IsRegistryKeyRootPSDrive -Key $invalidKey | Should be $false
        }
    }

    Context "ConvertPSDriveKeyToFullQualifiedKey" {

        It "ConvertPSDriveKeyToFullQualifiedKey should not throw" {
            {ConvertPSDriveKeyToFullQualifiedKey -PSDriveKey $key3} | Should not throw
        }

        It "ConvertPSDriveKeyToFullQualifiedKey add registry:: with key. : $key3" {
            ConvertPSDriveKeyToFullQualifiedKey -PSDriveKey $key3 | Should be "HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
        }

        It "ConvertPSDriveKeyToFullQualifiedKey add registry:: with key. : $key4" {
            ConvertPSDriveKeyToFullQualifiedKey -PSDriveKey $key4 | Should be "HKEY_CURRENT_USER\SOFTWARE\hoge/piyo\fuga/nyao"
        }

        It "ConvertPSDriveKeyToFullQualifiedKey should throw for invalid key" {
            {ConvertPSDriveKeyToFullQualifiedKey -PSDriveKey $invalidKey} | Should throw
        }
    }

    Context "ConvertToRegistryFullQualifiedPath" {

        It "ConvertToRegistryFullQualifiedPath should not throw" {
            {ConvertToRegistryFullQualifiedPath -Key $key} | Should not throw
        }

        It "ConvertToRegistryFullQualifiedPath add registry:: with key. : $key" {
            ConvertToRegistryFullQualifiedPath -Key $key | Should be "registry::$key"
        }

        It "ConvertToRegistryFullQualifiedPath add registry:: with key. : $key2" {
            ConvertToRegistryFullQualifiedPath -Key $key2 | Should be "registry::$key2"
        }

        It "ConvertToRegistryFullQualifiedPath add registry:: with key. : $key3" {
            ConvertToRegistryFullQualifiedPath -Key $key3 | Should be "registry::HKEY_LOCAL_MACHINE\SOFTWARE\hoge/piyo\fuga/nyao"
        }

        It "ConvertToRegistryFullQualifiedPath add registry:: with key. : $key4" {
            ConvertToRegistryFullQualifiedPath -Key $key4 | Should be "registry::HKEY_CURRENT_USER\SOFTWARE\hoge/piyo\fuga/nyao"
        }

        It "ConvertToRegistryFullQualifiedPath should throw for invalid key" {
            {ConvertToRegistryFullQualifiedPath -Key $invalidKey} | Should throw
        }
    }

    Context "GetRegistryRoot" {

        It "GetRegistryRoot Should not throw" {
            {GetRegistryRoot -Path $key} | Should not throw
        }

        It "GetRegistryRoot returns root : $key" {
            (GetRegistryRoot -Path $key).ToString() | Should be "HKEY_LOCAL_MACHINE"
        }

        It "GetRegistryRoot returns root : $key2" {
            (GetRegistryRoot -Path $key2).ToString() | Should be "HKEY_LOCAL_MACHINE"
        }

        It "GetRegistryRoot should throw for PSDrive format : $key3" {
            {GetRegistryRoot -Path $key3} | Should throw
        }

        It "GetRegistryRoot should throw for PSDrive format : $key4" {
            {GetRegistryRoot -Path $key4} | Should throw
        }

        It "GetRegistryRoot should throw for invalid key" {
            {GetRegistryRoot -Path $key4} | Should throw
        }
    }
}
