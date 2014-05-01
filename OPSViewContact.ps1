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

function Set-OPSViewContact
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewContact,
        $language,
        $name,
        $variables,
        $description,
        $notificationprofiles,
        $fullname,
        $realm,
        $role,
        $uncomitted,
        $OPSViewSession
    )
    if ($OPSViewContact -is [string]) { $OPSViewContact = Get-OPSViewContact -name $OPSViewContact }
    if (!(Get-OPSViewObjectType -OPSViewObject $OPSViewContact -is 'config/contact'))
    {
        Throw "Expected string or OPSViewContact. Found $(Get-OPSViewObjectType -OPSViewObject $OPSViewContact)"
    }

    $service = $OPSViewContact.ref

    $payload = $PSBoundParameters
    $payload.Remove("OPSViewContact")
    $payload.Remove("OPSViewSession")


    $result = Execute-OPSViewRESTCall -verb 'put' -service $service -payload (ConvertTo-Json $payload) -OPSViewSession $OPSViewSession

    return $result
}
