<#
.Description
Enable the auto-upgrade option of the AMA monitoring agent for all the VMs in the selected subscription.

.NOTES
Requires Azure Az PowerShell module Az.Compute
Before running the script, connect to the Azure Tenant and select the proper Subscription.
#>

# Get the Running VMs
$runningVMs = Get-AzVM -Status | Where-Object PowerState -eq "VM running"

Write-Host "Checking AMA auto-upgrade on " ($runningVMs | Measure-Object).Count " VMs"

# VMs where I enable the autoupgrade of the AMA agent
$linuxVMs = @()
$windowsVMs = @()

foreach ($vm in $runningVMs) {

    # check if the VM has the AzureMonitorLinuxAgent and it is in a succeeded provisioning state
    if ((Get-AzVMExtension -ResourceId $vm.Id).Name -contains "AzureMonitorLinuxAgent" -and (Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "AzureMonitorLinuxAgent").ProvisioningState -eq "Succeeded") {
        # check if the AMA has the Automatic Upgrade Disabled
        if($null -eq (Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "AzureMonitorLinuxAgent").EnableAutomaticUpgrade){
            $linuxVMs += $vm
            Write-Host "Enabling autoupdate on " $vm.Name
            Set-AzVMExtension -ExtensionName "AzureMonitorLinuxAgent" -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Publisher "Microsoft.Azure.Monitor" `
                -ExtensionType "AzureMonitorLinuxAgent" -EnableAutomaticUpgrade $true
        }   
    }
    # check if the VM has the MicrosoftMonitoringAgent and it is in a succeeded provisioning state
    if ((Get-AzVMExtension -ResourceId $vm.Id).Name -contains "MicrosoftMonitoringAgent" -and (Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "MicrosoftMonitoringAgent").ProvisioningState -eq "Succeeded") {
        # check if the AMA has the Automatic Upgrade Disabled
        if($null -eq (Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "MicrosoftMonitoringAgent").EnableAutomaticUpgrade){
            $linuxVMs += $vm
            Write-Host "Enabling autoupdate on " $vm.Name
            Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Publisher "Microsoft.Azure.Monitor" `
                -ExtensionType "AzureMonitorWindowsAgent" -EnableAutomaticUpgrade $true
        }   
    }
}

Write-Host "AMA auto-upgrade abilitato su:"
$linuxVMs | Format-Table
$windowsVMs | Format-Table