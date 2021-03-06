function Get-OPSViewAttribute
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

    $result = Get-OPSViewconfig -objectType 'attribute' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
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
<#

#>

function Get-OPSViewDowntime
{
    Param(
        $OPSViewHost,
        $filter,
        $OPSViewSession
    )
    if (!$filter) { $filter = @{} }
    if ($OPSViewHost) { $filter['hostname'] = $OPSViewHost.name }
    $service = '/rest/downtime'

    #Write-Host $service
    $result = Execute-OPSViewRESTCall -service $service -verb "get" -OPSViewSession $OPSViewSession -parameters $filter
    return $result.list
}

function Add-OPSViewDowntime
{
    #todo: Add-OPSViewDowntime :: This function is barely functional. It needs support for all the OpsView object types, as well as supporting collections of objects
    Param(
        $OPSViewHost,
        [Parameter(Mandatory=$True)]$starttime,
        $endtime,
        $duration,
        [Parameter(Mandatory=$True)]$comment,
        $OPSViewSession
    )
    $service = "/rest/downtime"

    $parameters = @{}
    $parameters['starttime'] = $starttime
    if ($endtime) { $parameters['endtime'] = $endtime }
    if ($comment) { $parameters['comment'] = $comment }
    if ($duration) { $parameters['endtime'] = $duration }
    if ($OPSViewHost) { $parameters['hst.hostname'] = $OPSViewHost.name }

    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -parameters $parameters
    return $result
}
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
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -parameters $parameters
    return $result
}
function Get-OPSViewHost
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

    $result = Get-OPSViewconfig -objectType 'host' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}

function Add-OPSViewHost
{
    Param(
        [Parameter(Mandatory=$True)]$hostname,
        [Parameter(Mandatory=$True)]$title,
        $clone,
        $properties,
        $OPSViewSession
    )
    $service = "/rest/config/host"

    if ($clone) { $service += "/" + $clone.id }
    if (!$properties) { $properties = @{} }

    $properties['name'] = $title
    $properties['ip'] = $hostname

    echo $properties | ft
    echo $service
    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -payload (ConvertTo-Json $properties) -OPSViewSession $OPSViewSession
    return $result
}

function Remove-OPSViewHost
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewHost,
        $OPSViewSession
    )
    if (!$OPSViewHost.id) { Throw "Delete-OPSViewHost requires a host object. Use Get-OPSViewHost." }
    $service = '/rest/config/host/' + $OPSViewHost.id
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -OPSViewSession $OPSViewSession
    return $result
}
function Set-OPSViewHost
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewHost,
        $properties,
        $OPSViewSession
    )
    $service = '/rest/config/host/' + $OPSViewHost.id
    $result = Execute-OPSViewRESTCall -verb 'put' -service $service -OPSViewSession $OPSViewSession -payload (ConvertTo-Json $properties)
    return $result
}
function Get-OPSViewHostCheckCommand
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

    $result = Get-OPSViewconfig -objectType 'hostcheckcommand' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewHostGroup
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

    $result = Get-OPSViewconfig -objectType 'hostgroup' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewHostTemplate
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

    $result = Get-OPSViewconfig -objectType 'hosttemplate' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewKeyword
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

    $result = Get-OPSViewconfig -objectType 'keyword' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
Function Add-OPSViewKeyword
{
    Param(
        [Parameter(Mandatory=$True)]$name,
        $clone,
        $properties,
        $OPSViewSession
    )
    $service = "/rest/config/keyword"

    if ($clone) { $service += "/" + $clone.id }
    if (!$properties) { $properties = @{} }

    $properties['name'] = $name

    $result = Execute-OPSViewRESTCall -verb 'post' -service $service -payload (ConvertTo-Json $properties) -OPSViewSession $OPSViewSession
    return $result
}
function Remove-OPSViewKeyword
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewKeyword,
        $OPSViewSession
    )
    if (!$OPSViewKeyword.id) { Throw "Delete-OPSViewHost requires a keyword object. Use Get-OPSViewKeyword." }
    $service = "/rest/config/keyword/" + $OPSViewKeyword.id
    $result = Execute-OPSViewRESTCall -verb 'delete' -service $service -OPSViewSession $OPSViewSession
    return $result
}
function Set-OPSViewKeyword
{
    Param(
        [Parameter(Mandatory=$True)]$OPSViewKeyword,
        $properties,
        $OPSViewSession
    )
    $service = '/rest/config/keyword/' + $OPSViewKeyword.id
    $result = Execute-OPSViewRESTCall -verb 'put' -service $service -OPSViewSession $OPSViewSession -payload (ConvertTo-Json $properties)
    return $result

}
function Get-OPSViewMonitoringServer
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
function Get-OPSViewNotificationMethod
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

    $result = Get-OPSViewconfig -objectType 'notificationmethod' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewRole
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

    $result = Get-OPSViewconfig -objectType 'role' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewServiceCheck
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

    $result = Get-OPSViewconfig -objectType 'servicecheck' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewServiceGroup
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

    $result = Get-OPSViewconfig -objectType 'servicegroup' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewSharedNotificationProfile
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

    $result = Get-OPSViewconfig -objectType 'sharednotificationprofile' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function Get-OPSViewTimePeriod
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

    $result = Get-OPSViewconfig -objectType 'timeperiod' -filter $filter -OPSViewSession $OPSViewSession
    return $result.list
}
function OPSViewEpoch
{
    Param(
        [string]$timestamp
    )
    $start = Get-Date -Date "01/01/1970"
    $end = Get-date -date $timestamp
    return (New-TimeSpan -Start $start -end $end).TotalSeconds
}

function Get-OPSViewObjectType
{
    Param(
        $OPSViewObject,
        $is
    )
    if (!$OPSViewObject.ref) { return $false }
    $result = $OPSViewObject.ref

    $result = $result.replace("/rest/","")

    #drop the trailing ID
    $result = $result.substring(0,$result.LastIndexOf('/'))
    
    if ($is)
    {
        return ($result -eq $is)
    }
    else
    {
        return $result
    }

}
Export-ModuleMember -Function *
