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
    $parameters['hst.hostname'] = 'N1-LAB-REL-001'
    $OPSViewDowntime.objects = $null
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -parameters $parameters
    return $result
}

<#
$h = Get-OPSViewHost -name "N1-LAB-REL-001"
echo $h
$dt = Add-OPSViewDowntime -OPSViewHost $h -starttime "now" -duration "+2h" -comment "The system is down."

echo $dt
#>

$dt = Get-OPSViewDowntime

echo $dt

#Remove-OPSViewDowntime -OPSViewDowntime $dt