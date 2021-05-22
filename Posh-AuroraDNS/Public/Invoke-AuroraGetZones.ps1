function Invoke-AuroraGetZones {
    <#
.SYNOPSIS
    Get Aurora DNS Zones
.DESCRIPTION
    Get Aurora DNS Zones
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER Api
    The Aurora DNS API hostname.
    Default (if not specified): api.auroradns.eu
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$zones = Invoke-AuroraGetZones @auroraAuthorization
.NOTES
    Function Name : Invoke-AuroraGetZones
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

        [Parameter()]
        [ValidateNotNullOrEmpty()]
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
    $Uri = '/zones'
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
