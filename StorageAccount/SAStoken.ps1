############## SAS TOKEN GENERATION ##############
##################################################

# In some cases, generating the SAS Token from Azure CLI/Azure PowerShell becomes necessary because certain settings are not available from the portal. 
# For example, if you want to add the permission to read tags (t) to the SAS. In these cases, the choice between Azure CLI and Azure PowerShell is 
# crucial since Azure CLI has a limitation on the maximum allowed duration, which is 7 days for account-level SAS tokens and a maximum of 90 days for 
# blob-level SAS tokens. In contrast, with Azure PowerShell, it is possible to generate SAS tokens with an expiration of up to 1 year.

# AZURE CLI
# - permissions: (r)ead, (w)rite, (d)elete, (a)dd, (c)reate, (u)pdate, (p)rocess, (t)ag
# - date format: 2025-10-02
az storage blob generate-sas --account-name <storage-account-name> --container-name <container-name> --permissions racwdit --expiry <date> --https-only --as-user --output tsv --auth-mode login

# AZURE POWERSHELL
$context = New-AzStorageContext -StorageAccountName "<storage-account-name>" -StorageAccountKey "<primary-key>"
$expiryDate = (Get-Date).AddDays(365) 

# SAS token at Container level
$sasToken = New-AzStorageContainerSASToken -Container "<container-name>" -Context $context -Permission racwdit -ExpiryTime $expiryDate

# SAS token at Blob level
$sasToken = New-AzStorageBlobSASToken -Container "<container-name>" -Blob "<blob-name>" -Context $context -Permission racwdit -ExpiryTime $expiryDate


################ SAS TOKEN TEST #################
#################################################

# Test a SAS TOKEN using curl to retrieve the tags of a file within a container
https://<storage-account-name>.blob.core.windows.net/<container-name>/<blob-name>?comp=tags&<sas-token>

