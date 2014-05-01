function OPSViewEpoch
{
    Param(
        [string]$timestamp
    )
    $start = Get-Date -Date "01/01/1970"
    $end = Get-date -date $timestamp
    return (New-TimeSpan -Start $start -end $end).TotalSeconds
}
