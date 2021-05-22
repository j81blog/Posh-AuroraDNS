function Invoke-AuroraFindZone {
    <#
.SYNOPSIS
    Get Aurora DNS Zone based on full record/host name
.DESCRIPTION
    Get Aurora DNS Zone based on full record/host name
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER Api
    The Aurora DNS API hostname.
    Default (if not specified): api.auroradns.eu
.EXAMPLE
    $auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
    PS C:\>$zone = Invoke-AuroraFindZone -RecordName www.domain.com @auroraAuthorization
.NOTES
    Function Name : Invoke-AuroraFindZone
    Version       : v2021.0522.1915
    Author        : John Billekens
    Requires      : API Account => https://cp.pcextreme.nl/auroradns/users
.LINK
    https://blog.j81.nl
#>  
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [String]$RecordName,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Key,
        
        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$Secret,
        
        [Parameter(Position = 3)]
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
    $auroraAuthorization = @{ Api = $Api; Key = $Key; Secret = $Secret; UseBasicParsing = $UseBasicParsing }
    try {
        $zones = Invoke-AuroraGetZones @auroraAuthorization
    } catch { Write-Debug "Caught an error, $($_.Exception.Message)"; throw }
         
    Write-Debug "Search for the zone from longest to shortest set of FQDN pieces"
    $pieces = $RecordName.Split('.')
    for ($i = 0; $i -lt ($pieces.Count - 1); $i++) {
        $zoneTest = $pieces[$i..($pieces.Count - 1)] -join '.'
        Write-Debug "Checking $zoneTest"
        try {
            ## check for results
            $result = @($Zones | Where-Object { $_.name -eq $zoneTest })
            if ($result.Count -gt 0) {
                Write-Output $result
            }
        } catch { Write-Debug "Caught an error, $($_.Exception.Message)"; throw }
    }
}
