#region Initialize

function Initialize
{
    # Load Assembly to use HttpClient
    try
    {
        Add-Type -AssemblyName System.Net.Http
    }
    catch
    {
    }

    # cache Location Variable
    # MSFT using this path, but this always clear when LCM runs. It means whenever you run "Get" you can't refer cache. 
    # => need to change to persistence path to match with cache.
    # $script:cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltinProvCache\Grani_Download"
    $script:cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\CustomProvCache\Grani_Download"

    # Enum for Item Type
    Add-Type -TypeDefinition @"
        public enum GraniDonwloadItemTypeEx
        {
            FileInfo,
            DirectoryInfo,
            Other,
            NotExists
        }
"@
}

Initialize

#endregion

#region Message Definition

$debugMessage = DATA {
    ConvertFrom-StringData -StringData "
        AddRequestHeader = Adding Request Header. Key : '{0}', Value : '{1}'
        AddContentType = Adding ContentType : '{0}'
        AddUserAgent = Adding UserAgent : '{0}'
        AddCredential = Adding Network Credential for Basic Authentication. UserName : '{0}'
        DownloadComplete = Download content complete.
        IsDestinationPathExist = Checking Destination Path is existing and Valid as a FileInfo
        IsDestinationPathAlreadyUpToDate = Matching FileHash to verify file is already exist/Up-To-Date or not.
        IsFileAlreadyUpToDate = CurrentFileHash : CachedFileHash -> {0} : {1}
        IsFileExists = File found from DestinationPath. Checking already up-to-date.
        ItemTypeWasFile = Destination Path found as File : '{0}'
        ItemTypeWasDirectory = Destination Path found but was Directory : '{0}'
        ItemTypeWasOther = Destination Path found but was neither File nor Directory: '{0}'
        ItemTypeWasNotExists = Destination Path not found : '{0}'
        SetCacheLocationPath = CacheLocation Value detected. Setting Custom CacheLocation Path : '{0}'
        TestUriConnection = Testing connection to the uri : {0}
        UpdateFileHashCache = Updating cache path '{1}' for current Filehash SHA256 '{0}'.
        ValidateUri = Cast uri string '{0}' to System.Uri.
        ValidateFilePath = Check DestinationPath '{0}' is FileInfo and Parent Directory already exist.
        WriteStream = Start writing downloaded stream to File Path : '{0}'
    "
}

$verboseMessage = DATA {
    ConvertFrom-StringData -StringData "
        alreadyUpToDate = Current DestinationPath FileHash and Cache FileHash matched. File already Up-To-Date.
        DownloadStream = Status Code returns '{0}'. Start download stream from uri : '{1}'
        notUpToDate = Current DestinationPath FileHash and Cache FileHash not matched. Need to download latest file.
    "
}
$exceptionMessage = DATA {
    ConvertFrom-StringData -StringData "
        InvalidCastURI = Uri : '{0}' casted to [System.Uri] but was invalid string for uri. Make sure you have passed valid uri string.
        InvalidUriSchema = Specified URI is not valid: '{0}'. Only http|https|file are accepted.
        InvalidResponce = Status Code returns '{0}'. Stop download stream from uri : '{1}'
        DestinationPathAlreadyExistAsNotFile = Destination Path '{0}' already exist but not a file. Found itemType is {1}. Windows not allowed exist same name item.
    "
}

#endregion

