﻿function Get-OPSViewMonitoringServer
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

    $result = Get-OPSViewconfig -objectType 'monitoringserver' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
