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
function Add-OPSViewKeyword
{

}
function Remove-OPSViewKeyword
{
    Param(
        $OPSViewKeyword,
        $OPSViewSession
    )
    if (!$OPSViewKeyword.id) { Throw "Delete-OPSViewHost requires a keyword object. Use Get-OPSViewKeyword." }
    $service = "/rest/config/keyword/" + $OPSViewKeyword.id
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -OPSViewSession $OPSViewSession
    return $result
}