#region *-Resource

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Uri,

        [parameter(Mandatory = $true)]
        [System.String]$DestinationPath,

        [parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$Header = $null,

        [parameter(Mandatory = $false)]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$UserAgent = "Mozilla/5.0 (Windows NT; Windows NT 6.3; en-US) WindowsPowerShell/{0}" -f $PSVersionTable.PSVersion.ToString(),

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true,

        [parameter(Mandatory = $false)]
        [System.String]$CacheLocation = [string]::Empty
    )

    # Set Custom Cache Location
    if ($CacheLocation -ne [string]::Empty)
    {
        Write-Debug -Message ($debugMessage.SetCacheLocationPath -f $CacheLocation)
        $script:cacheLocation = $CacheLocation
    }

    # Initialize return values
    $returnHash = 
    @{
        Uri = $Uri
        DestinationPath = $DestinationPath
        ContentType = $ContentType
        UserAgent = $UserAgent
        AllowRedirect = $AllowRedirect
        Ensure = "Absent"

    }

    if ($null -ne $Heaer)
    {
        $returnHash.Header = $Header.GetEnumerator()
    }

    # Destination Path check
    Write-Debug -Message $debugMessage.IsDestinationPathExist
    $itemType = GetPathItemType -Path $DestinationPath

    $fileExists = $false
    switch ($itemType.ToString())
    {
        ([GraniDonwloadItemTypeEx]::FileInfo.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasFile -f $DestinationPath)
            $fileExists = $true
        }
        ([GraniDonwloadItemTypeEx]::DirectoryInfo.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasDirectory -f $DestinationPath)
        }
        ([GraniDonwloadItemTypeEx]::Other.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasOther -f $DestinationPath)
        }
        ([GraniDonwloadItemTypeEx]::NotExists.ToString())
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasNotExists -f $DestinationPath)
        }
    }

    # Already Up-to-date Check
    Write-Debug -Message $debugMessage.IsDestinationPathAlreadyUpToDate
    if ($fileExists -eq $true)
    {
        Write-Debug -Message $debugMessage.IsFileExists
        $currentFileHash = GetFileHash -Path $DestinationPath
        $cachedFileHash = GetCache -DestinationPath $DestinationPath -Uri $Uri

        Write-Debug -Message ($debugMessage.IsFileAlreadyUpToDate -f $currentFileHash, $cachedFileHash)
        if ($currentFileHash -eq $cachedFileHash)
        {
            Write-Verbose -Message $verboseMessage.alreadyUpToDate
            $returnHash.Ensure = "Present"
        }
        else
        {
            Write-Verbose -Message $verboseMessage.notUpToDate
        }
    }

    return $returnHash
}


function Set-TargetResource
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Uri,

        [parameter(Mandatory = $true)]
        [System.String]$DestinationPath,

        [parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$Header = $null,

        [parameter(Mandatory = $false)]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$UserAgent = "Mozilla/5.0 (Windows NT; Windows NT 6.3; en-US) WindowsPowerShell/{0}" -f $PSVersionTable.PSVersion.ToString(),

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true,

        [parameter(Mandatory = $false)]
        [System.String]$CacheLocation = [string]::Empty
    )

    # Set Custom Cache Location
    if ($CacheLocation -ne [string]::Empty)
    {
        Write-Debug -Message ($debugMessage.SetCacheLocationPath -f $CacheLocation)
        $script:cacheLocation = $CacheLocation
    }

    # validate Uri can be parse to [uri] and Schema is http|https|file
    $validUri = ValidateUri -Uri $Uri

    # validate DestinationPath is valid
    ValidateFilePath -Path $DestinationPath

    # Convert CimInstance to HashTable
    $headerHashtable = ConvertKCimInstanceToHashtable -CimInstance $Header

    # Start Download
    Invoke-HttpClient -Uri $validUri -Path $DestinationPath -Header $headerHashtable -ContentType $ContentType -UserAgent $UserAgent -Credential $Credential

    # Update Cache for FileHash
    UpdateCache -DestinationPath $DestinationPath -Uri $validUri
}


function Test-TargetResource
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$Uri,

        [parameter(Mandatory = $true)]
        [System.String]$DestinationPath,

        [parameter(Mandatory = $false)]
        [Microsoft.Management.Infrastructure.CimInstance[]]$Header = $null,

        [parameter(Mandatory = $false)]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$UserAgent = "Mozilla/5.0 (Windows NT; Windows NT 6.3; en-US) WindowsPowerShell/{0}" -f $PSVersionTable.PSVersion.ToString(),

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true,

        [parameter(Mandatory = $false)]
        [System.String]$CacheLocation = [string]::Empty
    )

    return (Get-TargetResource -DestinationPath $DestinationPath -Uri $Uri).Ensure -eq "Present"
}

#endregion

#region HttpClient Helper

