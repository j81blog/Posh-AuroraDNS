function Get-AuroraDNSAuthorizationHeader {
    <#
.SYNOPSIS
    Create headers required for Aurora DNS authorization
.DESCRIPTION
    Create headers required for Aurora DNS authorization
.PARAMETER Key
    The Aurora DNS API key for your account.
.PARAMETER Secret
    The Aurora DNS API secret key for your account.
.PARAMETER Method
    The method used for this action.
    Some of the most used: 'POST', 'GET' or 'DELETE'
.PARAMETER Uri
    The Uri used for this action.
    Example: '/zones'
.PARAMETER ContentType
    The content type.
    Default value (if not specified): 'application/json; charset=UTF-8'
.EXAMPLE
    $authorizationHeader = Get-AuroraDNSAuthorizationHeader -Key XXXXXXXXXX -Secret YYYYYYYYYYYYYYYY -Method GET -Uri /zones
.NOTES
    Function Name : Invoke-AuroraFindZone
    Version       : v2021.0522.1930
    Author        : John Billekens
    Requires      : API Account => https://cp.pcextreme.nl/auroradns/users
.LINK
    https://github.com/j81blog/Posh-AuroraDNS
#>  
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$Key,
        
        [Parameter(Mandatory)]
        [String]$Secret,
        
        [Parameter(Mandatory)]
        [String]$Method,
        
        [Parameter(Mandatory)]
        [String]$Uri,
        
        [Parameter()]
        [String]$ContentType = "application/json; charset=UTF-8",
        
        [Parameter(DontShow)]
        [String]$TimeStamp = $((get-date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")),
        
        [Parameter(ValueFromRemainingArguments, DontShow)]
        $ExtraParams
    )
    $Message = '{0}{1}{2}' -f $Method, $Uri, $TimeStamp
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.key = [Text.Encoding]::UTF8.GetBytes($Secret)
    $Signature = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($Message))
    $SignatureB64 = [Convert]::ToBase64String($signature)
    $AuthorizationString = '{0}:{1}' -f $Key, $SignatureB64
    $Authorization = [Text.Encoding]::UTF8.GetBytes($AuthorizationString)
    $AuthorizationB64 = [Convert]::ToBase64String($Authorization)
    
    $headers = @{
        'X-AuroraDNS-Date' = $TimeStamp
        'Authorization'    = $('AuroraDNSv1 {0}' -f $AuthorizationB64)
        'Content-Type'     = $ContentType
    }
    Write-Output $headers
}
