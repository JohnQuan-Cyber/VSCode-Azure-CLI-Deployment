# Set the parameters to shorten the commands
$grp = "EnterpriseDemo"
$loc = "WestUS"

# Use this commnad to deploy the resource group
az group create --resource-group $grp --location $loc

# Use these commands to deploy the Virtual Network and Network Security Group
az deployment group create --resource-group $grp --template-file .\EnterpriseVNet.bicep
az deployment group create --resource-group $grp --template-file .\EnterpriseNSG.bicep

# Use this command to check if there resources deployed in the resource group. We are checking to see if there is already Virtual Machines
# deployed in Subnet-2 of the VNet. 
# EnterpriseVM.becip would deploy the VMs in Subnet-1 and we are terying to deploy in Subnet-2 
az deployment group what-if --resource-group $grp --template-file .\EnterpriseVM2.bicep --parameters subnetName='Subnet-2'

# Use this command to create the Virtual Machines in Subnet-2 once we find out that we that we can.
az deployment group create --resource-group $grp --template-file .\EnterpriseVM2.bicep --parameters subnetName='Subnet-2'

# Once the Virtual Machines are deployed. Check to see if the following are deployed:
#
# EnterpriseDemo - Resource Group
# EnterpriseVNet - Virtual Network (Three Subnets should be deployed in this deployment)
# EnterpriseNSG - Network Security Group (Two inbound rules should be created: RDP + HTTP)
# EnterpriseVM2 - Virtual MAchines (Two Virtual Machines are deployed with NIC and PIP)

# Once Everything is confirmed. Try to RDP into the devices. Then delete the deployment
az group delete --resource-group $grp --yes --no-wait