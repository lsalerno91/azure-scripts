# Set the variables values
$resourceGroupName = ""
$agwName = ""

# Get the Application Gateway object
$agw=Get-AzApplicationGateway -Name $agwName -ResourceGroupName $resourceGroupName

# Stop and start the Application Gateway
Stop-AzApplicationGateway -ApplicationGateway $agw
Start-AzApplicationGateway -ApplicationGateway $agw