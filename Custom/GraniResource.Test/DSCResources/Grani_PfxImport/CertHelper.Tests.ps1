$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_PfxImport : ValidationHelper" {

    Context "GetCertPath test" {
        It "CertStoreName : My should not Throw." {
            {GetCertPath -CertStoreName My } | Should not Throw
        }

        It "[System.String] => CertStoreName : My should be Cert:\LocalMachine\My." {
            GetCertPath -CertStoreName My | Should be "Cert:\LocalMachine\My"
        }

        foreach ($x in [Enum]::GetNames([System.Security.Cryptography.X509Certificates.StoreName]))
        {
            It "[System.Security.Cryptography.X509Certificates.StoreName] => CertStoreName : $x should be Cert:\LocalMachine\$x." {
                GetCertPath -CertStoreName $x | Should be "Cert:\LocalMachine\$x"
            }
        }
    }
}
 