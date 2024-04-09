<#
.SYNOPSIS
The function Remove-AzDiagnosticSettingCustom removes DS from all the resources of a specific resource type.

.DESCRIPTION
Before running the function, connect to the Azure tenant and select the subscription where you want to operate.
You can set the scope of the function at subscription level, or at resource group level.   

.PARAMETER DestinationLaws (Optional)
Array of strings with the names of the Log Analytics Workspaces. 
If you want to remove all the diagnostic settings, leave it empty. 
If you want to delete all the diagnostic settings, except for the ones sending logs to a specific workspace (e.g. the Sentinel workspace), 
specify the workspace name in this parameter. 
It can be more than one workspace. 

.PARAMETER ResourceType (Mandatory)
Specify the type of Azure resource from which you want to delete the diagnostic settings.
Allowed values: 
- nsg
- pip
- app
- agw

.PARAMETER ResourceGroupName (Optional)
Set the scope at RG level. 
If not specified, the scope will be at subscription level.

.PARAMETER DryRun
If you set this parameter, the DS will not be deleted. 
The function will tell you all the resources that have DS to delete without performing the deletion. 

.EXAMPLE
Remove-AzDiagnosticSettingCustom -ResourceType nsg -ResourceGroupName conn-tests -DestinationLaws "eeab0244-132c-4ec4-bcc5-57b515a045a2-rg-aksTest-WEU" -DryRun

.NOTES
VERSION HISTORY
1.0 | 2024/04/06 | Lorenzo Salerno (l.salerno91@gmail.com)

#>

function Remove-AzDiagnosticSettingCustom {

    [CmdletBinding()]
    param( 
        [string[]]$DestinationLaws,
        [Parameter(Mandatory = $true)]
        [ValidateSet("nsg", "pip", "app")]
        [string]$ResourceType,
        [string]$ResourceGroupName,
        [switch]$DryRun
    )

    $resources = @()
    $resourcesToDelete = @()

    switch ($ResourceType) {
        "nsg" {
            Write-Host "ResourceType selected: NSG (Network Security Group)."
            $resources = ($PSBoundParameters.ContainsKey('ResourceGroupName')) ? (Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName) : (Get-AzNetworkSecurityGroup) 
        }
        "pip" {
            Write-Host "ResourceType selected: PIP (Public IP Address)."
            $resources = ($PSBoundParameters.ContainsKey('ResourceGroupName')) ? (Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName) : (Get-AzPublicIpAddress) 
        }
        "app" {
            Write-Host "ResourceType selected: APP (Web Apps)."
            $resources = ($PSBoundParameters.ContainsKey('ResourceGroupName')) ? (Get-AzWebApp -ResourceGroupName $ResourceGroupName) : (Get-AzWebApp) 

        }
        "agw" {
            Write-Host "ResourceType selected: AGW (Application Gateway)."
            $resources = ($PSBoundParameters.ContainsKey('ResourceGroupName')) ? (Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName) : (Get-AzApplicationGateway) 
        }
        default {
            Write-Host "ResourceType selected not valid: " $ResourceType
        }
    }

    foreach ($resource in $resources) {
        
        # get the DS of the current resource
        $dsList = Get-AzDiagnosticSetting -ResourceId $resource.Id

        # check DS that sends logs to Sentinel
        foreach ($ds in $dsList) {
            if ($ds.WorkspaceId.Split("/")[-1] -notin $DestinationLaws) {
                $resourcesToDelete += $resource
                if(!$PSBoundParameters.ContainsKey('DryRun')) {
                    Write-Host "removing DS " $ds.Name " from resource " $resource.Name
                    Remove-AzDiagnosticSetting -ResourceId $resource.Id -Name $ds.Name
                }
            }
        }   
    }

    Write-Host "The following " $ResourceType " have DS to delete: "
    $resourcesToDelete

}


$comandoStringa = "Get-AzWebApp -ResourceGroupName 'NomeGruppoRisorse'"
Invoke-Expression $comandoStringa

param (
        [scriptblock]$comando
    )

    # Esegui il comando fornito come parametro
    Invoke-Command -ScriptBlock $comando