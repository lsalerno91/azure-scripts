# Setup Variables
$apiManagementName=""
$apiManagementResourceGroup=""
$storageAccountName=""
$storageResourceGroup=""
$containerName=""
$blobName="170424backup.apimbackup"

# Storage access
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageResourceGroup -StorageAccountName $storageAccountName)[0].Value
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

# Backup
Backup-AzApiManagement -ResourceGroupName $apiManagementResourceGroup -Name $apiManagementName `
    -StorageContext $storageContext -TargetContainerName $containerName -TargetBlobName $blobName

# Restore
Restore-AzApiManagement -ResourceGroupName $apiManagementResourceGroup -Name $apiManagementName `
    -StorageContext $storageContext -SourceContainerName $containerName -SourceBlobName $blobName

