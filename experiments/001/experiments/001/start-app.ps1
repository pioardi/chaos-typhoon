param(
    [Parameter()] [string]$functionAppName,
    [Parameter()] [string]$resourceGroupName,
    [Parameter()] [string]$subscriptionId
)
Start-AzFunctionApp -Name $functionAppName -ResourceGroupName $resourceGroupName -SubscriptionId $subscriptionId