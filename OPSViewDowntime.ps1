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
function Remove-OPSViewDowntime
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewDownTime
    )
    write-host "-------------------"
    write-host $OPSViewDownTime | ft
    
    echo OPSViewEpoch -timestamp $OPSViewDownTime.start_time
    $service = '/rest/downtime'
    $service += "h.name=IT-NETOPS"
    #$service += '?start_time=' + (OPSViewEpoch -timestamp $OPSViewDownTime.start_time)
    #$service += '&comment=' + [System.Web.HttpUtility]::UrlEncode($OPSViewDownTime.comment)

    write-host $service
    $result = Execute-OPSViewRESTCall -service $service -verb "delete"
    write-host $result
}
