$apps = Get-AzWebApp
$appsWithoutPep = @()

foreach ($app in $apps) {

    # Get the private endpoint associated to the web app
    $privateEndpoint = Get-AzPrivateEndpoint -ResourceGroupName $app.ResourceGroup | Where-Object { $_.PrivateLinkServiceConnections[0].PrivateLinkServiceId -eq $app.Id }

    if (-not $privateEndpoint) {
        Write-Warning "No private endpoint found for App Service: "$app.Name
        $tmp = New-Object PSObject
        $tmp | Add-Member -membertype noteproperty -name "WebApp" -value $app.Name
        $tmp | Add-Member -membertype noteproperty -name "RG" -value $app.ResourceGroup
        $appsWithoutPep += $tmp
    } 
}

# Display the results in a table format
$appsWithoutPep | Format-Table -Property WebApp, RG -AutoSize