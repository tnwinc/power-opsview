function Get-OPSViewKeyword
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

    $result = Get-OPSViewconfig -objectType 'keyword' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
Function Add-OPSViewKeyword
{
    Param(
        [Parameter(Mandatory=$True)]$name,
        $clone,
        $properties,
        $OPSViewSession
    )
    $service = "/rest/config/keyword"

    if ($clone) { $service += "/" + $clone.id }
    if (!$properties) { $properties = @{} }

    $properties['name'] = $name

    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -payload (ConvertTo-Json $properties) -OPSViewSession $OPSViewSession
    return $result
}
function Remove-OPSViewKeyword
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewKeyword,
        $OPSViewSession
    )
    if (!$OPSViewKeyword.id) { Throw "Delete-OPSViewHost requires a keyword object. Use Get-OPSViewKeyword." }
    $service = "/rest/config/keyword/" + $OPSViewKeyword.id
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -OPSViewSession $OPSViewSession
    return $result
}
function Set-OPSViewKeyword
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewKeyword,
        $properties,
        $OPSViewSession
    )
    $service = '/rest/config/keyword/' + $OPSViewKeyword.id
    $result = Execute-OPSViewRESTCall -verb 'put' -service $service -OPSViewSession $OPSViewSession -payload (ConvertTo-Json $properties)
    return $result

}
