function Invoke-AuroraAddRecord {
    <#
.SYNOPSIS
    Get Aurora DNS Record
.DESCRIPTION
    Get Aurora DNS Record
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER ZoneID
    Specify a specific Aurora DNS Zone ID (GUID).
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
    PS C:\>$record = Invoke-AuroraAddRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -Name www -Content 198.51.100.85 @auroraAuthorization
    Create an 'A' record with the name 'www' and content '198.51.100.85'
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$record = Invoke-AuroraAddRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -Content 'v=spf1 include:_spf.google.com' -Type TXT @auroraAuthorization
    Create an 'TXT' for the domain (no record name) and content 'v=spf1 include:_spf.google.com'
.NOTES
    Function Name : Invoke-AuroraAddRecord
    Version       : v2021.0522.1915
    Author        : John Billekens
    Requires      : API Account => https://cp.pcextreme.nl/auroradns/users
.LINK
    https://blog.j81.nl
#> 
    [CmdletBinding()]
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
        
        [Parameter(Mandatory)]
        [String]$Name = '',
        
        [String]$Content = '',
        
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
    $Method = 'POST'
    $Uri = '/zones/{0}/records' -f $ZoneID.Guid
    $ApiUrl = 'https://{0}{1}' -f $Api, $Uri
    $AuthorizationHeader = Get-AuroraDNSAuthorizationHeader -Key $Key -Secret $Secret -Method $Method -Uri $Uri
    $restError = ''

    $Payload = @{
        name    = $Name
        ttl     = $TTL
        type    = $Type
        content = $Content
    }
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
