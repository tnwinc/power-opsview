Get-ChildItem ".\*" -Filter "OPSView*.ps1" | `
ForEach-Object {
    . $_.FullName
}

. .\Connect.ps1



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
    echo $parameters | ft
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -parameters $parameters
    return $result
}

<#
$h = Get-OPSViewHost -name "N1-LAB-REL-001"
echo $h
$dt = Add-OPSViewDowntime -OPSViewHost $h -starttime "now" -duration "+2h" -comment "The system is down."

echo $dt
#>
$h = Get-OPSViewHost -name "N1-LAB-REL-001"

<#
$dt = Add-OPSViewDowntime -OPSViewHost $h -starttime "now" -duration "+2h" -comment "baz"
echo $dt
#>

$dt = Get-OPSViewDowntime -filter @{'hostname'=$h.name}
echo $dt

#Remove-OPSViewDowntime -OPSViewDowntime $dt