@description('Location for resources')
param location string = resourceGroup().location

@description('VM name')
param vmName string = 'enterprise'

@description('Admin username')
param adminUsername string = 'Camosun'

@secure()
@description('Admin password (min 12 chars)')
param adminPassword string

@description('VNet name')
param vnetName string = 'enterprise-VNet'

@description('Subnet name')
param subnetName string = 'Subnet-1'

@description('NSG name (for NIC attachment)')
param nsgName string = 'enterprise-NSG'

@description('VM size')
param vmSize string = 'Standard_B2s'

@description('Number of VMs')
param vmCount int = 2

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
            id: publicIp[i].id  // Fixed: Index the specific PIP
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

resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = [for i in range(0, vmCount): {  // Fixed API version
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
        sku: '2022-datacenter-azure-edition-core'  // Fixed valid SKU
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
          id: nic[i].id  // Fixed: Index the specific NIC
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}]
