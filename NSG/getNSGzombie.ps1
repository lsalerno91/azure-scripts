# Find NSG zombie on all the subscriptions 
# For each subscription, it creates an output file with Name, RG, and Subscription of the NSG Zombie
# The full list of the NSG Zombie for all the subscriptions is in $NSGZombie

# Login ad Azure
Connect-AzAccount

# Date used for the file name
$Date = Get-Date
$Date = $Date.ToString("yyyy-MM-dd")

# Get all the subscriptions
$Subscriptions = Get-AzSubscription

# NSG without associations (full list of all subscriptions)
$NSGZombie = @()

foreach ($subscription in $subscriptions)
{
    Select-AzSubscription $subscription 

    $nsgs = Get-AzNetworkSecurityGroup

    # NSG Zombie in the selected subscription
    $NSGZombiePerSub = @()

    # Get all the NSG zombie in the subscription
    $nsgZ = $nsgs | Where-Object {($_.Subnets.Count -eq 0) -and ($_.NetworkInterfaces.Count -eq 0)} 
    
    # Create an object with Name, RG, and Subscription for each NSG zombie and add it to 2 lists
    foreach($nsg in $nsgZ){
        $tmp = New-Object PSObject
        $tmp | Add-Member -membertype noteproperty -name "NSGname" -value $nsg.Name
        $tmp | Add-Member -membertype noteproperty -name "RGname" -value $nsg.ResourceGroupName
        $tmp | Add-Member -membertype noteproperty -name "Subscription" -value $subscription.Name
        $NSGZombie += $tmp
        $NSGZombiePerSub += $tmp
    }

    # Create a file per subscription
    $SubscriptionName = $Subscription.Name
    $path = "C:\Users\lorenzo.salerno\Desktop\SOGEI\Powershell\Export.\"+"NSGZombie - "+$SubscriptionName+$Date+".xlsx"
    $NSGZombiePerSub | Export-Excel -Path $path
}


