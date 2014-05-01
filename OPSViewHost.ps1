function Get-OPSViewHost
{
    Param(
        [string]$name,
        [string]$id,
        $filter,
        $OPSViewSession
    )
    if (!$filter) { $filter = @{} }
    if ($name) { $filter['s.name'] = $name }
    if ($id) { $filter['s.id'] = $id }

    $result = Get-OPSViewconfig -objectType 'host' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}

function Add-OPSViewHost
{
    Param(
        [Parameter(Mandatory=$True)]$hostname,
        [Parameter(Mandatory=$True)]$title,
        $clone,
        $properties,
        $OPSViewSession
    )
    $service = "/rest/config/host"

    if ($clone) { $service += "/" + $clone.id }
    if (!$properties) { $properties = @{} }

    $properties['name'] = $title
    $properties['ip'] = $hostname

    echo $properties | ft
    echo $service
    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -payload (ConvertTo-Json $properties) -OPSViewSession $OPSViewSession
    return $result
}

function Remove-OPSViewHost
{
    Param(
        [Alias("host")]$OPSViewHost,
        $OPSViewSession
    )
    if (!$host.id) { Throw "Delete-OPSViewHost requires a host object. Use Get-OPSViewHost." }
    $service = '/rest/config/host/' + $OPSViewHost.id
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -OPSViewSession $OPSViewSession
    return $result
}
function Set-OPSViewHost
{
    Param(
        [Alias("host")]$OPSViewHost,
        $properties,
        $OPSViewSession
    )
    $service = '/rest/config/host/' + $OPSViewHost.id
    $result = Execute-OPSViewRESTCall -verb 'put' -service $service -OPSViewSession $OPSViewSession -payload (ConvertTo-Json $properties)
    return $result
}
