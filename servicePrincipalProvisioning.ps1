# Script to provision a Service Principal for daemon/service applications
# Es: .\servicePrincipalProvisioning.ps1 -TenantId "12345678-90ab-cdef-1234-567890abcdef" -AppId "abcd1234-5678-90ab-cdef-1234567890ab"


param (
    [Parameter(Mandatory=$true)]
    [string]$TenantId,  # The Azure AD Tenant ID (mandatory)

    [Parameter(Mandatory=$true)]
    [string]$AppId      # The Application (Client) ID of the daemon/service app (mandatory)
)

# Set the execution policy for the current process
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Check if the Microsoft Graph Applications module is installed; install it if missing
if ($null -eq (Get-Module -ListAvailable -Name "Microsoft.Graph.Applications")) {
    Install-Module "Microsoft.Graph.Applications" -Scope CurrentUser
}

# Define parameters for creating the Service Principal
$params = @{
    appId = $AppId
}

# Create the Service Principal using the provided Application ID
New-MgServicePrincipal -BodyParameter $params
