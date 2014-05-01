function OPSViewEpoch
{
    Param(
        [string]$timestamp
    )
    $start = Get-Date -Date "01/01/1970"
    $end = Get-date -date $timestamp
    return (New-TimeSpan -Start $start -end $end).TotalSeconds
}

function Get-OPSViewObjectType
{
    Param(
        $OPSViewObject,
        $is
    )
    if (!$OPSViewObject.ref) { return $false }
    $result = $OPSViewObject.ref

    $result = $result.replace("/rest/","")

    #drop the trailing ID
    $result = $result.substring(0,$result.LastIndexOf('/'))
    
    if ($is)
    {
        return ($result -eq $is)
    }
    else
    {
        return $result
    }

}