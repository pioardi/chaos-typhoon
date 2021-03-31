param(
    [Parameter()] [string]$subscriptionId,
    [Parameter()] [string]$prefix
)
# Connect-AzAccount
# deploy.ps1 -subscriptionId '0bc0e570-beae-4da5-bc38-d98039c84edc' -prefix apatest 
Set-AzContext -Subscription $subscriptionId
Write-Host "Creating azure resource groups"
New-AzResourceGroup -Name chaos-we -Location westeurope
New-AzResourceGroup -Name chaos-ne -Location northeurope
New-AzResourceGroup -Name chaos-global -Location northeurope
Write-Host "Azure resource groups created"

Write-Host "Deploy cosmos db"
New-AzResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName 'chaos-ne' `
  -TemplateFile './cosmos.json' `
  -accountName "$prefix-cosmos-ne-01" `
  -location 'northeurope' `
  -databaseName 'blob'
Write-Host "cosmos db deployed"


Write-Host "Deploy function app in the primary region"
$primaryAppName = "$prefix-supplychain-fa-01"
$secondaryAppName = "$prefix-supplychain-fa-02"

New-AzResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName 'chaos-ne' `
  -TemplateFile './functioapp.json' `
  -appName $primaryAppName `
  -storageAccountType 'Standard_LRS' `
  -location 'northeurope' `
  -appInsightsLocation 'northeurope' `
  -runtime 'node'
Write-Host "function app in the primary region deployed"

Write-Host "Deploy function app in the secondary region"
New-AzResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName 'chaos-we' `
  -TemplateFile './functioapp.json' `
  -appName $secondaryAppName `
  -storageAccountType 'Standard_LRS' `
  -location 'westeurope' `
  -appInsightsLocation 'westeurope' `
  -runtime 'node'
Write-Host "function app in the secondary region deployed"


Write-Host "Deploy front door"
New-AzResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName 'chaos-global' `
  -TemplateFile './frontdoor.json' `
  -frontDoorName "$prefix-supplychain-fake-apa-03" `
  -primaryBackendAddress "$primaryAppName.azurewebsites.net" `
  -secondaryBackendAddress "$secondaryAppName.azurewebsites.net"

Write-Host "Front door deployed"

Write-Host "Code deployment"

Set-Location ../code/
func azure functionapp publish $primaryAppName
func azure functionapp publish $secondaryAppName


# TODO Setup enviornment variables to run chaos experiments
$primaryAppId = (Get-AzApplicationInsights -ResourceGroupName 'chaos-ne' -Name $primaryAppName -Full).AppId
$secondaryAppId = (Get-AzApplicationInsights -ResourceGroupName 'chaos-we' -Name $secondaryAppName -Full).AppId
Write-Host "Please before to run the experiments set up the following environment variables"
Write-Host "export PRIMARY_APP_ID=$primaryAppId"
Write-Host "export SECONDARY_APP_ID=$secondaryAppId"
Write-Host "export FUNCTION_APP_NAME=$primaryAppName"
Write-Host "export RG_NAME=chaos-ne"
Write-Host "export SUBSCRIPTION_ID=$subscriptionId"
Write-Host "export URL=https://$prefix-supplychain-fake-apa-03.azurefd.net"