function Invoke-HttpClient
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [uri]$Uri,

        [parameter(Mandatory = $true)]
        [string]$Path,

        [parameter(Mandatory = $false)]
        [System.Collections.Hashtable]$Header = @{},

        [parameter(Mandatory = $false)]
        [System.String]$ContentType = "application/json",

        [parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]$Credential = [PSCredential]::Empty,

        [parameter(Mandatory = $false)]
        [System.String]$UserAgent = "Mozilla/5.0 (Windows NT; Windows NT 6.3; en-US) WindowsPowerShell/{0}" -f $PSVersionTable.PSVersion.ToString(),

        [parameter(Mandatory = $false)]
        [System.Boolean]$AllowRedirect = $true
    )

    begin
    {
        #region Initialize

        # Should support Timeout? : Default -> 1:40 min
        # Should support MaxResponseContentBufferSize? : Default -> 2147483647

        $httpClientHandler = New-Object System.Net.Http.HttpClientHandler
        $httpClientHandler.AllowAutoRedirect = $AllowRedirect
        
        $httpClient = New-Object System.Net.Http.HttpClient ($httpClientHandler)

        # Request Header
        if ($Header.Keys.Count -ne 0)
        {
            foreach ($item in $Header.GetEnumerator())
            {
                Write-Debug -Message ($debugMessage.AddRequestHeader -f $item.Key, $item.Value)
                $httpClient.DefaultRequestHeaders.Add($item.Key, $item.Value)
            }
            
            # Keep-Alive
            $httpClient.DefaultRequestHeaders.Add("Keep-Alive", "true")
        }

        # ContentType
        if ($ContentType -ne [string]::Empty)
        {
            Write-Debug -Message ($debugMessage.AddContentType -f $ContentType)
            $private:mediaType = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue($ContentType)
            $httpClient.DefaultRequestHeaders.Accept.Add($mediaType)
        }

        # UserAgent
        if ($UserAgent -ne [string]::Empty)
        {
            Write-Debug -Message ($debugMessage.AddUserAgent -f $UserAgent)
            $httpClient.DefaultRequestHeaders.UserAgent.ParseAdd($UserAgent)
        }

        # Credential
        if ($Credential -ne [PSCredential]::Empty)
        {
            # Credential on Handler does not work with Basic Authentication : http://stackoverflow.com/questions/25761214/why-would-my-rest-service-net-clients-send-every-request-without-authentication
            # $httpClientHandler.Credential = $Credential

            Write-Debug -Message ($debugMessage.AddCredential -f $Credential.UserName)
            $encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes([String]::Format( "{0}:{1}", $Credential.UserName, $Credential.GetNetworkCredential().Password)));
            $httpClient.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue ("Basic", $encoded) # Basic Authentication Only
        }

        #endregion
    }

    end
    {
        try
        {
            #region Test Connection

            Write-Debug -Message ($debugMessage.TestUriConnection -f $Uri.ToString())
            $res = $httpClient.GetAsync($Uri)
            $res.ConfigureAwait($false) > $null
            if ($res.Exception -ne $null){ throw $res.Exception }
            if ($res.Result.StatusCode -ne [System.Net.HttpStatusCode]::OK){ throw ($exceptionMessage.InvalidResponce -f $res.Result.StatusCode.value__, $Uri) }
            
            #endregion

            #region Execute Download

            Write-Verbose -Message ($verboseMessage.DownloadStream -f $res.Result.StatusCode.value__, $Uri)
            [System.Threading.Tasks.Task`1[System.IO.Stream]]$stream = $httpClient.GetStreamAsync($Uri)
            $stream.ConfigureAwait($false) > $null
            if ($stream.Exception -ne $null){ throw $stream.Exception }

            #endregion

            #region Write Stream to the file

            WriteStream -Path $Path -Stream $stream
            
            #endregion

            Write-Debug -Message ($debugMessage.DownloadComplete)
        }
        catch [System.Exception]
        {
            throw $_
        }
        finally
        {
            if (($null -ne $res) -and ($res.IsCompleted -eq $true)){ $res.Dispose() }
            if ($null -ne $httpClient){ $httpClient.Dispose() }
            if ($null -ne $httpClientHandler){ $httpClientHandler.Dispose() }
        }
    }
}

function WriteStream
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path,

        [parameter(Mandatory = $true)]
        [System.Threading.Tasks.Task`1[System.IO.Stream]]$Stream
    )

    try
    {
        # Write stream to the File
        Write-Debug -Message ($debugMessage.WriteStream -f $Path)
        $fileStream = [System.IO.File]::Create($Path)
        $Stream.Result.CopyTo($fileStream)
    }
    finally
    {
        if ($null -ne $fileStream){ $fileStream.Dispose() }
        if (($null -ne $Stream) -and ($Stream.IsCompleted -eq $true)){ $Stream.Dispose() }
    }
}

#endregion

#region Validation Helper

function ValidateUri
{
    [OutputType([uri])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Uri
    )
    
    Write-Debug -Message ($debugMessage.ValidateUri -f $Uri)
    [uri]$result = $Uri -as [uri]
    if ($result.AbsolutePath -eq $null){ throw New-Object System.NullReferenceException ($exceptionMessage.InvalidCastURI -f $Uri)}
    if ($result.Scheme -notin "http", "https", "file")
    {
        $errorId = "UriValidationFailure";
        $errorMessage = $exceptionMessage.InvalidUriSchema -f ${Uri}
        ThrowInvalidDataException -ErrorId $errorId -ErrorMessage $errorMessage
    }
    return $result
}

