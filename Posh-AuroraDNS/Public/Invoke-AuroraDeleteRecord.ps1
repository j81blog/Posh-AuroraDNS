function Invoke-AuroraDeleteRecord {
    <#
.SYNOPSIS
    Delete an Aurora DNS Record
.DESCRIPTION
    Delete an Aurora DNS Record
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER ZoneID
    Specify a specific Aurora DNS Zone ID (GUID).
.PARAMETER RecordID
    Specify a specific Aurora DNS Record ID (GUID).
.PARAMETER Api
    The Aurora DNS API hostname.
    Default (if not specified): api.auroradns.eu
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>Invoke-AuroraDeleteRecord -ZoneID aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee  -RecordID vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz @auroraAuthorization
    Delete a record with the ID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' in zone 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
.NOTES
    Function Name : Invoke-AuroraDeleteRecord
    Version       : v2021.0522.1915
    Author        : John Billekens
    Requires      : API Account => https://cp.pcextreme.nl/auroradns/users
.LINK
    https://blog.j81.nl
#> 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Key,
        
        [Parameter(Mandatory)]
        [string]$Secret,
        
        [Parameter(Mandatory)]
        [GUID[]]$ZoneID,
        
        [Parameter(Mandatory)]
        [GUID[]]$RecordId,
        
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
    $Method = 'DELETE'
    $Uri = '/zones/{0}/records/{1}' -f $ZoneID.Guid, $RecordId.Guid
    $ApiUrl = 'https://{0}{1}' -f $Api, $Uri
    $AuthorizationHeader = Get-AuroraDNSAuthorizationHeader -Key $Key -Secret $Secret -Method $Method -Uri $Uri
    $restError = ''
    
    Write-Debug "$Method URI: `"$ApiUrl`""
    try {
        $result = Invoke-RestMethod -Uri $ApiUrl -Headers $AuthorizationHeader -Method $Method -UseBasicParsing:$UseBasicParsing -ErrorVariable restError
    } catch {
        $result = $null
        $OutError = $restError[0].Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        Write-Debug $($OutError | Out-String)
        Throw ($OutError.errormsg)
    }
    if ([String]::IsNullOrEmpty($($result.id))) {
        Write-Debug "The function generated no data"
        Write-Output $null
    } else {
        Write-Output $result
    }
}
