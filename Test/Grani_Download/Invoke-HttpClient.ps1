$parent = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulePath = $parent.Replace("Test","GraniResource")
$name = Split-Path $modulePath -leaf
iex (Get-Content (Join-Path $modulePath "$name.psm1") -Raw).Replace("Export-ModuleMember -Function *-TargetResource", "")
