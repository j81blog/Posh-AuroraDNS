# Posh-AuroraDNS

PowerShell Aurora DNS (PCExtreme) functions

Here are some examples about how to use the functions.
If you haven't done it already, you need to generate API Credentials for your account from the [DNS - Health Checks Users](https://cp.pcextreme.nl/auroradns/users) page. You should end up with an `API URL`, `Key` and `Secret` value.
The Api parameter is optional and you only have to specify it if it differs from 'api.auroradns.eu'

You can set a general variable with the 'credentials' and use (@splat) it for all functions.

```Powershell
$auroraAuthorization = @{ Api='api.auroradns.eu'; Key='XXXXXXXXXX'; Secret='YYYYYYYYYYYYYYYY' }
```

## Get-AuroraDNSAuthorizationHeader

You do not have to specify this unless you want to create your own functions / manual actions.

```Powershell
$authorizationHeader = Get-AuroraDNSAuthorizationHeader -Method GET -Uri /zones @auroraAuthorization
```

## Invoke-AuroraFindZone

Get zone that matches you specified full record name, e.g. 'www.domain.com'

```Powershell
$zone = Invoke-AuroraFindZone -RecordName www.domain.com @auroraAuthorization
```

## Invoke-AuroraGetZones

Get all zones

```Powershell
$zones = Invoke-AuroraGetZones @auroraAuthorization
```

## Invoke-AuroraGetRecord

List all records by not specifying 'RecordID' or 'RecordName' with a value

```Powershell
$records = Invoke-AuroraGetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' @auroraAuthorization
```

Get record with name 'www' in zone 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

```Powershell
$record = Invoke-AuroraGetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -RecordName 'www' @auroraAuthorization
```

Get record with ID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' in zone 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

```Powershell
$record = Invoke-AuroraGetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -RecordID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' @auroraAuthorization
```

## Invoke-AuroraAddRecord

Create an 'A' record with the name 'www' and content '198.51.100.85'

```Powershell
$record = Invoke-AuroraAddRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -Name www -Content 198.51.100.85 @auroraAuthorization
```

Create an 'TXT' for the domain (no record name) and content 'v=spf1 include:_spf.google.com'

```Powershell
$record = Invoke-AuroraAddRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -Content 'v=spf1 include:_spf.google.com' -Type TXT @auroraAuthorization
```

## Invoke-AuroraSetRecord

Set an existing record with new content '198.51.100.85'

```Powershell
$record = Invoke-AuroraSetRecord -ZoneID 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' -RecordID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' -Content 198.51.100.85 @auroraAuthorization
```

## Invoke-AuroraDeleteRecord

Delete a record with the ID 'vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz' in zone 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

```Powershell
Invoke-AuroraDeleteRecord -ZoneID aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee  -RecordID vvvvvvvv-wwww-xxxx-yyyy-zzzzzzzzzzzz @auroraAuthorization
```
