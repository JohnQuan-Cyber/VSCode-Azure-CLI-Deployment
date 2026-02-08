# Deployment of resource group and resources while on VSCode

**Prerequisite**
* Azure Account (Student Account is preferable to learn)
* Visual Studio Code
* AZ CLI
* Understanding in the ARM and Bicep Template Files
* Bicep Files (In this repository)

Since we are using a azure for students account, there is a limitation in what we can use and how much we can deploy. If the steps are followed correctly then you shouldn't be using too much credits when deploying these bicep template files.

# Steps

**Step 1 - Set the parameters to shorten the commands**

Enter these variables in the terminal 

* $grp = "EnterpriseDemo"
* $loc = "WestUS"

**Step 2 - Deploying the Resource Group**

Using the command will create a resource group with the location that it will be deployed in

* az group create --resource-group $grp --location $loc

**Step - 3 Deploying the Virtual Network and Network security Group templates**

We are deploying 2 seperate files. One file will contain the Virtual Network that will deploy three subnets. The second file will deploy the Network Security Group with two inbound rules (RDP and SSH)

* az deployment group create --resource-group $grp --template-file .\EnterpriseVNet.bicep
* az deployment group create --resource-group $grp --template-file .\EnterpriseNSG.bicep

**Step 4 - Use the pre-flight check**

We are using the what-if command as a validation check to make sure that if we deploy a template, that it will succeed in the deployment. We will add the parameter 'Subnet-2' to verify that I can deploy.

* az deployment group what-if --resource-group $grp --template-file .\EnterpriseVM2.bicep --parameters subnetName='Subnet-2'

**Step 5 - Deploying the Virtual Machines**

We are deploying virtual machines into Subnet-2 after the pre-flight check.

* az deployment group create --resource-group $grp --template-file .\EnterpriseVM2.bicep --parameters subnetName='Subnet-2'

**Checklist**

Once all the templates are deployed. confirm that each of these reources are deployed.

EnterpriseDemo - Resource Group
EnterpriseVNet - Virtual Network (Three Subnets should be deployed in this deployment)
EnterpriseNSG - Network Security Group (Two inbound rules should be created: RDP + HTTP)
EnterpriseVM2 - Virtual MAchines (Two Virtual Machines are deployed with NIC and PIP)

**Step 6 - Delete the deployment**

You got to the final step. It's time to delete the resource group and the resources. 

* az group delete --resource-group $grp --yes --no-wait
