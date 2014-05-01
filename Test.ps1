Get-ChildItem ".\*" -Filter "OPSView*.ps1" | `
ForEach-Object {
    . $_.FullName
}

. .\Connect.ps1