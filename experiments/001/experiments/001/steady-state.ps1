param(
    [Parameter()] [string]$baseUri,
    [Parameter()] [string]$primaryAppId,
    [Parameter()] [string]$secondaryAppId
 )
$token = (Get-AzAccessToken).Token
$bearerToken = "Bearer " + $token
$currentTime =  (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffK")
$ordersToSend = 1000
Write-Host $primaryAppId
Write-Host $secondaryAppId
Write-Host $baseUri

Write-Host "Send orders"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

for ($i=1; $i -le $ordersToSend; $i++)
{
    $body = @{
        id =  $i
    }
    $headers = @{ 
        'Content-Type' = "application/json";
        'Cache-Control' = 'no-cache';
        'postman-token' = 'e13d7aa0-19a7-9820-bfa0-f701f52251ce';
    }
    # Send 120 orders per minute
    Sleep 0.2
    Write-Host "Iteration $i"
    # $res1 = Invoke-RestMethod -Method Post -Uri "$baseUri/SendOrder" -Body ( $body | ConvertTo-Json )
    $res1 =Invoke-WebRequest -Method Post -Uri "$baseUri/api/SendOrder" -Body ( $body | ConvertTo-Json ) -Headers $headers
    
    # Process orders is invoked only to simplify the simulation, in a real world system this step should be done
    # via events and a bus in the middle
    $res2 = Invoke-RestMethod -Method POST -Uri "$baseUri/api/ProcessOrder" -Body ( $body | ConvertTo-Json ) -Headers $headers
}

#Check business metrics.
# We know how much orders we have sent
<#
customMetrics 
| where name == "OrderReceived" or name == "OrderProcessed"
| where timestamp > datetime(2021-03-30T06:30:00Z)
| summarize count() by name   
#>
$token = (Get-AzAccessToken -ResourceTypeName "OperationalInsights").Token
$bearerToken = "Bearer " + $token
$primaryAppInsightsUri = "https://api.applicationinsights.io/v1/apps/$primaryAppId/query"
$secondaryAppInsightsUri = "https://api.applicationinsights.io/v1/apps/$secondaryAppId/query"
$headers = @{ 'Content-Type' = "application/json" ; 'authorization' = $bearerToken}
$body = @{
    query =  "set query_take_max_records=30001;set truncationmaxsize=67108864;customMetrics| where name == `"OrderReceived`" or name == `"OrderProcessed`"| where timestamp > datetime($currentTime)| summarize count() by name   "
}

Write-Host $body.query
Write-Host "Sleep 3 minutes to wait metrics propagation"
Sleep 180
$primaryMetrics = Invoke-RestMethod -Method POST -Uri $primaryAppInsightsUri -Body ( $body | ConvertTo-Json ) -Headers $headers
$secondaryMetrics = Invoke-RestMethod -Method POST -Uri $secondaryAppInsightsUri -Body ( $body | ConvertTo-Json ) -Headers $headers
$numberOfOrdersReceived = 0
$numberOfOrdersProcessed = 0
# TODO Use the time to repair to decide if the experiment is successful or not
if($primaryMetrics.tables.rows){
    $numberOfOrdersReceived = $primaryMetrics.tables.rows[0][1]
    $numberOfOrdersProcessed = $primaryMetrics.tables.rows[1][1]
}

if($secondaryMetrics.tables.rows){
    $numberOfOrdersReceived = $numberOfOrdersReceived + $secondaryMetrics.tables.rows[0][1]
    $numberOfOrdersProcessed = $numberOfOrdersProcessed + $secondaryMetrics.tables.rows[1][1]
}

Write-Host ( $numberOfOrdersReceived )
Write-Host ( $numberOfOrdersProcessed )

$minNumberOfProcessedOrders = ($ordersToSend * 80) / 100
if( $numberOfOrdersProcessed -lt $minNumberOfProcessedOrders) {
    Write-Error "The system is not in steady state"
    exit 1
} else {
    exit 0
}
