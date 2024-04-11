<#
.SYNOPSIS
The function Set-AzVmExtensionForceUpgrade upgrade an extension to the newest version on all the VMs in the selected subscription.

.DESCRIPTION
To update an extention is need to rerun it. To do it, we need to change something in the configuration of our extension. 
But what if we don’t want to change anything? In these cases, we can modify the “forceUpdateTag” property. 
Unlike most properties, Azure actually doesn’t use this value at all. You can provide any string you want, and it will not 
affect the extension at all. It exists specifically so that you can modify it to cause the extension to rerun.
This function update the “forceUpdateTag” property with a random string, so that if you run twice the function on the same
VM extension, the extension will be always redeployed. 
Because we changed the value of “forceUpdateTag”, Azure will recognize this as a change to the extension and rerun it.


.PARAMETER ExtensionName (Mandatory)
String that specify the extension name

.EXAMPLE
Set-AzVmExtensionForceUpgrade -ExtensionName "AzureMonitorLinuxAgent"
Set-AzVmExtensionForceUpgrade -ExtensionName "AzureMonitorWindowsAgent"

.NOTES
Before running the function, connect to the Azure tenant and select the subscription where you want to operate.
The scope of the function is at subscription level.

VERSION HISTORY
1.0 | 2024/04/11 | Lorenzo Salerno (l.salerno91@gmail.com)

#>

function Set-AzVmExtensionForceUpgrade {

    param( 
        [Parameter(Mandatory = $true)]
        [string]$ExtensionName
    )

    # Generate a random string for the VmExtension Attribute "ForceUpdateTag"
    $randomString = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})

    # Get the Running VMs
    $runningVMs = Get-AzVM -Status | Where-Object PowerState -eq "VM running"

    Write-Host "Checking extensions on " ($runningVMs | Measure-Object).Count " VMs"

    # List of the VM with an extension that has been updated
    $resourcesUpdated = @()

    foreach ($vm in $runningVMs) {
        # check if the VM has the extension installed and it is in a succeeded provisioning state
        if (((Get-AzVMExtension -ResourceId $vm.Id).Name -contains $ExtensionName) -and ((Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name $ExtensionName).ProvisioningState -eq "Succeeded")) {
            # force the extension update
            $resourcesUpdated += $vm.Name
            Write-Host "Rerunning extension on VM: " $vm.Name
            $extension = Get-AzVmExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name $ExtensionName
            Set-AzVMExtension -Publisher $extension.Publisher -ExtensionType $extension.ExtensionType -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name $ExtensionName -ForceRerun $randomString
        }
    }

    Write-Host "Extensions updated on the following VMs:"
    $resourcesUpdated | Format-Table

}