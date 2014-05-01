function Get-OPSViewContact
{
    Param(
        [string]$name,
        [string]$id,
        [string]$fullname,
        $filter,
        $OPSViewSession
    )
    if (!$filter) { $filter = @{} }
    if ($name) { $filter['s.name'] = $name }
    if ($id) { $filter['s.id'] = $id }
    if ($fullname) { $filter['s.fullname'] = $fullname }

    $result = Get-OPSViewconfig -objectType 'contact' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
