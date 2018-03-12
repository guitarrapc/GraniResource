configuration DownloadS3Object
{
    Import-DscResource -ModuleName GraniResource
    cS3Content Download
    {
        S3BucketName = "YourBucketName"
        Key = "ObjectName"
        DestinationPath = "c:\Path\To\Save\Content.log"
    }
}

DownloadS3Object
Start-DscConfiguration -Verbose -Force -Wait -Path DownloadS3Object