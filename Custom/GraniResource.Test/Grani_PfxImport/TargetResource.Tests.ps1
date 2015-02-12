#Requires 
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_PfxImport : *-TargetResource" {

    if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        return "This test requires Administrative Privilege. Make sure Pester invoke from UAC Promoted PowerShell."
    }
    
    $certPath = GetCertPath -CertStoreName My
    $dns = "test.contoso.com"
    $file = "test.pfx"
    $parent = "D:\hoge"
    $exportLocation = Join-Path $parent $file

    # create self-signed certificate
    $cert = New-SelfSignedCertificate -Dns $dns -CertStoreLocation $certPath

    # export certificate
    New-Item -Path $parent -ItemType Directory -Force > $null
    $credential = Get-Credential
    Export-PfxCertificate -Force -Password $credential.Password -FilePath $exportLocation -Cert $cert.PSPath
    Remove-Item -Path $cert.PSPath -Force

    Context "Scratch environment. " {
        It "Get-TargetResource should not throw" {
            {Get-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential} | should not Throw
        }

        $result = Get-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential
        It "Get-TargetResource should return Ensure : Absent" {
            $result.Ensure | should be "Absent"
        }

        It "Get-TargetResource should return ThumbPrint : $($cert.thumbPrint)" {
            $result.ThumbPrint | should be $cert.thumbPrint
        }

        It "Get-TargetResource should return PfxFilePath : $exportLocation" {
            $result.PfxFilePath | should be $exportLocation
        }

        It "Get-TargetResource should return CertStoreName : My" {
            $result.CertStoreName | should be "My"
        }

        It "Test-TargetResource should return false" {
            Test-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential | should be $false
        }

        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential | should be $true
        }

        It "Pfx Should exist in Cert Location" {
            Test-Path $cert.PSPath | Should be $true
        }

        It "Pfx Should exist in File Location" {
            Test-Path $exportLocation | Should be $true
        }
    }

    Context "Already configured environment. Same ThumbPrint." {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Present" {
            (Get-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential).Ensure | should be "Present"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Present -PfxFilePath $exportLocation -CertStoreName My -Credential $credential | should be $true
        }
    }

    Context "Absent test." {
        It "Set-TargetResource should not Throw" {
            {Set-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Absent -PfxFilePath $exportLocation -CertStoreName My -Credential $credential} | should not Throw
        }

        It "Get-TargetResource should return Ensure : Absent" {
            (Get-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Absent -PfxFilePath $exportLocation -CertStoreName My -Credential $credential).Ensure | should be "Absent"
        }

        It "Test-TargetResource should return true" {
            Test-TargetResource -ThumbPrint $cert.ThumbPrint -Ensure Absent -PfxFilePath $exportLocation -CertStoreName My -Credential $credential | should be $true
        }

        It "Pfx Should not exist in Cert Location" {
            Test-Path $cert.PSPath | Should be $false
        }

        It "Pfx Should not exist in File Location" {
            Test-Path $exportLocation | Should be $false
        }
    }
}