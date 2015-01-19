function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]$Enable
    )

    $value = if ($Enable)
    {
        2
    }
    else
    {
        1
    }

    Get-NetworkInterfaceRegisty `
    | where TcpAckFrequency -ne $value `
    | %{ Set-ItemProperty -Path $_.PSPath -Name TcpAckFrequency -Value $value -Force -PassThru }
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]$Enable
    )
 
    $value = if ($Enable)
    {
        2
    }
    else
    {
        1
    }

    $tcpAckFrequency = (Get-NetworkInterfaceRegisty).TcpAckFrequency | sort -Unique
    if ($null -eq $tcpAckFrequency){ $tcpAckFrequency = 2 }
    $result = $value -eq $tcpAckFrequency

    return @{
        Enable = $Enable
        NetworkInterfaceName = $NetworkInterfaceName
        Result = $result
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]$Enable
    )

    $result = Get-TargetResource -Enable $Enable
    return $result.Result
}

function Get-NetworkInterfaceRegisty
{
    [CmdletBinding()]
    [OutputType([Microsoft.Win32.RegistryKey[]])]
    param
    ()

    return Get-ChildItem -Path "registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" `
    | where {
        Get-ItemProperty -Path "registry::$_" `
        | where AddressType -eq 0
    }
}