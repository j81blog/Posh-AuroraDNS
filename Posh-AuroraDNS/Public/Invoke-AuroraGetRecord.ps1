function Invoke-AuroraGetRecord {
    <#
.SYNOPSIS
    Get Aurora DNS Record
.DESCRIPTION
    Get Aurora DNS Record
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER RecordID
    Specify a specific Aurora DNS Record ID (GUID).
.PARAMETER RecordName
    Specify a specific Aurora DNS Record Name (String).
.PARAMETER ZoneID
    Specify a specific Aurora DNS Zone ID (GUID).
.PARAMETER Api
    The Aurora DNS API hostname.
    Default (if not specified): api.auroradns.eu
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$record = Invoke-AuroraGetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' @auroraAuthorization
    List all records by not specifying 'RecordID' or 'RecordName' with a value
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$record = Invoke-AuroraGetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -RecordName 'www' @auroraAuthorization
    Get record with name 'www' in zone 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$record = Invoke-AuroraGetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -RecordID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' @auroraAuthorization
    Get record with ID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' in zone 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
.NOTES
    Function Name : Invoke-AuroraGetRecord
    Version       : v2021.0522.1915
    Author        : John Billekens
    Requires      : API Account => https://cp.pcextreme.nl/auroradns/users
.LINK
    https://blog.j81.nl
#>  
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Key,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Secret,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [GUID[]]$ZoneID,

        [Parameter(ParameterSetName = 'GUID', Mandatory)]
        [GUID[]]$RecordID = $null,
        
        [Parameter(ParameterSetName = 'Named', Mandatory)]
        [String]$RecordName = $null,
        
        [Parameter()]
        [String]$Api = 'api.auroradns.eu',
        
        [Parameter(DontShow)]
        [Switch]$UseBasicParsing,
        
        [Parameter(ValueFromRemainingArguments, DontShow)]
        $ExtraParams
    )
    if ($PSBoundParameters.ContainsKey('UseBasicParsing')) {
        $UseBasicParsing = [bool]::Parse($UseBasicParsing)
    } elseif (($null -ne $script:UseBasic) -and ($script:UseBasic['UseBasicParsing'] -is [bool])) {
        $UseBasicParsing = [bool]::Parse($script:UseBasic['UseBasicParsing'])
    } else {
        $UseBasicParsing = $true
    }
    $Method = 'GET'
    if ([String]::IsNullOrEmpty($($RecordID.Guid))) {
        $Uri = '/zones/{0}/records' -f $ZoneID.Guid
    } else {
        $Uri = '/zones/{0}/records/{1}' -f $ZoneID.Guid, $RecordID.Guid
    }
    $ApiUrl = 'https://{0}{1}' -f $Api, $Uri
    $AuthorizationHeader = Get-AuroraDNSAuthorizationHeader -Key $Key -Secret $Secret -Method $Method -Uri $Uri
    $restError = ''
    try {
        Write-Debug "$Method URI: `"$ApiUrl`""
        [Object[]]$result = Invoke-RestMethod -Uri $ApiUrl -Headers $AuthorizationHeader -Method $Method -UseBasicParsing:$UseBasicParsing -ErrorVariable restError
        if (-Not [String]::IsNullOrEmpty($RecordName)) {
            [Object[]]$result = $result | Where-Object { $_.name -eq $RecordName }
        }
    } catch {
        $result = $null
        $OutError = $restError[0].Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        Write-Debug $($OutError | Out-String)
        if ($OutError.error -eq 'NoSuchRecordError') {
            $result = $null
        } else {
            Throw ($OutError.errormsg)
        }
    }
    if ([String]::IsNullOrEmpty($($result.id))) {
        Write-Debug "The function generated no data"
        Write-Output $null
    } else {
        Write-Output $result
    }
}
