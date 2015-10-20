$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_S3Content : ValidationHelper" {

    $bucketName = [Guid]::NewGuid()
    $key =     [Guid]::NewGuid()

    $path = "d:\hoge\ReadMe.md"
    $parent = Split-Path -Path $path -Parent

    New-Item -Path $parent -ItemType Directory -Force > $null
    New-Item -Path $path -ItemType File -Force > $null

    Context "S3Bucket test" {
        
        It "S3Bucket not exist Should Throw" {
            {ValidateS3Bucket -BucketName $bucketName} | Should Throw
        }

        It "S3Bucket exist should not Throw." {
            New-S3Bucket -BucketName $bucketName
            sleep -Milliseconds 500
            {ValidateS3Bucket -BucketName $bucketName} | Should not Throw
        }
    }

    Context "S3Object test" {
        
        It "S3Object not exist Should Throw" {
            {ValidateS3Object -BucketName $bucketName -Key $key} | Should Throw
        }

        It "S3Object exist should not Throw." {
            Write-S3Object -BucketName $bucketName -Key $key -File $path
            {ValidateS3Object -BucketName $bucketName -Key $key} | Should not Throw
        }
    }

    Context "ValidateFile test" {
        
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

    Remove-Item -Path $parent -Recurse -Force > $null
    Remove-S3Bucket -BucketName $bucketName -DeleteBucketContent -Force > $null
}