function ValidateFilePath
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path
    )
    
    Write-Debug -Message ($debugMessage.ValidateFilePath -f $Path)
    $itemType = GetPathItemType -Path $Path
    switch ($itemType.ToString())
    {
        ([GraniDonwloadItemTypeEx]::FileInfo.ToString())
        {
            return;
        }
        ([GraniDonwloadItemTypeEx]::NotExists.ToString())
        {
            # Create Parent Directory check
            $parentPath = Split-Path $Path -Parent
            if (-not (Test-Path -Path $parentPath))
            {
                [System.IO.Directory]::CreateDirectory($parentPath) > $null
            }
        }
        Default
        {
            $errorId = "FileValudationFailure"
            $errorMessage = $exceptionMessage.DestinationPathAlreadyExistAsNotFile -f $Path, $itemType.ToString()
            ThrowInvalidDataException -ErrorId $errorId -ErrorMessage $errorMessage
        }
    }

}

#endregion

#region Cache Helper

function GetFileHash
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash
}

function GetCacheKey
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [string]$Uri
    )

    $key = [string]::Join("", @($DestinationPath, $Uri)).GetHashCode().ToString()
    return $key
}

function GetCache
{
    [OutputType([string])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [string]$Uri
    )

    $cacheKey = GetCacheKey -DestinationPath $DestinationPath -Uri $Uri
    $path = Join-Path $script:cacheLocation $cacheKey
    
    # Test Cache Path is exist
    if (-not (Test-Path -Path $path)){ return [string]::Empty }

    # Get FileHash from Cache File
    $fileHash = (Import-CliXml -Path $path).FileHash
    return $fileHash    
}

function UpdateCache
{
    [OutputType([void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [string]$Uri
    )

    $cacheKey = GetCacheKey -DestinationPath $DestinationPath -Uri $Uri
    $path = Join-Path $script:cacheLocation $cacheKey

    # create cacheLocaltion Directory
    if (-not (Test-Path -Path $script:cacheLocation))
    {
        [System.IO.Directory]::CreateDirectory($script:cacheLocation) > $null
    }

    # Create Cache Object
    $fileHash = GetFileHash -Path $DestinationPath
    $obj = NewXmlObject -DestinationPath $DestinationPath -Uri $Uri -FileHash $fileHash

    # export cache to CliXML
    Write-Debug ($debugMessage.UpdateFileHashCache -f $fileHash, $Path)
    $obj | Export-CliXml -Path $path -Force
}

function NewXmlObject
{
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [parameter(Mandatory = $true)]
        [uri]$Uri,

        [parameter(Mandatory = $true)]
        [string]$FileHash
    )
    
    $obj = @{}
    $obj.FileHash = $FileHash
    $obj.WriteTime = [System.IO.File]::GetLastWriteTimeUtc($DestinationPath)
    $obj.Path = $DestinationPath
    $obj.Uri = $Uri.AbsoluteUri.ToString()
    return [PSCustomObject]$obj
}

#endregion

#region ItemType Helper

function GetPathItemType
{
    [OutputType([GraniDonwloadItemTypeEx])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName", "LiteralPath", "PSPath")]
        [System.String]$Path = [string]::Empty
    )

    $type = [string]::Empty

    # Check type of the Path Item
    if (-not (Test-Path -Path $Path))
    {
        return [GraniDonwloadItemTypeEx]::NotExists
    }
    
    $pathItem = Get-Item -Path $path
    $pathItemType = $pathItem.GetType().FullName
    $type = switch ($pathItemType)
    {
        "System.IO.FileInfo"
        {
            [GraniDonwloadItemTypeEx]::FileInfo
        }
        "System.IO.DirectoryInfo"
        {
            [GraniDonwloadItemTypeEx]::DirectoryInfo
        }
        Default
        {
            [GraniDonwloadItemTypeEx]::Other
        }
    }

    return $type
}

#endregion

#region Converter from Microsoft.Management.Infrastructure.CimInstance[] (KeyValuePair) to HashTable

function ConvertKCimInstanceToHashtable
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $false)]
        [AllowNull()]
        [Microsoft.Management.Infrastructure.CimInstance[]]$CimInstance
    )

    if ($null -eq $CimInstance)
    {
        return @{}
    }

    $hashtable = New-Object System.Collections.Generic.List[hashtable]
    foreach($item in $CimInstance.GetEnumerator())
    {
        $hashtable.Add(@{$item.Key = $item.Value})
    }

    return $hashtable
}

#endregion

#region Exception Helper

function ThrowInvalidDataException
{
    [OutputType([Void])]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]$ErrorId,

        [parameter(Mandatory = $true)]
        [System.String]$ErrorMessage
    )
    
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidData
    $exception = New-Object System.InvalidOperationException $ErrorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $ErrorId, $errorCategory, $null
    throw $errorRecord
}