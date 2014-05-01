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

function Add-OPSViewDowntime
{
    #todo: Add-OPSViewDowntime :: This function is barely functional. It needs support for all the OpsView object types, as well as supporting collections of objects
    Param(
        $OPSViewHost,
        [Parameter(Mandatory=$True)]$starttime,
        $endtime,
        $duration,
        [Parameter(Mandatory=$True)]$comment,
        $OPSViewSession
    )
    $service = "/rest/downtime"

    $parameters = @{}
    $parameters['starttime'] = $starttime
    if ($endtime) { $parameters['endtime'] = $endtime }
    if ($comment) { $parameters['comment'] = $comment }
    if ($duration) { $parameters['endtime'] = $duration }
    if ($OPSViewHost) { $parameters['hst.hostname'] = $OPSViewHost.name }

    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -parameters $parameters
    return $result
}
