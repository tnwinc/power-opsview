<#

#>

function Get-OPSViewDowntime
{
    Param(
        $OPSViewHost,
        $filter,
        $OPSViewSession
    )
    if (!$filter) { $filter = @{} }
    if ($OPSViewHost) { $filter['hostname'] = $OPSViewHost.name }
    $service = '/rest/downtime'

    #Write-Host $service
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession -parameters $filter
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
function Remove-OPSViewDowntime
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewDowntime,
        $OPSViewSession
    )
    $service = '/rest/downtime'
    
    $parameters = @{}
    if ($OPSViewDowntime.objects.hosts)
    {
        $parameters['hst.hostname'] = $OPSViewDowntime.objects.hosts[0].hostname
    }
    $parameters['comment'] = $OPSViewDowntime.comment
    $parameters['starttime'] = $OPSViewDowntime.start_time
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -parameters $parameters
    return $result
}
