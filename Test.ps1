Get-ChildItem ".\*" -Filter "OPSView*.ps1" | `
ForEach-Object {
    . $_.FullName
}

. .\Connect.ps1



$computername = "N1-LAB-REL-001"

$h = Get-OPSViewHost -name $computername
$dt = Add-OPSViewDowntime -OPSViewHost $h -starttime "now" -duration "+5m" -comment "Restart IIS"
$s = Get-Service -ComputerName $computername -Name w3svc
$s.stop()
$s.start()
echo $dt

sleep 1 #OPSView actions are asynchronous so a quick sleep makes sure it posted before trying to remove
$dt = Get-OPSViewDowntime -OPSViewHost $h
Remove-OPSViewDowntime -OPSViewDowntime $dt

