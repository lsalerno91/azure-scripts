# Generate token 
az account get-access-token

# login from external browser
az login --use-device-code

# show account details
az account show

# set subscription
Select-AzSubscription -SubscriptionId $subscriptionId
az account set --subscription $subscriptionId

# list subscriptions
az account list --output table

# Change Tenant
az login -t $tenantId

# List Tenants
az account tenant list
Get-AzTenant

# List Subscriptions
Get-AzSubscription

# Connect with a user managed identity (only from an azure resource with the UMI associated)
Connect-AzAccount -Identity -AccountId $identity