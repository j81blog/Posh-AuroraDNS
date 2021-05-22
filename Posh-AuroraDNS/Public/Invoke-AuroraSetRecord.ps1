
function Invoke-AuroraSetRecord {
    <#
.SYNOPSIS
    Set Aurora DNS Record with new values
.DESCRIPTION
    Get Aurora DNS Record with new values
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER ZoneID
    Specify a specific Aurora DNS Zone ID (GUID).
.PARAMETER RecordID
    Specify a specific Aurora DNS Record ID (GUID).
.PARAMETER Name
    Specify a name fo the new record.
.PARAMETER Content
    Specify the content for the nwe record.
.PARAMETER TTL
    Specify a Time To Live value in seconds.
    Default (if not specified): 3600
.PARAMETER Type
    Specify the record type.
    Can contain one of the following values: "A", "AAAA", "CNAME", "MX", "NS", "SOA", "SRV", "TXT", "DS", "PTR", "SSHFP", "TLSA"
    Default (if not specified): "A"
.PARAMETER Api
    The Aurora DNS API hostname.
    Default (if not specified): api.auroradns.eu
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$record = Invoke-AuroraSetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -RecordID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' -Content 198.51.100.85 @auroraAuthorization
    Set an existing record with new content '198.51.100.85'
.NOTES
    Function Name : Invoke-AuroraAddRecord
    Version       : v2021.0522.1930
    Author        : John Billekens
    Requires      : API Account => https://cp.pcextreme.nl/auroradns/users
.LINK
    https://github.com/j81blog/Posh-AuroraDNS
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
        
        [String]$Name,
        
        [String]$Content,
        
        [int]$TTL = 3600,

        [ValidateSet('A', 'AAAA', 'CNAME', 'MX', 'NS', 'SOA', 'SRV', 'TXT', 'DS', 'PTR', 'SSHFP', 'TLSA')]
        [String]$Type = 'A',

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
    $Method = 'PUT'
    $Uri = '/zones/{0}/records/{1}' -f $ZoneId.Guid, $RecordId.Guid
    $ApiUrl = 'https://{0}{1}' -f $Api, $Uri
    $AuthorizationHeader = Get-AuroraDNSAuthorizationHeader -Key $Key -Secret $Secret -Method $Method -Uri $Uri
    $restError = ''

    $Payload = @{ }
    if ($PSBoundParameters.ContainsKey('Name')) { $Payload.Add('name', $Name) } 
    if ($PSBoundParameters.ContainsKey('TTL')) { $Payload.Add('ttl', $TTL) } 
    if ($PSBoundParameters.ContainsKey('Type')) { $Payload.Add('type', $Type) } 
    if ($PSBoundParameters.ContainsKey('Content')) { $Payload.Add('content', $Content) } 

    $Body = $Payload | ConvertTo-Json

    Write-Debug "$Method URI: `"$ApiUrl`""
    try {
        $result = Invoke-RestMethod -Uri $ApiUrl -Headers $AuthorizationHeader -Method $Method -Body $Body -UseBasicParsing:$UseBasicParsing -ErrorVariable restError
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
