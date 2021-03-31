param(
    [Parameter()] [string]$functionAppName,
    [Parameter()] [string]$resourceGroupName,
    [Parameter()] [string]$subscriptionId
)
Stop-AzFunctionApp -Name $functionAppName -ResourceGroupName $resourceGroupName -SubscriptionId $subscriptionId -Force