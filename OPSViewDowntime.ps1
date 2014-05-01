function Get-OPSViewDowntime
{
    Param(
        [string]$objectType,
        $filter,
        $OPSViewSession
    )
    $service = '/rest/downtime'
    if ($filter.count)
    {
        $service += "?"
        foreach ($f in $filter)
        {
            $service += "s." + $f.keys + "=" + $f.Values
        }
    }
    #Write-Host $service
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession
    return $result.list
}
