function ValidateTaskPathLastChar ($taskPath)
{
    $lastChar = [System.Linq.Enumerable]::ToArray($taskPath) | select -Last 1
    if ($lastChar -ne "\"){ return $taskPath + "\" }
    return $taskPath
}
