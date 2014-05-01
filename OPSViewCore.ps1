function Execute-OPSViewRESTCall
{
    Param(
        [string]$verb,
        [string]$service,
        $parameters,
        [string]$payload,
        $OPSViewSession
    )

    #URL encode the parameters
    if ($parameters.count)
    {
        $j = "?"
        foreach ($key in $parameters.Keys)
        {
            $service += $j + $key + "=" + [System.Web.HttpUtility]::UrlEncode($parameters[$key])
            $j = "&"
        }
    }
    
    $verb = $verb.ToLower()

    #use the global param if one not specified
    if (!$OPSViewSession) { $OPSViewSession = $Global:OPSViewSession }

    #build the service URL
    $url = $OPSViewSession['baseURL'] + $service

    if ($OPSViewSession['debug'] -eq $true) { write-host $url }
    #assemble the headers
    if ($OPSViewSession['token'])
    {
        $headers = @{}
        $headers['X-Opsview-Username'] = $OPSViewSession['username']
        $headers['X-Opsview-Token'] = $OPSViewSession['token']
    }

    ##Invoke-RestMethod should just accept a body for gets and send it ... it's not forbidden. Bah!
    if (@('post','put','delete') -match $verb)
    {
        $result = Invoke-RestMethod `
            -ContentType 'application/json' `
            -Headers $headers `
            -Method $verb `
            -uri $url `
            -Body $payload
    }
    elseif (@('get') -match $verb)
    {
        $result = Invoke-RestMethod `
            -ContentType 'application/json' `
            -Headers $headers `
            -Method $verb `
            -uri $url
    }
    return $result
        
}

function Connect-OPSView
{
    Param(
        [string]$baseURL,
        [string]$username,
        [string]$password,
        $creds
    )
    if ($creds)
    {
        $username = $creds.UserName.toString().Trim("\")
        $password = $creds.GetNetworkCredential().password
    }
    #todo: Connect-OPSView :: check for empty username/password
    #todo: Connect-OPSView :: add a switch to avoid setting the global OPSViewSession

    #build the credentials json
    $global:OPSViewSession = @{}
    $global:OPSViewSession['baseURL'] = $baseURL
    $global:OPSViewSession['username'] = $username

    $ovcreds = @{}
    $ovcreds['username'] = $username
    $ovcreds['password'] = $password
    $json = ConvertTo-Json $ovcreds

    
    $result = Execute-OPSViewRESTCall -service '/rest/login' -payload $json -verb "post"
    if ($result)
    {
        $global:OPSViewSession['token'] = $result.token
    }


}
function Get-OPSViewAPI
{
    Param(
        $OPSViewSession
    )
    $service = "/rest"
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession
    return $result
}
function Get-OPSViewInfo
{
    Param(
        $OPSViewSession
    )
    $service = "/rest/info"
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession
    return $result
}
function Get-OPSViewUserInfo
{
    Param(
        $OPSViewSession
    )
    $service = "/rest/user"
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession
    return $result
}
function Get-OPSViewServerInfo
{
    Param(
        $OPSViewSession
    )
    $service = "/rest/serverinfo"
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession
    return $result
}

function Start-OPSViewReload
{
    Param(
        $OPSViewSession
    )
    $service = '/rest/reload'
    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -OPSViewSession $OPSViewSession
    return $result
}


function Get-OPSViewConfig
{
    Param(
        [string]$objectType,
        $filter,
        $OPSViewSession
    )
    $service = '/rest/config/' + $objectType

    #Write-Host $service
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession -parameters $filter
    return $result
}
