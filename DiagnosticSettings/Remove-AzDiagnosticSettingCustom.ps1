

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

Remove-CazDiagnosticSettingCustom -ResourceType nsg -ResourceGroupName conn-tests -DestinationLaws "eeab0244-132c-4ec4-bcc5-57b515a045a2-rg-aksTest-WEU" -DryRun