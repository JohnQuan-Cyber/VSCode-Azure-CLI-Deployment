// This code is to deploy this template with the location of the resource group you are in
@description('Location for resources')
param location string = resourceGroup().location

// This is a parameter naming the VM with the name enterprise
@description('VM name')
param vmName string = 'enterprise'

// This is a parameter naming the admin username with Enterprise
@description('Admin username')
param adminUsername string = 'Enterprise'

// This parameter will prompt you to create a password in the command line 
@secure()
@description('Admin password (min 12 chars)')
param adminPassword string

// This parameter is naming the vnet
@description('VNet name')
param vnetName string = 'enterprise-VNet'

// This allows you to choose the the subnet to deploy the VMs in if you use the parameters command on the CLI
@allowed([
  'Subnet-1'
  'Subnet-2'
  'Subnet-3'
  'Subnet-4'
  'Subnet-5'
])

@description('Subnet name')
param subnetName string = 'Subnet-1'

@description('NSG name (for NIC attachment)')
param nsgName string = 'enterprise-NSG'

@description('VM size')
param vmSize string = 'Standard_B2s'

@description('Number of VMs')
param vmCount int = 2

// The resources here is making sure that when the Virtual Machines are created that it will use the existinf reources 
resource existingVnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: vnetName
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' existing = {
  parent: existingVnet
  name: subnetName
}

resource existingNsg 'Microsoft.Network/networkSecurityGroups@2025-05-01' existing = {
  name: nsgName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = [for i in range(0, vmCount): {
  name: '${vmName}-pip${i + 1}'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${vmName}${i + 1}-${uniqueString(resourceGroup().id)}'
    }
  }
  sku: {
    name: 'Standard'
  }
}]

resource nic 'Microsoft.Network/networkInterfaces@2025-05-01' = [for i in range(0, vmCount): {
  name: '${vmName}-nic${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp[i].id
          }
          subnet: {
            id: existingSubnet.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: existingNsg.id
    }
  }
}]

// We are configuring the Virtual Machine here. The for loop allows you to create the VMs until the condition is met. The vmCount is set to 2 so the loop will break after tow Virtual Machines are created
resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = [for i in range(0, vmCount): {
  name: '${vmName}-VM${i + 1}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${vmName}-VM${i + 1}'  // Unique per VM
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2025-datacenter-azure-edition-core'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}]
