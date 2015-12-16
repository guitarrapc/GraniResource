$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_S3Content : HashHelper" {

    # Local definition
    $pathF = "c:\hoge\ReadMe.md"
    $pathD = "c:\hoge\ReadMe"
    $pathNotExist = "c:\hoge\notexist.md"

    $parent = Split-Path -Path $pathF -Parent
    New-Item -Path $parent -ItemType Directory -Force > $null

    New-Item -Path $pathF -ItemType File -Force > $null
    New-Item -Path $pathD -ItemType Directory -Force > $null

    # S3 definition
    $bucketName = [Guid]::NewGuid().ToString()
    $key = [Guid]::NewGuid().ToString()

    Context "GetFileHash should get Local FileHash" {

        It "Folder should be null" {
            GetFileHash -Path $pathD | should be $null
        }

        It "GetFileHash should not BeNullOrEmpty" {
            GetFileHash -Path $pathF | Should Not BeNullOrEmpty
        }

        It "GetFileHash should be MD5 hash string." {
            GetFileHash -Path $pathF | Should be (Get-FileHash -Path $pathF -Algorithm MD5).Hash
        }

        It "GetFileHash should not be SHA256 hash string." {
            GetFileHash -Path $pathF | Should not be (Get-FileHash -Path $pathF -Algorithm SHA256).Hash
        }
    }

    Context "GetS3ObjectHash should get S3 FileHash" {

        It "Bucket not exist should Throw" {
            {GetS3ObjectHash -Bucket $pathNotExist -Key $Key} | Should Throw
        }

        New-S3Bucket -BucketName $bucketName > $null

        It "Bucket exist but Key not exist should Throw" {
            {GetS3ObjectHash -Bucket $bucketName -Key $Key} | Should Throw
        }

        Write-S3Object -BucketName $bucketName -Key $Key -File $pathF

        It "Bucket/Key exist should not Throw" {
            {GetS3ObjectHash -Bucket $bucketName -Key $Key} | Should not Throw
        }

        Read-S3Object -BucketName $bucketName -Key $key -File $pathF > $null
    }

    Context "GetFileHash and GetS3ObjectHash should get same hash" {

        It "S3Hash should same as LocalHash." {
            GetFileHash -Path $pathF | Should be (GetS3ObjectHash -Bucket $bucketName -Key $key)
        }
    }

    Remove-Item -Path $parent -Force -Recurse > $null
    Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force
}
