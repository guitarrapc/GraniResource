Import-Module xDSCResourceDesigner
$property = @()
$property += New-xDscResourceProperty `
    -Name DestinationPath `
    -Type String `
    -Attribute key `
    -Description "File Path to output Donwloaded item."
$property += New-xDscResourceProperty `
    -Name Repository `
    -Type String `
    -Attribute Required `
    -Description "GitHub Repository name to access. refer : https://developer.github.com/v3/repos/contents/"
$property += New-xDscResourceProperty `
    -Name RepositoryOwner `
    -Type String `
    -Attribute Required `
    -Description "GitHub Repository Owner Name which content owns. refer : https://developer.github.com/v3/repos/contents/"
$property += New-xDscResourceProperty `
    -Name ContentPath `
    -Type String `
    -Attribute Required `
    -Description "Path to the content. If README.md under root, then just README.md. Make sure path is case-sensitive. refer : https://developer.github.com/v3/repos/contents/"
$property += New-xDscResourceProperty `
    -Name Branch `
    -Type String `
    -Attribute Write `
    -Description "Specify Branch name for the content. Default is master. refer : https://developer.github.com/v3/repos/contents/"
$property += New-xDscResourceProperty `
    -Name OAuth2Token `
    -Type PSCredential `
    -Attribute Required `
    -Description "OAuth2 access token for GitHub Api Authorization. UserName value will not been in use. refer : https://developer.github.com/v3/#authentication"
$property += New-xDscResourceProperty `
    -Name Header `
    -Type Hashtable -Attribute Write -Description "Specify Headers for Web Request. if you need any 'if' or other header control. refer : https://developer.github.com/v3/"
$property += New-xDscResourceProperty `
    -Name ContentType `
    -Type String `
    -Attribute Write `
    -ValueMap "application/json", "application/vnd.github+json", "application/vnd.github.v3.raw", "application/vnd.github.v3.html" `
    -Values "application/json", "application/vnd.github+json", "application/vnd.github.v3.raw", "application/vnd.github.v3.html" `
    -Description "Select Media Type to access GitHub API Default is application/json. You need change for each content type. refer : https://developer.github.com/v3/media/"
$property += New-xDscResourceProperty `
    -Name UserAgent `
    -Type String `
    -Attribute Write `
    -Description "Specify User-Agent for Web Request. Default is powerShell user-agent default. refer : https://developer.github.com/v3/#user-agent-required"
$property += New-xDscResourceProperty `
    -Name AllowRedirect `
    -Type Boolean `
    -Attribute Write `
    -Description "Specify if you want to control Redirect. Default is true as Github requires. refer : https://developer.github.com/v3/#http-redirects"
$property += New-xDscResourceProperty `
    -Name CacheLocation `
    -Type String `
    -Attribute Write `
    -Description "Specify CacheLocation to hold your last configuration result."
$property += New-xDscResourceProperty `
    -Name Ensure `
    -Type String `
    -Attribute Read `
    -ValueMap Present, Absent `
    -Values Present, Absent `
    -Description "Describe File is exist on DestinationPath or not."

New-xDscResource -Name Grani_GitHubApiContent -Property $property -Path .\ -ModuleName GraniResource -FriendlyName cGitHubApiContent -Force

