<#
.Description
Remove tags from all the resources of a given resource group

.NOTES
Requires Azure Az PowerShell module Az.Compute
Before running the script, connect to the Azure Tenant and select the proper Subscription.

.EXAMPLE
Remove-AzTagsFromRg -ResourceGroupName MyRg

.NOTES
VERSION HISTORY
1.0 | 2024/05/20 | Lorenzo Salerno (l.salerno91@gmail.com)
#>

function Remove-AzTagsFromRg {

    [CmdletBinding()]
    param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName
    )

    # Check if RG exists
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $resourceGroup) {
        Write-Host "Resource Group '$resourceGroupName' not found."
        return
    }

    # Get all resources in the resource group
    $resources = Get-AzResource -ResourceGroupName $resourceGroupName

    # Loop through each resource
    foreach ($resource in $resources) {
        # Remove all tags from the resource
        Write-Host "Removing tags from resource $($resource.Name)"
        $resource.Tags.Clear()

        # Update the resource
        Set-AzResource -ResourceId $resource.ResourceId -Tag $resource.Tags -Force
    }    
}

Remove-AzTagsFromRg -ResourceGroupName rg_Test