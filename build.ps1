﻿if (Test-Path ".\build\OPSView*") { Remove-Item ".\build\OPSView*" }

Get-ChildItem ".\*" -Filter "OPSView*.ps1" | `
ForEach-Object {
    $c = Get-Content $_.FullName
    $c | Out-File ".\build\OPSView.ps1" -Append
    $c | Out-File ".\build\OPSView.psm1" -Append
}

"Export-ModuleMember -Function *" | Out-File ".\build\OPSView.psm1" -Append