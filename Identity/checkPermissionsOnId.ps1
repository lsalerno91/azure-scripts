# Given a User Assigned Managed Identity (UAMI), this script checks its RBAC permissions across all subscriptions in the same tenant.
# It exports the results to a CSV file.

param(
    [Parameter(Mandatory=$true)]
    [string]$ManagedIdentityName,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName
)

# Login to Azure if not already authenticated
# This will prompt for credentials if not already logged in
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

# Get the Identity
try {
    $uami = Get-AzUserAssignedIdentity -Name $ManagedIdentityName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
} catch {
    Write-Error "UAMI $ManagedIdentityName not found in the resource group $ResourceGroupName"
    exit
}


$principalId = $uami.PrincipalId
Write-Host "UAMI: $($uami.Name)"
Write-Host "PrincipalId: $principalId"

# Get the subscriptions in the current tenant
$subscriptions = Get-AzSubscription
if ($subscriptions.Count -eq 0) {
    Write-Warning "No subscriptions found in the current tenant."
    exit
}

$results = @()

foreach ($sub in $subscriptions) {
    Write-Host "Subscription: $($sub.Name)"
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    try {
        $assignments = Get-AzRoleAssignment -ObjectId $principalId
        foreach ($a in $assignments) {
            $role = Get-AzRoleDefinition -Id $a.RoleDefinitionId
            $results += [PSCustomObject]@{
                SubscriptionName = $sub.Name
                Role             = $role.Name
                Scope            = $a.Scope
            }
        }
    } catch {
        Write-Warning "Error in the subscription $($sub.Name): $_"
    }
}

if ($results.Count -eq 0) {
    Write-Host "No RBAC role found for the UAMI $ManagedIdentityName in any subscription."
} else {
    Write-Host "Founded roles: $($results.Count)"
    $results | Format-Table -AutoSize

    # Export results to CSV file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmm"
    $csvPath = ".\RBAC_UAMI_$($ManagedIdentityName)_$($timestamp).csv"
    $results | Export-Csv -NoTypeInformation -Path $csvPath
    Write-Host "Exported in: $csvPath"
}
