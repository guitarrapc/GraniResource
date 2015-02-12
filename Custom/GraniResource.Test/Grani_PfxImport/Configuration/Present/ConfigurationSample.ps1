# variables
$certPath = GetCertPath -CertStoreName My
$dns = "test.contoso.com"
$file = "test.pfx"
$parent = "C:\hoge"
$exportLocation = Join-Path $parent $file

# create self-signed certificate
$cert = New-SelfSignedCertificate -Dns $dns -CertStoreLocation $certPath

# export certificate
New-Item -Path $parent -ItemType Directory -Force > $null
Export-PfxCertificate -Force -Password $credential.Password -FilePath $exportLocation -Cert $cert.PSPath
Remove-Item -Path $cert.PSPath -Force

configuration pfxImport
{
    param
    (
        [PSCredential]$Credential
    )
    Import-DscResource -ModuleName GraniResource

    node $Allnodes.Where{$_.Role -eq "localhost"}.NodeName
    {
        cPfxImport hoge
        {
            ThumbPrint = $cert.Thumbprint
            Ensure = "Present"
            PfxFilePath = $exportLocation
            CertStoreName = "My"
            Credential = $Credential
        }
    }
}

$configurationData = @{
    AllNodes = @(
        @{
            NodeName = '*'
            PSDSCAllowPlainTextPassword = $true
        }
        @{
            NodeName = "localhost"
            Role     = "localhost"
        }
    )
}
pfxImport -Credential (Get-Credential) -ConfigurationData $configurationData
Start-DscConfiguration -Wait -Verbose -Force -Path pfxImport