Get-ChildItem ".\*" -Filter "OPSView*.ps1" | `
ForEach-Object {
    . $_.FullName
}

. .\Connect.ps1

#$k = Get-OPSViewKeyword -name "labrie"


#Remove-OPSViewKeyword -OPSViewKeyword $k