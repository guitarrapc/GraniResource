$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_InheritACL : *-TargetResource" {

    $path = "d:\test";
    $invalidPath = "d:\invalid";
    $protected = $true;
    $notprotected = $false;
    $preserveInheritance = $true;
    $notpreserveInheritance = $false;
    
    if (Test-Path $invalidPath){ Remove-Item -Path $invalidPath -Recurse -Force; }
    if (Test-Path $path){ Remove-Item -Path $path -Recurse -Force; }
    New-Item -Path $path -ItemType Directory -Force > $null;

    Context "Scratch environment. " {
        It "Get-TargetResource should not throw with valid path" {
            {Get-TargetResource -Path $path -IsProtected $notprotected -PreserveInheritance $preserveInheritance} | should not Throw
        }

        It "Get-TargetResource should not throw with invalid path" {
            {Get-TargetResource -Path $invalidPath -IsProtected $notprotected -PreserveInheritance $preserveInheritance} | should not Throw
        }

        $result = Get-TargetResource -Path $path -IsProtected $notprotected -PreserveInheritance $preserveInheritance
        It "Get-TargetResource should return Ensure : Present" {
            $result.Ensure | should be "Present"
        }

        It "Get-TargetResource should return Path : $path" {
            $result.Path | should be $path
        }

        It "Get-TargetResource should return IsProtected : $notprotected" {
            $result.IsProtected | should be $notprotected
        }

        It "Get-TargetResource should return PreserveInheritance : $preserveInheritance" {
            $result.PreserveInheritance | should be $preserveInheritance
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $preserveInheritance} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $preserveInheritance).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $preserveInheritance | should be $true
        }
    }

    Context "Already configured environment. Same Path / not protected / preserveInheritance." {
        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Path $path -IsProtected $notprotected -PreserveInheritance $preserveInheritance).Ensure | should be "Absent"
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -Path $path -IsProtected $notprotected -PreserveInheritance $preserveInheritance} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Path $path -IsProtected $notprotected -PreserveInheritance $preserveInheritance).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Path $path -IsProtected $notprotected -PreserveInheritance $preserveInheritance | should be $true
        }
    }

    Context "Scratch environment. Same Path / protected / not preserveInheritance." {

       It "Set-TargetResource should Throw for no access result remain." {
            {
                $acl = Get-Acl -Path $path;
                $notInheritAccessRules = $acl.Access | where IsInherited -eq $false
                foreach ($access in $notInheritAccessRules)
                {
                    # Remove all not inherited rules
                    $acl.RemoveAccessRule($access);
                }
                $acl | Set-Acl -Path $path
                Set-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $notpreserveInheritance
            } | should Throw
        }

        It "Set-TargetResource should not Throw when any access result remain." {
            $acl = Get-Acl -Path $path;
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("Users","FullControl","ContainerInherit, ObjectInherit", "None","Allow")
            # add not inherited rule before hand
            $acl.SetAccessRule($accessRule)
            $acl | Set-Acl $path
            {Set-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $notpreserveInheritance} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $notpreserveInheritance).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -Path $path -IsProtected $protected -PreserveInheritance $notpreserveInheritance | should be $true
        }
    }

    if (Test-Path $invalidPath){ Remove-Item -Path $invalidPath -Recurse -Force; }
    if (Test-Path $path){ Remove-Item -Path $path -Recurse -Force; }
}