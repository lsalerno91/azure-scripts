<#
.Description
Remove the OMS/MMA monitoring agent from all the VMs in the selected subscription.
.Example
Remove-AzVMExtension -Name MicrosoftMonitoringAgent -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Force
Remove-AzVMExtension -Name OmsAgentForLinux -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Force
.NOTES
Requires Azure Az PowerShell module Az.Compute
#>

# Get the Running VMs
$runningVMs = Get-AzVM -Status | Where-Object PowerState -eq "VM running"

#$runningVMs = $vmList | Select-Object Name, Id, PowerState, OsName | Where-Object PowerState -eq "VM running"

# VMs with MMA/OMS agent
$linuxVMs = @()
$windowsVMs = @()

# 
foreach ($vm in $runningVMs) {

    # Remove OMS from running Linux VMs
    if ((Get-AzVMExtension -ResourceId $vm.Id).Name -contains "OmsAgentForLinux" -and (Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Name "OmsAgentForLinux").ProvisioningState -eq "Succeeded") {
        $linuxVMs += $vm
        Write-Host "Rimozione OMS agent da " $vm.Name
        Remove-AzVMExtension -Name OmsAgentForLinux -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Force
    }
    # Remove MMA from running Windows VMs
    if ((Get-AzVMExtension -ResourceId $vm.Id).Name -contains "MicrosoftMonitoringAgent") {
        $windowsVMs += $vm
        Write-Host "Rimozione MMA agent da " $vm.Name
        Remove-AzVMExtension -Name MicrosoftMonitoringAgent -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -Force
    }
}

Write-Host "OMS rimosso da: "
$linuxVMs | Format-Table

Write-Host "MMA rimosso da:"
$windowsVMs | Format-Table
