param location string = resourceGroup().location
param vnetName string = 'enterprise'

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: '${vnetName}-VNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
  }
  
  @batchSize(1)
  resource subnets 'subnets' = [for i in range(0, 5): {
    name: 'Subnet-${i + 1}'
    properties: {
      addressPrefix: '10.0.${i}.0/24'
    }
  }]
}
