param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param nsgName string = 'enterprise'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${nsgName}-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow_HTTP'
        properties: {
          description: 'Allowing HTTP'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_RDP'
        properties: {
          description:'Allowing RDP'
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

