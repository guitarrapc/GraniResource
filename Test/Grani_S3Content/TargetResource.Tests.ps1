$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_S3Content : *-TargetResource" {
    $regions = @("", "us-west-2")
    foreach ($region in $regions) {
        try {
            
            $path = "c:\hoge\ReadMe.md"
            $parent = Split-Path -Path $path -Parent

            $bucketName = [Guid]::NewGuid()
            # $key =     [Guid]::NewGuid()
            $key = '8f7a6322-4fee-44f1-a2eb-533a7e9dff33'
            $checksum = "FileName"

            New-Item -Path $parent -ItemType Directory -Force > $null
            New-Item -Path $path -ItemType File -Force  > $null
            1..10 | Get-Random -Count 10 | Out-File -FilePath $path -Append -Force > $null

            if ([string]::IsNullOrWhiteSpace($region)) {
                New-S3Bucket -BucketName $bucketName > $null
                Write-S3Object -BucketName $bucketName -Key $key -File $path
            }
            else {
                New-S3Bucket -BucketName $bucketName -Region $region
                Write-S3Object -BucketName $bucketName -Key $key -File $path -Region $region
            }

            Remove-Item -Path $parent -Recurse -Force > $null

            #region CheckSum : FileHash
            Context "Scratch environment. CheckSum : FileHash / Region ($region)" {
                It "Get-TargetResource should not throw for invalid S3Bucket" {
                    {Get-TargetResource -S3BucketName "hogemoge$bucketName" -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should not throw for invalid S3Object" {
                    {Get-TargetResource -S3BucketName "$bucketName" -Key "$key-$bucketName" -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should not throw for invalid Path" {
                    {Get-TargetResource -S3BucketName "$bucketName" -Key "$key" -DestinationPath "$path-$bucketName" -Region $region} | should not Throw
                }

                It "Get-TargetResource should not throw for invalid S3Bucket / S3Object / Path" {
                    {Get-TargetResource -S3BucketName "$hogemoge$bucketName" -Key "$key-$bucketName" -DestinationPath "$path-$bucketName" -Region $region} | should not Throw
                }

                It "Get-TargetResource should not throw for valid S3Bucket / S3Object" {
                    {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                $result = Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region
                It "Get-TargetResource should return Ensure : Absent" {
                    $result.Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
                }

                It "Get-TargetResource should return DestinationPath : $path" {
                    $result.DestinationPath | should be $path
                }

                It "Get-TargetResource should return BucketName : $bucketName" {
                    $result.S3BucketName | should be $bucketName
                }

                It "Get-TargetResource should return Key : $key" {
                    $result.Key | should be $key
                }

                It "Get-TargetResource should return Region : $region" {
                    $result.Region | should be $region
                }

                It "Test-TargetResource should return false" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $false
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Present" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
                }

                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $true
                }
            }

            Context "Already configured environment. CheckSum : FileHash / Region ($region)" {
                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $true
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Present" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
                }

                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $true
                }
            }

            Context "Already configured but delete file environment. CheckSum : FileHash / Region ($region)" {
                Remove-Item -Path $path -Force

                It "Get-TargetResource should not throw" {
                    {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Absent" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
                }

                It "Test-TargetResource should return false" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $false
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Present" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
                }

                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $true
                }
            }

            Context "Exist same name Folder environment. CheckSum : FileHash / Region ($region)" {
                Remove-Item -Path $path -Force
                New-Item -Path $path -ItemType Directory > $null

                It "Get-TargetResource should not throw" {
                    {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Absent" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
                }

                It "Test-TargetResource should return false" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region | should be $false
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region} | should Throw
                }
            }
 
            Remove-Item -Path $parent -Recurse -Force

            #endregion

            #region CheckSum : FileName

            Context "Scratch environment. CheckSum : FileName / Region ($region)" {
                It "Get-TargetResource should not throw" {
                    {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region -CheckSum $checkSum} | should not Throw
                }

                $result = Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -Region $region
                It "Get-TargetResource should return Ensure : Absent" {
                    $result.Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
                }

                It "Get-TargetResource should return DestinationPath : $path" {
                    $result.DestinationPath | should be $path
                }

                It "Get-TargetResource should return BucketName : $bucketName" {
                    $result.S3BucketName | should be $bucketName
                }

                It "Get-TargetResource should return Key : $key" {
                    $result.Key | should be $key
                }

                It "Get-TargetResource should return Region : $region" {
                    $result.Region | should be $region
                }

                It "Test-TargetResource should return false" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $false
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Present" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
                }

                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $true
                }
            }

            Context "Already configured environment. CheckSum : FileHash / Region ($region)" {
                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $true
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Present" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
                }

                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $true
                }
            }

            Context "Already configured but delete file environment. CheckSum : FileHash / Region ($region)" {
                Remove-Item -Path $path -Force

                It "Get-TargetResource should not throw" {
                    {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Absent" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
                }

                It "Test-TargetResource should return false" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $false
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Present" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Present.ToString())
                }

                It "Test-TargetResource should return true" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $true
                }
            }

            Context "Exist same name Folder environment. CheckSum : FileHash / Region ($region)" {
                Remove-Item -Path $path -Force
                New-Item -Path $path -ItemType Directory > $null

                It "Get-TargetResource should not throw" {
                    {Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region} | should not Throw
                }

                It "Get-TargetResource should return Ensure : Absent" {
                    (Get-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region).Ensure | should be ([GraniDonwloadEnsuretype]::Absent.ToString())
                }

                It "Test-TargetResource should return false" {
                    Test-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region | should be $false
                }

                It "Set-TargetResource should not Throw" {
                    {Set-TargetResource -S3BucketName $bucketName -Key $key -DestinationPath $path -CheckSum $checkSum -Region $region} | should Throw
                }
            }

            #endregion    
        }
        finally {
            Remove-Item -Path $parent -Recurse -Force
            if ([string]::IsNullOrWhiteSpace($region)) {
                Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force
            }
            else {
                Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force -Region $region
            }       
        }
    }
}