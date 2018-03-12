$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_S3Content : ValidationHelper" {
    $regions = @("", "us-west-2")
    foreach ($region in $regions) {
        try {

            $bucketName = [Guid]::NewGuid()
            $key = [Guid]::NewGuid()

            $path = "c:\hoge\ReadMe.md"
            $parent = Split-Path -Path $path -Parent

            New-Item -Path $parent -ItemType Directory -Force > $null
            New-Item -Path $path -ItemType File -Force > $null

            if ([string]::IsNullOrWhiteSpace($region)) {
                New-S3Bucket -BucketName $bucketName
                Write-S3Object -BucketName $bucketName -Key $key -File $path
            } else {
                New-S3Bucket -BucketName $bucketName -Region $region
                Write-S3Object -BucketName $bucketName -Key $key -File $path -Region $region
            }

            Context "S3Bucket test : Region ($region)" {
        
                It "S3Bucket not exist Should Throw" {
                    {ValidateS3Bucket -BucketName "hogemoge$bucketName" -Region $region} | Should Throw
                }

                It "S3Bucket exist should not Throw." {
                    {ValidateS3Bucket -BucketName $bucketName -Region $region} | Should not Throw
                }
            }

            Context "S3Object test : Region ($region)" {
        
                It "S3Object not exist Should Throw" {
                    {ValidateS3Object -BucketName $bucketName -Key "hogemoge$key" -Region $region} | Should Throw
                }

                It "S3Object exist should not Throw." {
                    {ValidateS3Object -BucketName $bucketName -Key $key -Region $region} | Should not Throw
                }
            }

            Context "ValidateFile test : Region ($region)" {
        
                It "Parent Directory Should created when not exists." {
                    Remove-Item -Path $parent -Recurse -Force > $null
                    ValidateFilePath -Path $path
                    (Get-Item -Path $parent).GetType().FullName | should be "System.IO.DirectoryInfo"
                }

                It "Nothing should do when File already exist and null return." {
                    New-Item -Path $path -ItemType File > $null
                    ValidateFilePath -Path $path | should be $null
                    Remove-Item -Path $path -Force > $null
                }

                It "Already exist Directory for same name should Throw." {
                    New-Item -Path $path -ItemType Directory > $null
                    {ValidateFilePath -Path $path} | should Throw
                }        
            }
        }
        finally {
            Remove-Item -Path $parent -Recurse -Force > $null
            if ([string]::IsNullOrWhiteSpace($region)) {
                Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force > $null
            } else {
                Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force -Region $region > $null
            }
        }
    }
}