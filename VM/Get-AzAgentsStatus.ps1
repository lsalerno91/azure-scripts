<#
.Description
Check the status of any agent installed in the running VMs of the selected subscription.
The function prints the unhealthy agent list at the end of the script execution. 

.EXAMPLE
Get-AzAgentsStatus

.NOTES
Requires Azure Az PowerShell module Az.Compute
Before running the script, connect to the Azure Tenant and select the proper Subscription.

.NOTES
VERSION HISTORY
1.0 | 2024/04/10 | Lorenzo Salerno (l.salerno91@gmail.com)
#>

function Get-AzAgentsStatus {

# Get the Running VMs
$runningVMs = Get-AzVM -Status | Where-Object PowerState -eq "VM running"

Write-Host "Checking agents status on " ($runningVMs | Measure-Object).Count " VMs"

# Stauts of the agents for each VM
$VmAgentStatus = @()

# 
foreach ($vm in $runningVMs) {
    $agents = Get-AzVMExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name
    
    foreach($agent in $agents){
        $tmp = New-Object PSObject
        $tmp | Add-Member -membertype noteproperty -name "RG" -value $vm.ResourceGroupName
        $tmp | Add-Member -membertype noteproperty -name "VM" -value $vm.Name
        $tmp | Add-Member -membertype noteproperty -name "Agent" -value $agent.Name
        $tmp | Add-Member -membertype noteproperty -name "Status" -value $agent.ProvisioningState
    }

    $VmAgentStatus += $tmp
}

Write-Host "List of Unhealthy agents:"
$VmAgentStatus | Where-Object { $_.Status -ne "Succeeded" } | Format-Table

}