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
    $script:cacheLocation = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltinProvCache\Grani_Download"

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

# Debug Message
$debugMessage = DATA {
    ConvertFrom-StringData -StringData "
        AddRequestHeader = Adding Request Header. Key : '{0}', Value : '{1}'
        AddContentType = Adding ContentType : '{0}'
        AddUserAgent = Adding UserAgent : '{0}'
        AddCredential = Adding Network Credential for Basic Authentication. UserName : '{0}'
        DownloadStream = Status Code returns '{0}'. Start download stream from uri : '{1}'
        DownloadComplete = Download content complete.
        ItemTypeWasFile = Destination Path found as File : '{0}'
        ItemTypeWasDirectory = Destination Path found but was Directory : '{0}'
        ItemTypeWasOther = Destination Path found but was neither File nor Directory: '{0}'
        ItemTypeWasNotExists = Destination Path not found : '{0}'
        TestUriConnection = Testing connection to the uri : {0}
        UpdateFileHashCache = Updating cache path '{1}' for current Filehash SHA256 '{0}'.
        ValidateUri = Cast uri string '{0}' to System.Uri.
        ValidateFilePath = Check DestinationPath '{0}' and Parent Directory already exist.
        WriteStream = Start writing downloaded stream to File Path : '{0}'
    "
}

# Throw Message
$exceptionMessage = DATA {
    ConvertFrom-StringData -StringData "
        InvalidCastURI = Uri : '{0}' casted to [System.Uri] but was invalid string for uri. Make sure you have passed valid uri string.
        InvalidUriSchema = Specified URI is not valid: '{0}'. Only http|https|file are accepted.
        InvalidResponce = Status Code returns '{0}'. Stop download stream from uri : '{1}'
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
        [System.String]$DestinationPath
    )

    # Checking Destination Path is existing and Valid as a FileInfo
    $itemType = Get-ChildItem -Path $DestinationPath -File | GetPathItemType
    $fileExists = $false
    switch ($itemType)
    {
        [GraniDonwloadItemTypeEx]::FileInfo
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasFile -f $DestinationPath)
            $fileExists = $true
        }
        [GraniDonwloadItemTypeEx]::DirectoryInfo
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasDirectory -f $DestinationPath)
        }
        [GraniDonwloadItemTypeEx]::Other
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasOther -f $DestinationPath)
        }
        [GraniDonwloadItemTypeEx]::NotExists
        {
            Write-Debug -Message ($debugMessage.ItemTypeWasNotExists -f $DestinationPath)
        }
    }

    # Matching FileHash to verify file is already exist/Up-To-Date or not.
    $ensure = "Absent"
    if ($fileExists -eq $true)
    {
        $currentFileHash = GetFileHash -Path $DestinationPath
        $cachedFileHash = GetCache -DestinationPath $DestinationPath -Uri $Uri

        if ($currentFileHash -eq $cachedFileHash)
        {
            $ensure = "Present"
        }
    }

    return @{
        Ensure = $ensure
        DestinationPath = $DestinationPath
        Uri = $Uri
    }
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

    # validate Uri can be parse to [uri] and Schema is http|https|file
    $validUri = ValidateUri -Uri $Uri

    # validate DestinationPath is valid
    ValidateFilePath -Path $DestinationPath

    # Start Download
    Invoke-HttpClient -Uri $validUri -Path $DestinationPath -Header $Header -ContentType $ContentType -UserAgent $UserAgent -Credential $Credential

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

            Write-Debug -Message ($debugMessage.DownloadStream -f $res.Result.StatusCode.value__, $Uri)
            [System.Threading.Tasks.Task`1[System.IO.Stream]]$stream = $httpClient.GetStreamAsync($Uri)
            $stream.ConfigureAwait($false) > $null
            if ($stream.Exception -ne $null){ throw $stream.Exception }

            #endregion

            #region Write Stream to the file

            Write-Debug -Message ($debugMessage.WriteStream -f $Path)
            $fileStream = [System.IO.File]::Create($Path)
            $stream.Result.CopyTo($fileStream)

            Write-Debug -Message ($debugMessage.DownloadComplete)

            #endregion

        }
        catch [System.Exception]
        {
            throw $_
        }
        finally
        {
            if (($null -ne $res) -and ($res.IsCompleted -eq $true)){ $res.Dispose() }
            if (($null -ne $stream) -and ($stream.IsCompleted -eq $true)){ $stream.Dispose() }
            if ($null -ne $fileStream){ $fileStream.Dispose() }
            if ($null -ne $httpClient){ $httpClient.Dispose() }
            if ($null -ne $httpClientHandler){ $httpClientHandler.Dispose() }
        }
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
    if (Test-Path -Path $Path)
    {
        return;
    }

    # Create Parent Directory check
    $parentPath = Split-Path $Path -Parent
    if (-not (Test-Path -Path $parentPath))
    {
        [System.IO.Directory]::CreateDirectory($parentPath) > $null
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
        [System.String]$Path
    )

    $type = [string]::Empty

    # Check type of the Path Item
    if (-not (Test-Path -Path $Path))
    {
        return [GraniDonwloadItemTypeEx]::NotExists
    }
    
    $pathItem = Get-Item -Path $path
    $pathItemType = $pathItem.GetType().FullName
    $type = if ($pathItemType -eq "System.IO.FileInfo")
    {
        [GraniDonwloadItemTypeEx]::FileInfo
    }
    elseif ($pathItemType -eq "System.IO.DirectoryInfo")
    {
        [GraniDonwloadItemTypeEx]::DirectoryInfo
    }
    else
    {
        [GraniDonwloadItemTypeEx]::Other
    }

    return $type
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
#endregion
